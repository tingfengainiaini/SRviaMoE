clc;
clear;
%function SR_moeTrain_ENumFixed(kmeans_Num,Gbeta, maxIt, ExpertNum, LearningRate, lamda, ERelation, EUseTol, EUseW_0, GUseMetric, dataNum)
SR_moeTrain_ENumFixed(16, 3, 30, 8, 0.0005,0.1, 'Compete',0,1,0,20000); 
%function SR_moeTest_ENumFixed(kmeans_Num, Gbeta, ExpertsNum, lamda, ERelation, EUseTol, EUseW_0, GUseMetric, dataNum)
SR_moeTest_ENumFixed(16, 3, 8,0.1,'Compete',0,1,0,20000);
