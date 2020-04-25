#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Branch Length Prediction Evaluation

Created on Sat Apr 25 12:13:11 2020

@author: Noah Igra nmi2106
"""
import numpy as np
import torch
import torch.nn as nn
from BranchPreprocess import Preprocess

##### STATEMENT #####
#Functions related to taking a .txt file of format
#.txt
#----Tree(list)
#    ----Pair(list)
#        ---- [parent(str),child(str)]
#And returning a data set with the same format:
#            [parent(str), child(str), predicted Branch length (float)]
#For branch length values bw 0 and 1
#####################

##### Model Definition and Functions #####

class BranchModel(nn.Module):
    '''
    Multilayer FFN, just trynna predict whats going on
    '''
    
    def __init__(self):
        super(BranchModel, self).__init__()
        
        self.fc1 = nn.Linear(42, 42*2)
        self.fc2 = nn.Linear(42*2, 42*4)
        self.fc3 = nn.Linear(42*4, 42*2)
        self.fc4 = nn.Linear(42*2, 42)
        self.final = nn.Linear(42,1)
        
    def forward(self, x):
        x = self.fc1(x)
        x = self.fc2(x)
        x = self.fc3(x)
        x = self.fc4(x)
        x = self.final(x)
        return torch.sigmoid(x)
    

def Evaluate(df_path, model_path):
    '''
    Main Buddy
    Inputs:
        df_path(str): Pathway to .txt file with format
            FILE.txt
                ----tree(list)
                    ----pair(list)
                        ----[parent(str), child(str)]
        model_path(str): Pathway to where the FNN is saved
            (EX: 'my_model_sleeps_here/Best_Brancher.pth')
    Returns:
        Numpy Array of form:
            ---tree(list)
                ----pair(list)
                    ----[parent(str),child(str),BL(float)]
    '''
    BM = BranchModel()
    state_dict = torch.load(model_path)
    BM.load_state_dict(state_dict)
    BM.eval()
    DATA_LIST, OG_DATA = Preprocess(df_path)
    for i in range(len(DATA_LIST)):
        tree = DATA_LIST[i]
        for j in range(len(tree)):
            pair = tree[j]
            pair_np = np.array(pair)
            pair_torch = torch.from_numpy(pair_np).type(torch.FloatTensor)
            predicted_bl = BM(pair_torch).view(1).item()
            OG_DATA[i][j]. append(predicted_bl)
    

    return OG_DATA
    
    
    