
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

treeData = "(((1_2102111000:136,(2_2100101000:11,3_2100101000:11):124):45,(((4_2121101121:4,5_2121101121:4):69,(6_2121101101:12,7_2121101101:12):61):57,((8_2211100221:12,13_2111101221:12):63,(15_2110101221:22,16_2111101221:22):53):55):50):31,(((17_2122111100:35,18_2122111100:35):43,(19_2122111100:24,20_2122111100:24):54):53,((21_0111001001:17,22_0111001001:17):59,(23_2101101001:21,24_0101001001:21):55):55):80);"
tree = read.newick(text = treeData)
terminal_vector <- rep(NA, length(tree$tip.label))
names(terminal_vector) <- tree$tip.label

for (currentIndex in seq(1, length(terminal_vector)))
{
  #we have already dealt with this node 
  if (!is.na(terminal_vector[currentIndex]))
  {
    next
  }
  
  currentNode <- tree$tip.label[currentIndex]
  sisterOfCurrentNode <- unlist(getSisters(tree, currentNode, mode = "label")[1])
  
  #if the sister node is another terminal
  if (names(sisterOfCurrentNode) == "tips")
  {
    parentNode <- determine_parent_funct(currentNode, sisterOfCurrentNode)
    terminal_vector[which(names(terminal_vector) == parentNode)] <- ifelse(parentNode == currentNode, sisterOfCurrentNode, currentNode)
    terminal_vector[which(names(terminal_vector) == ifelse(parentNode == currentNode, sisterOfCurrentNode, currentNode))] <- "Child."
  }
  
  #if the sister node is another node 
  else 
  {
    siblings_vec <- tree$tip.label[unlist(Descendants(tree, sisterOfCurrentNode, type = "tips")[1])]
    terminal_vector[which(names(terminal_vector) == currentNode)] <- determine_parent_funct(siblings_vec[1], siblings_vec[2])
  }
}

