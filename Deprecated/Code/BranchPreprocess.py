#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Branch Length Prediction Preprocessing

Created on Sat Apr 25 12:13:11 2020

@author: Noah Igra nmi2106
"""

import numpy as np

##### STATEMENT #####
#Functions related to taking a .txt file of format
#.txt
#----Tree(list)
#    ----Pair(list)
#        ---- [parent(str),child(str)]
#And returning a .csv file of same form with pair list of form:
#            [parent(str), child(str), predicted Branch length (float)]
#For branch length values bw 0 and 1
#####################


##### Preprocessing #####

def load_from_txt(path):
    '''Given a .txt file of the data, return an array'''
    loaded_data = []
    
    with open(path) as infile:
        lines = infile.readlines()
        for line in lines:
            line_list = line[2:len(line)-4].split('], ')
            new_line_list = []
            for pair in line_list:#[parent,child,branchlength] objects
                pair = pair[1:].split(', ')
                new_pair = pair
                new_pair[2] = float(pair[2])
                new_line_list.append(new_pair)
            loaded_data.append(new_line_list)
            
    return np.array(loaded_data)


def mutations_data(pair):
    '''
    Input:
        pair(list): [parent(str),child(str)]
    Returns:
        mutant_row(list) of length 42
    '''
    mutant_row = []
    parent, child = pair[0], pair[1]
    mut_count = 0
    prev_muts = 0
    for i in range(10):
        #for every 4 cells
        #[1->0,1->2,already_1->0,already_1->2]
        if parent[i] == '1' and child[i] == '0':
            mutant_row.extend([1,0,0,0])
            mut_count +=1
        elif parent[i] == '1' and child[i] == '2':
            mutant_row.extend([0,1,0,0])
            mut_count +=1
        elif parent[i] == '1' and child[i] == '1':
            mutant_row.extend([0,0,0,0])
        elif parent[i] == '0':
            mutant_row.extend([0,0,1,0])
            prev_muts += 1
        else:
            mutant_row.extend([0,0,0,1])
            prev_muts += 1
    mutant_row.extend([mut_count,prev_muts])
    
    return mutant_row




def Preprocess(df_path):
    '''
    Inputs:
        df_path(str): path to .txt formatted data
    Returns:
        datalist of form tree -pair etc.
    '''
    
    data = load_from_txt(df_path)
    
    data_list = []
    
    for tree in data:
        processed_tree = []
        for pair in tree:
            processed_pair = mutations_data(pair)
            processed_tree.append(processed_pair)
        data_list.append(processed_tree)

    return data_list, data


    


    