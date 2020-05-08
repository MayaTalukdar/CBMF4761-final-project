# align a pair of barcodes based on score matrix
pair.alignment <- function(x, y){
  #The inital state is 1111111111
  score_matrix <- rbind(c(0,1,2.27),c(1,0,1.27),c(2.27,1.27,0))
  score <- 0 # alignment score
  for (i in 1:10){ # 10 bits
    a <- as.integer(substr(x,i,i))
    b <- as.integer(substr(y,i,i))
    # 0->0 change corresponds to score_matrix[1,1]
    score <- score + score_matrix[a+1,b+1]  # update score
  }
  return(score)
}

# generate distance matrix for tree construct
Tree.reconstruction <- function(barcodes){
  l <- length(barcodes)
  barcode.set <- str_sub(barcodes,-10,-1) # remove "id_"
  m <- matrix(0, nrow = l, ncol = l)
  for (i in 2:l){
    for (j in 1:(i-1)){
      m[i,j] <- pair.alignment(barcode.set[i], barcode.set[j])
    }
  }
  # generate row and col names for the distance matrix m
  i <- 1:l
  row.names(m) <- barcodes
  colnames(m) <- barcodes
  return(m)
}


# impute parent from a pair of barcodes
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

convert_tree_to_row_no_BL <- function(tree)
{
  # initialize node lists
  terminalNodeList <- tree$tip.label
  nonTerminalNodeList <- rev(seq(length(tree$tip.label) + 1, length(tree$tip.label) + tree$Nnode))
  rootNode <- length(tree$tip.label) + 1
  
  #initialize index of node names
  indexVec <- setNames(terminalNodeList, seq(1, length(terminalNodeList)))
  indexVec <- c(indexVec, setNames(seq(length(tree$tip.label) + 1, length(tree$tip.label) + tree$Nnode), seq(length(tree$tip.label) + 1, length(tree$tip.label) + tree$Nnode)))
  
  # generate edge length dictionary 
  #edgeLengthTable <- create_edge_length_table_funct(tree, indexVec)
  
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
      #edgeLength = as.numeric(as.character(edgeLengthTable$length[edgeLengthTable$node_1 == nonTerminalNode & edgeLengthTable$node_2 == childOne]))
      parentChildListString <- paste(parentChildListString, "[", parentBarcode, ", ", childOneBarcode,"], ", sep = "")
    }
    
    if (parentBarcode != childTwoBarcode)
    {
      #edgeLength = as.numeric(as.character(edgeLengthTable$length[edgeLengthTable$node_1 == nonTerminalNode & edgeLengthTable$node_2 == childTwo]))
      parentChildListString <- paste(parentChildListString, "[", parentBarcode, ", ", childTwoBarcode,"], ", sep = "")
    }
    
  }
  parentChildListString = paste(substr(parentChildListString, 1, nchar(parentChildListString) - 2), "]", sep = "")
  
  return (parentChildListString)
  
}