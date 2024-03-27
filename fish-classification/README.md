# fish-classification

A preliminary custom residual neural network trained to classify Lake Trout and Smallmouth Bass from active hydroacoustic data. Here we split the data into regions of 5 pings with a frequency response across 249 frequencies. Each individual ping is labelled as data was collected from a tethered design. 

Raw data is pre-processed using Echoview software. In this, the target of interest is identified and the target strength of each frequency is decomposed. The RDS dataset here has auxilliary fish information plus the TS measure at each frequency. The script RNNScript then goes through a brief visualization of the data, splitting into test/training sets, and splitting the individual pings into temporally close sequencens of 5 pings. 
