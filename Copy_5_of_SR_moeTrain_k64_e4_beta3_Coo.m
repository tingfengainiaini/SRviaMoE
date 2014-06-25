clc;
clear;
%SR_moeTrain_ENumFixed(kmeans_Num,Gbeta, maxIt, ExpertNum, LearningRate, lamda, ERelation, EUseTol, EUseW_0, GUseMetric)
SR_moeTrain_ENumFixed(32, 3, 25, 16, 0.0001,1, 'Compete',0,1,0); 
%SR_moeTest_ENumFixed(kmeans_Num, Gbeta, ExpertsNum, lamda, ERelation)
SR_moeTest_ENumFixed(32, 3, 16,1,'Compete',0,1,0);

