clc;
clear;
close all;
load SData;
[Input, Target] = MoE_SyntheticData();
% Input = 0.01*pi:0.01*pi:5*pi;
% 
% Input = Input';
% Target = Target';
% 
% N = size(Input,1);
% Target = sin(Input)+rand(1,N)';
% %Input = [Input Input];
TestInput = Input;
TestTarget = Target;

folder_project = pwd;
folder_lib = fullfile(folder_project,'Lib');
addpath(genpath(folder_lib)); 

numOfExperts = 2;
moeModel = moeSimpleCreate('NumExperts', numOfExperts , 'MaxIt', 50, 'EType', 'linear', 'ENbf', 0.1, 'EKernel', 'linear', 'EKParam', 0.5, ...
    'GType', 'metric',  'GERelation', 'Compete', 'GBeta',7, 'GNbf', 0.1,  'GLearningRate',0.001, 'GKernel', 'linear', 'GKParam', 0.5);
moeModel = moeSimpleInit(moeModel, Input, Target, Target, Input);
tic;
%% Now run the EM Algorithm 
moeModel = moeSimpleTrain(moeModel, Target, Target) ;  
toc;

%% Display results 
NumInput = size(Input,1); 
DataPointColors = {'r.','g.','b.','k.','m.','c','y'} ; 
LineColors = {'r-','g-','b-','k-','m-','c','y'} ; 

%%------------------------------------------------------------------
%Clustering of the training data using Posterior and corresponding experts
h1 = figure ; 
hold on ; 
for i =1:NumInput     
    [MaxVal MaxI] = max(moeModel.Gatings.Posteriors(i,:));     
    plot(Input(i,1),Target(i,1),DataPointColors{MaxI});     
end

for i = 1:moeModel.NumExperts   
   plot(Input,moeModel.Experts.Means(:,i),LineColors{i});  
end
hold off ;

h3 = figure ; 
hold on ; 
for i =1:NumInput     
    [MaxVal MaxI] = max(moeModel.Gatings.Outputs(i,:));     
    plot(Input(i,1), Target(i,1), DataPointColors{MaxI});     
end
%moeModel.Experts.Means = BMEExpertsMeans([ones(size(GateInput,1),1) K],moeModel);
moeModel.Gatings.Outputs = moeModelGatingsOutputsNorm(moeModel);
for i = 1:NumInput
   [MaxVal MaxI] = max(moeModel.Gatings.Outputs(i,:)); 
   if strcmpi(moeModel.Gatings.ERelation,'Compete')
          plot(Input(i,1),moeModel.Experts.Means(i,MaxI),LineColors{MaxI}); 
            %disp(['moeModel reduece to iter ' num2str(MinErrorLoc) ',Training Error:    ' num2str(moeModel.Test.PredicteMAECompete(MinErrorLoc))]);
    elseif strcmpi(moeModel.Gatings.ERelation,'Coorperate')
          %disp(['moeModel reduece to iter ' num2str(MinErrorLoc) ',Training Error:    ' num2str(moeModel.Test.PredicteMAECoorper(MinErrorLoc))]);
          plot(Input(i,1), sum(moeModel.Experts.Means(i,:).*moeModel.Gatings.Outputs(i,:)), LineColors{MaxI});
   end
end
hold off ;

%%------------------------------------------------------------------
%Gate Distribution 
    
h2 = figure ; 
hold on ; 
for i =1:NumInput     
    [MaxVal MaxI] = max(moeModel.Gatings.Outputs(i,:));     
    plot(Input(i,1), Target(i,1), DataPointColors{MaxI});     
end

MinInput = min(Input(:,1)) ; 
MaxInput = max(Input(:,1)) ; 
NumPts = 500 ; 
GateInput = MinInput:(MaxInput - MinInput)/(NumPts - 1):MaxInput ; 
GateInput = GateInput';
%GateInput = [GateInput GateInput];
if strcmpi(moeModel.Gatings.Kernel, 'linear')
    if strcmpi(moeModel.Gatings.Type, 'metric')
        K = GateInput;
    elseif strcmpi(moeModel.Gatings.Type, 'mlr')
        K = [ones(size(GateInput,1),1) GateInput];
    end
    
else
    K = EvalKernel(GateInput, Input, moeModel.Gatings.Kernel, moeModel.Gatings.KParam);
end
%GateInput2 = [ones(size(GateInput,1),1) K];
GateInput2 = K;
gatingsOutputs = zeros(size(GateInput2,1),size(moeModel.Gatings.Weights,2));
if (strcmpi(moeModel.Gatings.Type,'metric'))
    for i = 1:moeModel.NumExperts   
         gatingsOutputs(:,i) = exp(-moeModel.Gatings.Beta*sum((GateInput2-repmat(moeModel.Gatings.Weights(:,i),1,NumPts)').^2,2));
    end
    moeModel.Gatings.Outputs  =  gatingsOutputs;
else
    moeModel.Gatings.Outputs = exp(GateInput2*moeModel.Gatings.Weights);
end
moeModel.Gatings.Outputs = moeModelGatingsOutputsNorm(moeModel);
for i = 1:moeModel.NumExperts   
   plot(GateInput, moeModel.Gatings.Outputs(:,i), LineColors{i});  
end
hold off ;
