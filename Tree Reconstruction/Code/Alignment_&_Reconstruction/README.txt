### Alignment_Reconstruction

### 1. What is each file?  
- BL_to_mut_freq.Rmd: given a .csv file which contains a pair of parent-child bacodes in each row, splits each barcode into 10 single bits and summarizes the frequency of each type of mutations at each position. The output is type_mut.csv. Besides, the second part takes in all the predicted trees and compares with ground-truth trees to get the normalized RF. The output file are "train_RF.csv" and "test_RF.csv".
- alignment_parent_child_pair: given the function implemented in alignment_parent_child_pair_func.R, the program takes in each array of barcodes from the train/test dataset, performs pairwise alignment using the mutation frequency-based scoring matrix. The alignment scores are stored in a distance matrix, which is then constructed into tree using upgma. The output is a list of trees in Newick format, saved in "train_newick.csv" and "test_newick.csv".
- alignment_parent_child_pair_func: contains all the functions required

### 2. What do you need to run this portion?  
- csv file which contains the original training and testing data
- directory containing a csv file for every tree with each row being a trit of the form parent | child | pred_len
 
### 3. System Requirements?  
- R with necessary packages source in 
