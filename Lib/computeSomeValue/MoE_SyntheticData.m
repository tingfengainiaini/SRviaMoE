% Generate data for mixture of experts classification and regression tests
% data can be learned with a 2 logistic discrimination expert MoE 

% classification dataset
function [x2 r2] = MoE_SyntheticData()
    r = zeros(1000,1);
    x = rand(1000,2);
    r((x(:,1) + x(:,2) < 1) & (x(:,2) < 0.5)) = 1;
    r((x(:,1) + x(:,2) < 1) & (x(:,2) >= 0.5)) = 2;
    r((x(:,1) + x(:,2) >= 1) & (x(:,1) >= 0.5)) = 2;
    r((x(:,1) + x(:,2) >= 1) & (x(:,1) < 0.5)) = 1;
    r = full(ind2vec(r'))';
    tx = x(1:600,:);
    vx = x(601:1000,:);
    tr = r(1:600,:);
    vr = r(601:1000,:);
    % plot(tx(tr==1,1), tx(tr==1,2),'ob')
    % hold on
    % plot(tx(tr==2,1), tx(tr==2,2),'xr')
    % 
    % plot(vx(vr(:,1)==1,1), vx(vr(:,1)==1,2),'ob')
    % hold on
    % plot(vx(vr(:,2)==1,1), vx(vr(:,2)==1,2),'xr')

    % regression dataset
    x2 = rand(500,1);
    r2 = zeros(500,1);
    r2(x2<0.5,:) = x2(x2<0.5) .* 2 + ( randn(size(x2(x2<0.5))) .* 0.1 );
    r2(x2>=0.5,:) = (2 - (x2(x2>=0.5) .* 2)) + ( randn(size(x2(x2>=0.5))) * 0.1 );
    tx2 = x2(1:300,:);
    vx2 = x2(301:500,:);
    tr2 = r2(1:300,:);
    vr2 = r2(301:500,:);

   % plot(x2, r2, 'ob');
    
