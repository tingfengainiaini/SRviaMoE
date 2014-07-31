clc;
clear;
%function SR_moeTrain_ENumFixed(kmeans_Num,Gbeta, maxIt, ExpertNum, LearningRate, lamda, ERelation, EUseTol, EUseW_0, GUseMetric, dataNum)
SR_moeTrain_ENumFixed(8, 3, 50, 64, 0.0002,0.1, 'Compete',0,0,0,80000); 
%function SR_moeTest_ENumFixed(kmeans_Num, Gbeta, ExpertsNum, lamda, ERelation, EUseTol, EUseW_0, GUseMetric, dataNum)
SR_moeTest_ENumFixed(8, 3, 64,0.1,'Compete',0,0,0,80000);