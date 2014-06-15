function Variances = moeExpertsVariances(Target, moeModel)
%% Compute the variance of expert
N = length(Target);
Num = moeModel.NumExperts;
Threshold = 0.1/Num;

ExpertMeans = moeModel.Experts.Means;
GatingsPosteriors = zeros(N,Num);
for i = 1:Num
    index = find(moeModel.Gatings.Posteriors(:,i) > Threshold);
    GatingsPosteriors(index,i) = moeModel.Gatings.Posteriors(index,i);
end

sumQ = sum(GatingsPosteriors) ; 
d2 = size(Target,2);
if d2 == 1
    numV = sum(GatingsPosteriors.*((repmat(Target,1,size(ExpertMeans,2)) - ExpertMeans).^2)) ; 
else
    for i = 1:Num
        numV(:,i) = sum(repmat(GatingsPosteriors(:,i),1,d2).*(Target - ExpertMeans(:,:,i)).^2)';
    end;
end
Variances = (numV./(repmat(sumQ,d2,1) + eps));