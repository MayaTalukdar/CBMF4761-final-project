### Branch Prediction with Neural Networks  
### 1. What is each file?  
**Example.ipynb** - Notebook exemplifying processing of tree data to return trees with predicted branch lengths  
**BranchEvaluate.py / BranchPreprocess.py** - Modules for Evaluation function in Example.ipynb. Based on the same functions in our setup  
**test_output_position_adj.txt** - Text file with rows representing trees as nested lists of pairs for parent,child string objects of length 10  
**test_adj_csv** - Folder with .csv files representing branch corrected trees  
**Brancher.pth** - Pytorch Model that accepts a 1x42 Tensor and returns a 1x1 Float. Used in our Evaluation function in the Example.ipynb Notebook      
**setup**:  
    * NN Brancher.ipnyb - Notebook for preprocessing, training, and evaluating our FFN for branch prediction  
    * DREAM_data_intMEMOIR.csv - Reference for preprocessing our branch lengths, necessary for normalizing lengths by tree  
    * testing/trainingDataFinalOutput.txt - inputs for evaluation/training steps of setting up the Brancher network.


### 2. What do you need to run this portion?  
Text file of the same form as test_output_position_adj.txt, the Brancher.pth model and the associated .py Modules    
### 3. System Requirements?  
Python; numpy, torch, csv, os, BranchEvaluate, BranchPreprocess