# import necessary packages 
require("phytools")
require ("phangorn")
require("data.table")
require("ape")


zero_pad_function <- function(word) 
{
  if (nchar(word) == 10)
  {
    return (word)
  }
  
  else
  {
    nchar_word <- nchar(word)
    padded_word <- paste(strrep("0", 10 - nchar_word), word, sep= "")
    return (padded_word)
  }
}

convert_trit_to_newick_funct <- function(index, original_test_data)
{
  setwd("/Users/mayatalukdar/Desktop/CBMF4761-final-project/")
  #source necessary functions
  source("training_data_generators_functions.R")
  
  
  setwd("/Users/mayatalukdar/Desktop/CBMF4761-final-project/BL/train_csv/")
  
  print(index)
  # open up appropriate test file and parse it 
  learned_test_data <- read.csv(paste(index, ".csv", sep = ""))
  learned_test_data <- apply(learned_test_data, 2, as.character)
  if (index == 53)
  {
    learned_test_data <- t(learned_test_data)
  }
  learned_test_data[,1] <- sapply(learned_test_data[,1], zero_pad_function)
  learned_test_data[,2] <- sapply(learned_test_data[,2], zero_pad_function)

  # create original newick tree and a copy we will manipulate 
  og_newick_tree <- read.newick(text = as.character(original_test_data$ground[index]))
  new_newick_tree <- read.newick(text = as.character(original_test_data$ground[index]))
  
  
  ## TAKEN FROM ANOTHER FUNCTION 
  # initialize node lists
  terminalNodeList <- og_newick_tree$tip.label
  nonTerminalNodeList <- rev(seq(length(og_newick_tree$tip.label) + 1, length(og_newick_tree$tip.label) + og_newick_tree$Nnode))
  rootNode <- length(og_newick_tree$tip.label) + 1
  
  #initialize index of node names
  indexVec <- setNames(terminalNodeList, seq(1, length(terminalNodeList)))
  indexVec <- c(indexVec, setNames(seq(length(og_newick_tree$tip.label) + 1, length(og_newick_tree$tip.label) + og_newick_tree$Nnode), seq(length(og_newick_tree$tip.label) + 1, length(og_newick_tree$tip.label) + og_newick_tree$Nnode)))
  
  # generate edge length dictionary 
  edgeLengthTable <- create_edge_length_table_funct(og_newick_tree, indexVec)
  
  # initialize list that matches nodes to barcodes 
  terminalNodeBarcodeList <- sapply(og_newick_tree$tip.label, function(x) sub("^[^_]*_", "", x))
  nonTerminalNodeBarcodeList <- setNames(rep(NA, og_newick_tree$Nnode), rev(seq(length(og_newick_tree$tip.label) + 1, length(og_newick_tree$tip.label) + og_newick_tree$Nnode)))
  nodeBarcodeList <- c(terminalNodeBarcodeList, nonTerminalNodeBarcodeList)
  
  # traverse the og_newick_tree bottom-up, imputing barcodes and adding to our list of parent/child nodes 
  parentChildListString = "["
  for (nonTerminalNode in nonTerminalNodeList)
  {
    # get barcodes of children 
    childOne <- setNames(indexVec[Descendants(og_newick_tree, nonTerminalNode, type = "children")[1]], NULL)
    childOneBarcode <- nodeBarcodeList[which(names(nodeBarcodeList) == childOne)]
    childTwo <- setNames(indexVec[Descendants(og_newick_tree, nonTerminalNode, type = "children")[2]], NULL)
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
  
  #convert any tips to their node indices 
  names(nodeBarcodeList) <- sapply(names(nodeBarcodeList), function(x) ifelse(x %in% og_newick_tree$tip.label, which(og_newick_tree$tip.label == x), x))
  
  # get new edge lengths
  new_edge_lengths <- vector()
  og_edge_matrix <- og_newick_tree$edge
  for (row_index in seq(1, nrow(og_edge_matrix)))
  {
    parent_barcode <- nodeBarcodeList[which(names(nodeBarcodeList) == og_edge_matrix[row_index, 1])]
    child_barcode <- nodeBarcodeList[which(names(nodeBarcodeList) == og_edge_matrix[row_index, 2])]
    new_dist <- learned_test_data[intersect(which(learned_test_data[,1] == parent_barcode),which(learned_test_data[,2] == child_barcode)),3]
    if (length(new_dist) == 0)
    {
      new_dist <- learned_test_data[which(learned_test_data[,1] == parent_barcode)[1],3]
    }
    
    if (is.na(new_dist))
    {
      new_dist <- 1/nrow(og_edge_matrix)
    }
      
    new_edge_lengths <- c(new_edge_lengths, new_dist)
  }
  new_edge_lengths <- as.numeric(new_edge_lengths)
  
  new_newick_tree$edge.length <- new_edge_lengths
  
  return (write.tree(new_newick_tree))
}

#create a list of newick trees from the test data
setwd("/Users/mayatalukdar/Desktop/CBMF4761-final-project/BL")
original_test_data <- read.csv("train_newick.csv")
new_newick_tree_list <- sapply(seq(nrow(original_test_data)), function(x) convert_trit_to_newick_funct(x, original_test_data))

#write out
setwd("/Users/mayatalukdar/Desktop/CBMF4761-final-project/BL")
write.csv(new_newick_tree_list, "trained_trees_in_newick_format_train_csv_MAY_3.csv", row.names = FALSE)
  
  
  
