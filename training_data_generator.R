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



generate_terminal_vector_funct <- function(currentIndex)
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
treeData = "(((1_2102111000:136,(2_2100101000:11,3_2100101000:11):124):45,(((4_2121101121:4,5_2121101121:4):69,(6_2121101101:12,7_2121101101:12):61):57,((8_2211100221:12,13_2111101221:12):63,(15_2110101221:22,16_2111101221:22):53):55):50):31,(((17_2122111100:35,18_2122111100:35):43,(19_2122111100:24,20_2122111100:24):54):53,((21_0111001001:17,22_0111001001:17):59,(23_2101101001:21,24_0101001001:21):55):55):80);"
tree = read.newick(text = treeData)
terminal_vector <- sapply(seq(1, length(tree$tip.label)), function(x) generate_terminal_vector_funct(x))
names(terminal_vector) <- tree$tip.label
View(as.data.frame(terminal_vector))