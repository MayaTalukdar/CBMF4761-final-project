require("phytools")
require ("phangorn")

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
  }
}

geerate_parent_child_pairs_funct <- function(currentIndex)
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