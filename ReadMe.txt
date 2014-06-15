实现过程跟word文档是一样的。

文件说明：
---------------------------------------------------------------
训练所需数据：
----------
训练的前提是有Cluster数据和MappingData文件夹。
Cluster数据直接来自于杨明轩的代码跑出来的。
MappingData数据得来的方法是：
将Yang的代码的前几步：
PP1_GenerateFileNameList.m
PP2_ExtractPosition.m
PP3_RandomSelect.m
PP4_ExtractFeatureForClustering.m
PP5_TrainClusterCenter.m
PP6_LabelFeature.m
PP7_mine_TrainingMappingFuncBME.m
不管kmean多少类，这里的前四步都是一样。所以只要前四步跑好了，就只用跑后面的就可以了。最慢的一步是LabelFeature。

---------------------------------------------------------------------------
1， SR_moeTrain_ENumFixed.m
	------------------------
	SR_moeTrain_ENumFixed(kmeans_Num,Gbeta, maxIt, ExpertNum, LearningRate, ERelation)
	这个函数是训练moe的。
	参数说明：
	kmeans_Num：初始kmeans数量
	Gbeta: gate函数中beta的取值，建议1-10之间。
	maxIt：训练moe的最大迭代次数，即EM的最大次数
	ExpertNum：每个moe 下设置的experts的数量
	LearningRate：M步中gate的初始学习步长的设置。
	ERelation：experts之间的关系，只能是Compete或者Coorperate，
	    Compete是指最后的输出使用GatingOuputs最大的那个Expert的输出作为最终输出
		Coorperate是指最后的输出使用Experts的输出按GatingOutputs 加权输出。
		（Coorperate写的还不是很完善，尽量用Compete）
	调用方式举例：
	SR_moeTrain_ENumFixed(64, 3, 25, 8, 0.002, 'Coorperate'); 
-----------------------------------------------------------------------------
2， SR_moeTest_ENumFixed.m
	-------------------------
	SR_moeTest_ENumFixed(kmeans_Num, Gbeta, ExpertsNum, ERelation)
	这个函数是测试的，函数中所用的图片只有四张，也就是Dataset\benchmark\input文件夹下的四张图片。
	这里图片执行超分辨以后就直接给出图片的psnr，ssim，qssim，rmse信息。
	参数说明：
	kmeans_Num：初始kmeans数量
	Gbeta: gate函数中beta的取值，建议1-10之间。
	ExpertNum：每个moe 下设置的experts的数量
	ERelation：experts之间的关系，只能是Compete或者Coorperate，
	调用方式举例：
	SR_moeTest_ENumFixed(128, 3, 8,'Coorperate');
------------------------------------------------------------------------------	
3， SR_moeTrain_ENumFlexible.m
	---------------------------
    SR_moeTrain_ENumFlexible(kmeans_Num,Gbeta, maxIt)
	这个函数是Experts的数量是动态的，函数中根据Input的变量数量调整Experts数量。这个函数可以最后的时候用来做实验。
	参数说明：
	kmeans_Num：初始kmeans数量
	Gbeta: gate函数中beta的取值，建议1-10之间
	maxIt：训练moe的最大迭代次数，即EM的最大次数
	调用方式举例：
	SR_moeTrain_ENumFlexible(128, 3, 25);
-------------------------------------------------------------------------------	
4， SR_moeTest_ENumFlexible.m
	---------------------------
	SR_moeTest_ENumFlexible(kmeans_Num, beta)
	这个函数是Experts的数量是动态的moe对应的测试
	调用方式举例：
	SR_moeTest_ENumFlexible(128, 3);
-------------------------------------------------------------------------------	
5， SR_moeTrain_single.m
	---------------------------
	整个只训练一个moe
	参数的设置在文件中间：
	moe = moeSimpleCreate('NumExperts', NumOfExperts , 'MaxIt', maxIt, 'EType', 'linear', 'ENbf', 0.1, 'EKernel', 'linear', 'EKParam', 0.5, ...
        'GType', 'mlr',  'GERelation', ERelation,  'GNbf', 0.1,'GBeta',Gbeta, 'GLearningRate', LearningRate, 'GKernel', 'linear', 'GKParam', 0.5);
-------------------------------------------------------------------------------	
6， moeSimple.m ****************************************
	---------------------------
	这个文件是用toy data测试代码的文件。里面有三种数据分布可以选择，sin形式，八字，之字。而且是二维的，所以可以显示出来。
	但是我不确定是不是对于二维出现的结果也会对于高维同理。

7， Lib文件夹介绍
	共七个文件夹，每个文件夹下有一定的功能。凡是在外面找不到的函数基本都在这里。
	
	
	