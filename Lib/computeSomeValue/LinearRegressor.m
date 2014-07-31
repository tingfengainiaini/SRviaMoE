%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors: Liefeng Bo, Cristian Sminchisescu                         %                                         
% Date: 01/12/2010                                                   %
%                                                                    % 
% Copyright (c) 2010  Liefeng Bo - All rights reserved               %
%                                                                    %
% This software is free for non-commercial usage only. It must       %
% not be distributed without prior permission of the author.         %
% The author is not responsible for implications from the            %
% use of this software. You can run it at your own risk.             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Weight = LinearRegressor(Input, Target, Lambda)

[N, d] = size(Input);
BiasVec = ones(N,1);
Hessian = [BiasVec'*BiasVec BiasVec'*Input; Input'*BiasVec Input'*Input];
InputTarget = [sum(Target,1); Input'*Target];

if nargin < 3
    Lambda = 1e-8*min(diag(Hessian));
end
if det(Hessian + Lambda*eye(d+1)) < Lambda
    Hessian = Hessian + eps;
end
Weight = (Hessian + Lambda*eye(d+1))\InputTarget;