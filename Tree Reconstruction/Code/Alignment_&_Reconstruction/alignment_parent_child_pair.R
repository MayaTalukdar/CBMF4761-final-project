library(tidyverse)
library(phangorn)
library(phytools)

# train sets

train <- read.csv("DREAM_data_intMEMOIR_train.csv",stringsAsFactors=FALSE)
# read all gt trees and barcode sets
all.barcodes <- str_extract_all(train$ground, regex("\\d{1,3}_\\d{10}")) # id_10bits
all.ground.truth <- read.newick(text = train$ground)
# create distance matrix for each barcode set
dist <- sapply(all.barcodes, Tree.reconstruction)
# construct upgma tree and extract all parent-child pairs
train.output <- sapply(dist, function(k) convert_tree_to_row_no_BL(upgma(k, method = "average")))
# write to .txt
fileConn<-file("train_output.txt")
writeLines(train.output, fileConn)
close(fileConn)

#test sets

test <- read.csv("DREAM_data_intMEMOIR_test.csv",stringsAsFactors=FALSE)
# read all gt trees and barcode sets
test.barcodes <- str_extract_all(test$ground, regex("\\d{1,3}_\\d{10}")) # id_10bits
test.ground.truth <- read.newick(text = test$ground)
# create distance matrix for each barcode set
dist <- sapply(test.barcodes, Tree.reconstruction)
# construct upgma tree and extract all parent-child pairs
test.output <- sapply(dist, function(k) convert_tree_to_row_no_BL(upgma(k, method = "average")))
# write to .txt
fileConn<-file("test_output.txt")
writeLines(test.output, fileConn)
close(fileConn)