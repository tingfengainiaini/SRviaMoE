function  moeModel  = moeSimpleCreate( varargin )
%% default field
moeModel.NumExperts = 10;
moeModel.MaxIt = 10;
moeModel.MinLogLikeChange = 1e-3;
moeModel.Experts.Type = 'linear';
moeModel.Experts.Nbf = 1;
moeModel.Experts.Kernel = 'linear';
moeModel.Experts.KParam = [];
moeModel.Gatings.Type = 'mlr';
moeModel.Gatings.Nbf = 1;
moeModel.Gatings.Kernel = 'linear';
moeModel.Gatings.KParam = [];

%% set field accroding to data user provides
for i = 1:length(varargin)/2
    Name = varargin{2*(i-1)+1};
    Value = varargin{2*i};
    switch Name
        case {'NumExperts', 'MaxIt'}
            moeModel = setfield(moeModel, Name, Value);
        case {'EType', 'ENbf','EUseTol','EUseW_0', 'Elamda', 'EWInit','EKernel', 'EKParam'}
            moeModel.Experts = setfield(moeModel.Experts, Name(2:end), Value);
        case {'GType', 'GERelation', 'GBeta', 'GUseMetric','GLearningRate', 'GNbf', 'GKernel', 'GKParam'}
            moeModel.Gatings = setfield(moeModel.Gatings, Name(2:end), Value);
        otherwise
            disp( ['unknown name: ' Name]);
    end
end

