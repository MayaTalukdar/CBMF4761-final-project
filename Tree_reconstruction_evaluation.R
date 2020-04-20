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
  names <- sapply(i, function(k) paste(k,barcodes[k], sep='-'))
  row.names(m) <- names
  colnames(m) <- names
  return(m)
}

# Use the tree with DreamID = 1 to test
barcode_1 = c('2012210001', '2012210001', '2212210001', '2112210001')
DM.1 <- Tree.reconstruction(barcode_1, score_matrix)
DM.1

# Generate a tree by UPGMA
upgma.tree <- upgma(DM.1, method = "average")
plot(upgma.tree, main="UPGMA")

# Generate a tree by Neighbor Joining
nj.tree <- NJ(DM.1)
plot(nj.tree, main="NJ")

# Test another tree
barcode_x <- c('2012212021', '2112212021', '2112212021', '2112212021', '0012212221', '0012012221', '2120010021', '2120010021', '0112212221')
DM <- Tree.reconstruction(barcode_x, score_matrix)
DM
# Generate a tree by UPGMA
upgma.tree <- upgma(DM, method = "average")
plot(upgma.tree, main="UPGMA")
# Generate a tree by Neighbor Joining
nj.tree <- NJ(DM)
plot(nj.tree, main="NJ")
