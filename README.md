# WeightedPvalue: A software for integrative genomic data analysis via p-value weight adjustment. 

This is a software for integrative genomic data analysisvia p-value weight adjustment. The method is desinged to identify X -> Z-> Y, for example: miRNA -> mRNA -> Disease. First, the p-values are calculated based on the associations between the variables in X and Y. Then weights are derived according to the strength of associations between X, Z and Z and Y. The weighted p-value 


There are three files: 
Source.R, RunSim.R, and RunRealData.R. 

* Source.R contains the source code for calculating weighted p value  
RunSim.R contains the r code for running simulation analysis in the paper. Need to source the Source.R file in the begining. 

* RunSim.R contains the r code for analyzing a dataset. Need to source the Source.R file in the begining. The method is desinged to identify X -> Z-> Y, for example: miRNA -> mRNA -> Disease. The colnames of the dataset need to contain X, Y, Z  to inform the algorithm the types of data. 
