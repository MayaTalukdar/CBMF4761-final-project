require("phytools")
require ("phangorn")
require("data.table")

determine_parent_funct <- function(barcode_1, barcode_2)
{
  mutArray1= sub("^[^_]*_", "", barcode_1)
  mutArray2= sub("^[^_]*_", "", barcode_2)

  if (mutArray1 == mutArray2)
  {
    return (barcode_1)
  }
  
  else
  {
    for (currentIndex in seq(1, nchar(mutArray1)))
    {
      mutArray1CurrentChar <- substr(mutArray1, currentIndex, currentIndex)
      mutArray2CurrentChar <- substr(mutArray2, currentIndex, currentIndex)

      if (mutArray1CurrentChar == mutArray2CurrentChar)
      {
        next
      }
      
      else if (mutArray1CurrentChar !="1" & mutArray2CurrentChar !="1")
      {
        next
      }
      
      else 
      {
        if (mutArray1CurrentChar == "1")
        {
          return (barcode_1)
        }
        
        else if (mutArray2CurrentChar == "1")
        {
          return (barcode_2)
        }
      }
    }

    return (barcode_1)
  }
}

generate_parent_child_pairs_funct <- function(currentIndex, tree)
{
  currentNode <- tree$tip.label[currentIndex]
  currentNodeArray <- sub("^[^_]*_", "", currentNode)
  sisterOfCurrentNode <- unlist(getSisters(tree, currentNode, mode = "label")[1])
  sisterOfCurrentNodeArray <-  sub("^[^_]*_", "", sisterOfCurrentNode)
  
  #if the sister node is another terminal
  if (names(sisterOfCurrentNode) == "tips")
  {
    parentNode <- determine_parent_funct(currentNode, sisterOfCurrentNode)
    parentNodeArray <- sub("^[^_]*_", "", parentNode)
    
    if (parentNodeArray == currentNodeArray & parentNodeArray == sisterOfCurrentNodeArray)
    {
      return (ifelse(which(tree$tip.label == currentNode) < which(tree$tip.label == sisterOfCurrentNode), sisterOfCurrentNode, "Child."))
    }
    return (ifelse(parentNode == currentNode, sisterOfCurrentNode, "Child."))
  }
  
  #if the sister node is another node 
  else 
  {
    siblings_vec <- tree$tip.label[unlist(Descendants(tree, sisterOfCurrentNode, type = "tips")[1])]
    return(determine_parent_funct(siblings_vec[1], siblings_vec[2]))
  }
}

convert_ground_truth_entry_to_training_data_funct <- function(ground_truth_entry_index, ground_truth_trees)
{
  ground_truth_entry <- ground_truth_trees[ground_truth_entry_index]
  tree <- read.newick(text = ground_truth_entry)
  plotTree(tree, nodes.numbers = TRUE)
  parent_child_pairs <- sapply(seq(1, length(tree$tip.label)), function(x) generate_parent_child_pairs_funct(x, tree))
  names(parent_child_pairs) <- tree$tip.label

  parent_child_pairs_string <- "("
  for (currentIndex in seq(1, length(parent_child_pairs)))
  {
    if (parent_child_pairs[currentIndex] == "Child.")
    {
      next
    }

    else 
    {
      parentNodeArray <- sub("^[^_]*_", "", names(parent_child_pairs[currentIndex]))
      childNodeArray <- sub("^[^_]*_", "", parent_child_pairs[currentIndex])
      parent_child_pairs_string <- paste(parent_child_pairs_string, paste(parentNodeArray, childNodeArray, sep = ", "), "), ", sep = "")
    }
  }
  parent_child_pairs_string <- paste(substr(parent_child_pairs_string, 1, nchar(parent_child_pairs_string) - 3), ")", sep = "")
  feature_string <- "["
  feature_string <- paste(feature_string, paste(ground_truth_entry_index, parent_child_pairs_string, sep = ": "), "]", sep = "")

  return (feature_string)
}

convert_DREAM_file_to_training_data_funct <- function(DREAM_data_file_name)
{
  DREAM_data <- fread(DREAM_data_file_name)
  ground_truth_trees <- DREAM_data$ground
  results <- sapply(seq(1, length(ground_truth_trees)), function(x) convert_ground_truth_entry_to_training_data_funct(x, ground_truth_trees))



} 

setwd("Desktop/CBMF4761-final-project/Data/")
DREAM_data_file_name <-  "DREAM_data_intMEMOIR.csv"
