function GatingsPosterior = moeModelGatingsPosterior(Target, moeModel)
%% Compute the posterior probability. 
GatingsOutputs = moeModelGatingsOutputsNorm(moeModel);
Means = moeModel.Experts.Means;
Variances = moeModel.Experts.Variances;
GatingsPosterior = zeros(size(GatingsOutputs));

if size(Target,2) == 1
    for i = 1:moeModel.NumExperts
        GatingsPosterior(:,i) = GatingsOutputs(:,i).*onedimgauss(Means(:,i) - Target, Variances(i));
    end
else
    for i = 1:moeModel.NumExperts
        for j = 1:size(Target,2)
            GatingsPosterior(:,i) = GatingsOutputs(:,i).*onedimgauss(Means(:,j,i) - Target(:,j), Variances(j,i)) ;
        end
    end
end
GatingsPosterior(isnan(GatingsPosterior)) = eps;
SumGatingsPosterior = sum(GatingsPosterior,2) ;
GatingsPosterior = GatingsPosterior./repmat(SumGatingsPosterior,1,size(GatingsPosterior,2)) ;
for i = 1:moeModel.NumExperts
    index = find(GatingsPosterior(:,i) < 1e-10);
    GatingsPosterior(index,i) = 0;
end