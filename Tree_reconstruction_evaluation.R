library(phangorn)
library(phytools)

# Use the distance matrix learned from the ground-truth
score_matrix <- rbind(c(2,6,10),c(6,0,4),c(10,4,3))

# Define a function to align a pair of 10-bit barcodes
pair.alignment <- function(x, y, score_matrix){
  #The inital state is 1111111111
  score <- 0 # alignment score
  for (i in 1:10){ # 10 bits
    a <- as.integer(substr(x,i,i))
    b <- as.integer(substr(y,i,i))
    # 0->0 change corresponds to score_matrix[1,1]
    score <- score + score_matrix[a+1,b+1]  # update score
  }
  return(score)
}

# Define a function to pairwisely align a set of barcodes
# returns a distance matrix
Tree.reconstruction <- function(barcodes, score_matrix){
  l <- length(barcodes)
  m <- matrix(0, nrow = l, ncol = l)
  for (i in 2:l){
    for (j in 1:(i-1)){
      m[i,j] <- pair.alignment(barcodes[i], barcodes[j], score_matrix)
    }
  }
  # generate row and col names for the distance matrix m
  i <- 1:l
  names <- sapply(i, function(k) paste(k,barcodes[k], sep='_'))
  row.names(m) <- names
  colnames(m) <- names
  return(m)
}


# Test on a tree wiht 9 leaves
barcode_x <- c('2012212021', '2112212021', '2112212021', '2112212021', '0012212221', '0012012221', '2120010021', '2120010021', '0112212221')
DM <- Tree.reconstruction(barcode_x, score_matrix)
DM
# Generate a tree by UPGMA
upgma.tree <- upgma(DM, method = "average")
plot(upgma.tree, main="UPGMA")
# Generate a tree by Neighbor Joining
nj.tree <- NJ(DM)
plot(nj.tree, main="NJ")

# Evaluate normalized RF

# Load the ground truth tree in Newick format
tree <- '((((1_2012212021:8,2_2112212021:8):38,(3_2112212021:4,4_2112212021:4):42):42,(5_0012212221:1,6_0012012221:1):87):46,((7_2120010021:22,8_2120010021:22):51,9_0112212221:74):62);'
ground.truth <- read.newick(text = tree)
plot(ground.truth, main = "ground_truth")
#check normalized RF, caution: trees must have identical labels
RF.upgma <- RF.dist(upgma.tree, ground.truth, normalize = T)
RF.upgma
RF.nj <- RF.dist(nj.tree, ground.truth, normalize = T)
RF.nj