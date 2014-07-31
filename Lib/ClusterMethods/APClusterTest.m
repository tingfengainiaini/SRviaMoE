close all;
clc;

% Input = 0.01*pi:0.01*pi:5*pi;
% Target = sin(Input)+rand(1,500);
[Input, Target] = MoE_SyntheticData();
% Input = Input';
% Target = Target';
N=size(Input,1);
x = [Input Target];
 M=N*N-N; s=zeros(M,3); j=1;
for i=1:N
  for k=[1:i-1,i+1:N]
    s(j,1)=i; s(j,2)=k; s(j,3)=-sum((x(i,:)-x(k,:)).^2);
    j=j+1;
  end;
end;
p=min(s(:,3)); 
[idx,netsim,dpsim,expref]=apcluster(s,p,'plot');
fprintf('Number of clusters: %d\n',length(unique(idx)));
fprintf('Fitness (net similarity): %g\n',netsim);
figure; 
for i=unique(idx)'
      ii=find(idx==i); 
      h=plot(x(ii,1),x(ii,2),'o'); 
      hold on;
      col=rand(1,3); 
      set(h,'Color',col,'MarkerFaceColor',col);
      xi1=x(i,1)*ones(size(ii)); 
      xi2=x(i,2)*ones(size(ii)); 
      line([x(ii,1),xi1]',[x(ii,2),xi2]','Color',col);
end;
clusterNum = 7;
[IDInput centers] = kMeansCluster(x(:,1),x(:,2),clusterNum);
DataPointColors = {'ro','go','bo','ko','mo','co','yo'} ; 
figure;
hold on;
 for i = 1:clusterNum
    Indices = find(IDInput == i) ; 
    plot(x(Indices,1),x(Indices,2),DataPointColors{i});  
 end
 hold off;
