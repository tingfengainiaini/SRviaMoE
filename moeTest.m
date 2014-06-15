function [MAE, PMAE, PredicteMAE,PredicteMAE2, Predictions, MPredictions] = moeTest(EInput, GInput, Target, moeModel)

%% Test
N = size(EInput,1);
Num = moeModel.Test.NumExperts;
ExpertsMeans = moeExpertsMeans(EInput,moeModel);
% GatingsOutputs = exp(GInput*moeModel.Gatings.Weights);
GatingsOutputs = moeGatingsOutputs(GInput, moeModel);
SumGatingsOutput = sum(GatingsOutputs,2) ;
GatingOutputsNorm = GatingsOutputs./repmat(SumGatingsOutput,1,size(GatingsOutputs,2)) ;

[values, index] = sort(GatingsOutputs, 2, 'descend');

MAE = zeros(1,Num);
PMAE = zeros(1,Num);

Results1 = inf*ones(N, 1);
Results2 = zeros(size(Target));
Results3 = zeros(size(Target,1),1);
Results4 = zeros(size(Target,1),1);
Predictions = zeros(N, Num);
if size(Target,2) == 1
    MPredictions = zeros(N,Num);
else
    MPredictions = zeros(N,size(Target,2),Num);
end

for k = 1:N
    if size(Target,2) == 1
            Results3(k) = abs(Target(k) - ExpertsMeans(k,index(k,1)));
            Results4(k) = abs(Target(k) - sum(GatingOutputsNorm(k,:).*ExpertsMeans(k,:),2));
    else
            Results3(k) = sum(abs(Target(k,:) - ExpertsMeans(k,:,index(k,1))));
            sumOutputs = zeros(size(Target));
            expertOutputs = reshape(ExpertsMeans(k,:,:),size(ExpertsMeans,2), size(ExpertsMeans,3));
            sumOutputs(k,:) = sum(repmat(GatingOutputsNorm(k,:),size(Target,2),1).*expertOutputs, 2)';
            Results4(k) = sum(abs(Target(k,:) - sumOutputs(k,:)));
    end
end %for

PredicteMAE = mean(Results3);
PredicteMAE2 = mean(Results4);
for i = 1:Num
    for j = 1:N
        if size(Target,2) == 1
            Results1(j) = min(Results1(j), abs(Target(j) - ExpertsMeans(j,index(j,i))));
            aaa = GatingsOutputs(j,:);
            tindex = index(j, 1:i);
            aaa = aaa/sum(aaa(tindex));
            Results2(j) = ExpertsMeans(j,tindex)*aaa(tindex)';
        else
            Results1(j) = min(Results1(j), mean(abs(Target(j,:) - ExpertsMeans(j,:,index(j,i)))));
            aaa = GatingsOutputs(j,:);
            tindex = index(j, 1:i);
            aaa = aaa/sum(aaa(tindex));
            for t = 1:i
                Results2(j,:) = Results2(j,:) + ExpertsMeans(j,:,tindex(i))*aaa(tindex(i));
            end
        end
    end
    MAE(1,i) = mean(Results1);
    PMAE(1,i) = mean(abs(Results2(:) - Target(:)));
    Predictions(:,i) = Results1;
    if size(Target,2) == 1
        MPredictions(:,i) = Results2;
    else
        MPredictions(:,:,i) = Results2;
    end
end