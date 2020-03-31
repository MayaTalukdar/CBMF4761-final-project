# change to match correct path 
setwd("Desktop/CBMF4761-final-project/")

# source in necessary functions and packages
source(file = "training_data_generators_functions.R")
library(data.table)

# generate training data in desired format
trainingDataDream <- fread("Data/DREAM_data_intMEMOIR_train.csv")
trainTrees <- trainingDataDream$ground
trainingDataFinalOutput <- as.data.frame(sapply(trainTrees, function(x) convert_DREAM_tree_to_training_data_row_funct(x)))
row.names(trainingDataFinalOutput) <- seq(1, nrow(trainingDataFinalOutput))
write.table(trainingDataFinalOutput, "trainingDataFinalOutput.txt")

# generate testing data in desired format
testingDataDream <- fread("Data/DREAM_data_intMEMOIR_test.csv")
testTrees <- testingDataDream$ground
testingDataFinalOutput <- as.data.frame(sapply(testTrees, function(x) convert_DREAM_tree_to_training_data_row_funct(x)))
row.names(testingDataFinalOutput) <- seq(1, nrow(testingDataFinalOutput))
write.table(testingDataFinalOutput, "testingDataFinalOutput.txt")

