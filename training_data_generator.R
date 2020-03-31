require(phytools)
require(phangorn)
source(file = "training_data_generator_functions.R")
require(data.table)









treeData = "(((1_2102111000:136,(2_2100101000:11,3_2100101000:11):124):45,(((4_2121101121:4,5_2121101121:4):69,(6_2121101101:12,7_2121101101:12):61):57,((8_2211100221:12,13_2111101221:12):63,(15_2110101221:22,16_2111101221:22):53):55):50):31,(((17_2122111100:35,18_2122111100:35):43,(19_2122111100:24,20_2122111100:24):54):53,((21_0111001001:17,22_0111001001:17):59,(23_2101101001:21,24_0101001001:21):55):55):80);"
tree = read.newick(text = treeData)
terminal_vector <- sapply(seq(1, length(tree$tip.label)), function(x) generate_terminal_vector_funct(x))
names(terminal_vector) <- tree$tip.label
View(as.data.frame(terminal_vector))