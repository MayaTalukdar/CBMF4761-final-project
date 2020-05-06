### Generating training and testing data in proper format 
### 1. What is each file? 
- training_data_generator_functions: various functions needed to turn a Newick tree given in the training or test data into a list of trits of the format [parent, child, branch-length]
	- includes function called get_parent_barcode_funct(child1, child2), which imputes the barcode of the parent of child1 and child2 using the following algorithm:
		1. if bits match at current position, keep this bit in the parent barcode 
		2. if bits do not match, replace that bit in the parent barcode with a 1 
		(aka the symbol for a non-mutated site 
- training_data_generator
	- utilizes training_data_generator_functions() to convert CSV files of DREAM data into a text file where each row is list of trits with aforementioned format that corresponds to the tree represented by Newick format in that row in the training or test data 

### 2. What do you need to run this portion?  
- CSV files where each row contains a column entitled ground that contains a tree in Newick format 
 
### 3. System Requirements?  
R with required packages (indicated in scripts) sourced in 
