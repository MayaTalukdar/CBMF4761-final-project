### Converts list of trits to Newick format

### 1. What is each file?  
- convert_trit_to_newick_tree_functions.R: given a file where each row contains the original tree in Newick format, takes in set of trits of reconstructed tree in order to change the branch lengths of the original tree based on branch lengths learned from neural network. returns a CSV file with one Newick tree/row 
	- note: reconstructing a tree from a set of trits is non-deterministic. thus, the user must pass in a file containing the topology of each original tree as a Newick string as this method will only alter branch lengths and is unable to reconstruct a tree's topology based on trits alone. thus, the topology of the tree must first be determined (described elsewhere in this directory). 

### 2. What do you need to run this portion?  
- csv file where each row is a tree in Newick format whose branch lengths we will modify 
- directory containing a csv file for every tree with each row being a trit of the form parent | child | pred_len
 
### 3. System Requirements?  
- R with necessary packages source in 
