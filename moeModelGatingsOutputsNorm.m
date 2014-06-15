function GatingOutputs = moeModelGatingsOutputsNorm(moeModel)
%% Normalize the output of gating network
GatingsOutputs = moeModel.Gatings.Outputs;
SumGatingsOutput = sum(GatingsOutputs,2) ;
GatingOutputs = GatingsOutputs./repmat(SumGatingsOutput,1,size(GatingsOutputs,2)) ;