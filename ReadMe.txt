ʵ�ֹ��̸�word�ĵ���һ���ġ�

�ļ�˵����
---------------------------------------------------------------
ѵ���������ݣ�
----------
ѵ����ǰ������Cluster���ݺ�MappingData�ļ��С�
Cluster����ֱ���������������Ĵ����ܳ����ġ�
MappingData���ݵ����ķ����ǣ�
��Yang�Ĵ����ǰ������
PP1_GenerateFileNameList.m
PP2_ExtractPosition.m
PP3_RandomSelect.m
PP4_ExtractFeatureForClustering.m
PP5_TrainClusterCenter.m
PP6_LabelFeature.m
PP7_mine_TrainingMappingFuncBME.m
����kmean�����࣬�����ǰ�Ĳ�����һ��������ֻҪǰ�Ĳ��ܺ��ˣ���ֻ���ܺ���ľͿ����ˡ�������һ����LabelFeature��

---------------------------------------------------------------------------
1�� SR_moeTrain_ENumFixed.m
	------------------------
	SR_moeTrain_ENumFixed(kmeans_Num,Gbeta, maxIt, ExpertNum, LearningRate, ERelation)
	���������ѵ��moe�ġ�
	����˵����
	kmeans_Num����ʼkmeans����
	Gbeta: gate������beta��ȡֵ������1-10֮�䡣
	maxIt��ѵ��moe����������������EM��������
	ExpertNum��ÿ��moe �����õ�experts������
	LearningRate��M����gate�ĳ�ʼѧϰ���������á�
	ERelation��experts֮��Ĺ�ϵ��ֻ����Compete����Coorperate��
	    Compete��ָ�������ʹ��GatingOuputs�����Ǹ�Expert�������Ϊ�������
		Coorperate��ָ�������ʹ��Experts�������GatingOutputs ��Ȩ�����
		��Coorperateд�Ļ����Ǻ����ƣ�������Compete��
	���÷�ʽ������
	SR_moeTrain_ENumFixed(64, 3, 25, 8, 0.002, 'Coorperate'); 
-----------------------------------------------------------------------------
2�� SR_moeTest_ENumFixed.m
	-------------------------
	SR_moeTest_ENumFixed(kmeans_Num, Gbeta, ExpertsNum, ERelation)
	��������ǲ��Եģ����������õ�ͼƬֻ�����ţ�Ҳ����Dataset\benchmark\input�ļ����µ�����ͼƬ��
	����ͼƬִ�г��ֱ��Ժ��ֱ�Ӹ���ͼƬ��psnr��ssim��qssim��rmse��Ϣ��
	����˵����
	kmeans_Num����ʼkmeans����
	Gbeta: gate������beta��ȡֵ������1-10֮�䡣
	ExpertNum��ÿ��moe �����õ�experts������
	ERelation��experts֮��Ĺ�ϵ��ֻ����Compete����Coorperate��
	���÷�ʽ������
	SR_moeTest_ENumFixed(128, 3, 8,'Coorperate');
------------------------------------------------------------------------------	
3�� SR_moeTrain_ENumFlexible.m
	---------------------------
    SR_moeTrain_ENumFlexible(kmeans_Num,Gbeta, maxIt)
	���������Experts�������Ƕ�̬�ģ������и���Input�ı�����������Experts���������������������ʱ��������ʵ�顣
	����˵����
	kmeans_Num����ʼkmeans����
	Gbeta: gate������beta��ȡֵ������1-10֮��
	maxIt��ѵ��moe����������������EM��������
	���÷�ʽ������
	SR_moeTrain_ENumFlexible(128, 3, 25);
-------------------------------------------------------------------------------	
4�� SR_moeTest_ENumFlexible.m
	---------------------------
	SR_moeTest_ENumFlexible(kmeans_Num, beta)
	���������Experts�������Ƕ�̬��moe��Ӧ�Ĳ���
	���÷�ʽ������
	SR_moeTest_ENumFlexible(128, 3);
-------------------------------------------------------------------------------	
5�� SR_moeTrain_single.m
	---------------------------
	����ֻѵ��һ��moe
	�������������ļ��м䣺
	moe = moeSimpleCreate('NumExperts', NumOfExperts , 'MaxIt', maxIt, 'EType', 'linear', 'ENbf', 0.1, 'EKernel', 'linear', 'EKParam', 0.5, ...
        'GType', 'mlr',  'GERelation', ERelation,  'GNbf', 0.1,'GBeta',Gbeta, 'GLearningRate', LearningRate, 'GKernel', 'linear', 'GKParam', 0.5);
-------------------------------------------------------------------------------	
6�� moeSimple.m ****************************************
	---------------------------
	����ļ�����toy data���Դ�����ļ����������������ݷֲ�����ѡ��sin��ʽ�����֣�֮�֡������Ƕ�ά�ģ����Կ�����ʾ������
	�����Ҳ�ȷ���ǲ��Ƕ��ڶ�ά���ֵĽ��Ҳ����ڸ�άͬ��

7�� Lib�ļ��н���
	���߸��ļ��У�ÿ���ļ�������һ���Ĺ��ܡ������������Ҳ����ĺ��������������
	
	
	