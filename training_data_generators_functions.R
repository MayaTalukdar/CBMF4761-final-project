# import necessary packages 
require("phytools")
require ("phangorn")
require("data.table")

create_edge_length_table_funct <- function(tree, indexVec)
{
  # isolate edgeMat and add names 
  edgeMat <- tree$edge
  edgeMatNamed <- t(apply(edgeMat, 1, function(x) indexVec[x]))

  # add edge lengths
  edgeLengthTable <- cbind(edgeMatNamed, tree$edge.length)
  colnames(edgeLengthTable) <- c("node_1", "node_2", "length")

  return (as.data.frame(edgeLengthTable))
}

get_parent_barcode_funct <- function(barcode_1, barcode_2)
{
  parentBarcode <- ""

  for (charIndex in seq(1, nchar(barcode_1)))
  {
    barcode1Char <- substr(barcode_1, charIndex, charIndex)
    barcode2Char <- substr(barcode_2, charIndex, charIndex)

    if (barcode1Char == barcode2Char)
    {
       parentBarcode <- paste(parentBarcode, barcode1Char, sep = "") 
    }

    # if mismatch, replace with a 1
    else
    {
      parentBarcode <- paste(parentBarcode, "1", sep = "") 
    }
  }

  return (parentBarcode)
}

convert_DREAM_tree_to_training_data_row_funct <- function(DREAM_tree)
{
  # create Newick tree
  tree <- read.newick(DREAM_tree)

  # initialize node lists
  terminalNodeList <- tree$tip.label
  nonTerminalNodeList <- rev(seq(length(tree$tip.label) + 1, length(tree$tip.label) + tree$Nnode))
  rootNode <- length(tree$tip.label) + 1

  #initialize index of node names
  indexVec <- setNames(terminalNodeList, seq(1, length(terminalNodeList)))
  indexVec <- c(indexVec, setNames(seq(length(tree$tip.label) + 1, length(tree$tip.label) + tree$Nnode), seq(length(tree$tip.label) + 1, length(tree$tip.label) + tree$Nnode)))

  # generate edge length dictionary 
  edgeLengthTable <- create_edge_length_table_funct(tree, indexVec)

  # initialize list that matches nodes to barcodes 
  terminalNodeBarcodeList <- sapply(tree$tip.label, function(x) sub("^[^_]*_", "", x))
  nonTerminalNodeBarcodeList <- setNames(rep(NA, tree$Nnode), rev(seq(length(tree$tip.label) + 1, length(tree$tip.label) + tree$Nnode)))
  nodeBarcodeList <- c(terminalNodeBarcodeList, nonTerminalNodeBarcodeList)

  # traverse the tree bottom-up, imputing barcodes and adding to our list of parent/child nodes 
  parentChildListString = "["
  for (nonTerminalNode in nonTerminalNodeList)
  {
    # get barcodes of children 
    childOne <- setNames(indexVec[Descendants(tree, nonTerminalNode, type = "children")[1]], NULL)
    childOneBarcode <- nodeBarcodeList[which(names(nodeBarcodeList) == childOne)]
    childTwo <- setNames(indexVec[Descendants(tree, nonTerminalNode, type = "children")[2]], NULL)
    childTwoBarcode <- nodeBarcodeList[which(names(nodeBarcodeList) == childTwo)]

    # fill in parental barcode 
    parentBarcode <- get_parent_barcode_funct(childOneBarcode, childTwoBarcode)
    ## force barcode to be all 1s if root node 
    if (nonTerminalNode == rootNode)
    {
      parentBarcode <- "1111111111"
    }
    nodeBarcodeList[which(names(nodeBarcodeList) == nonTerminalNode)] <- parentBarcode

    # add string representations 
    if (parentBarcode != childOneBarcode)
    {
      edgeLength = as.numeric(as.character(edgeLengthTable$length[edgeLengthTable$node_1 == nonTerminalNode & edgeLengthTable$node_2 == childOne]))
      parentChildListString <- paste(parentChildListString, "[", parentBarcode, ", ", childOneBarcode, ", ", edgeLength, "], ", sep = "")
    }

    if (parentBarcode != childTwoBarcode)
    {
      edgeLength = as.numeric(as.character(edgeLengthTable$length[edgeLengthTable$node_1 == nonTerminalNode & edgeLengthTable$node_2 == childTwo]))
      parentChildListString <- paste(parentChildListString, "[", parentBarcode, ", ", childTwoBarcode, ", ", edgeLength, "], ", sep = "")
    }

  }
parentChildListString = paste(substr(parentChildListString, 1, nchar(parentChildListString) - 2), "]", sep = "")

return (parentChildListString)

}

