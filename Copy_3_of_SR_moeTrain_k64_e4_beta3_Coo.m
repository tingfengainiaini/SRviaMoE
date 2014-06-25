clc;
clear;
%SR_moeTrain_ENumFixed(kmeans_Num,Gbeta, maxIt, ExpertNum, LearningRate, lamda, ERelation, EUseTol, EUseW_0, GUseMetric)
SR_moeTrain_ENumFixed(64, 3, 25, 4, 0.0002,1, 'Coorperate',0,1,0); 
%SR_moeTest_ENumFixed(kmeans_Num, Gbeta, ExpertsNum, lamda, ERelation)
SR_moeTest_ENumFixed(64, 3, 4, 1,'Coorperate',0,1,0);

