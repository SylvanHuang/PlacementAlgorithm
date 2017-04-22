%% 基础设施拓扑结构图
function Node_Location
Ns = 7; 

%% Create Ns Nodes and Return its Location in a square
% % Random Creation
% NodeLocation = 100*rand([Ns,2]);
% NodeLocation = sortrows(NodeLocation,1);

% Given substrate topology
NodeLocation = [10 50; 15 25; 32 80; 45 20; 55 15; 70 60; 90 45];

%% NodeRelation Based on Documents
NodeRelation = zeros(Ns);
% i-th node is connected to j-th node

RelationVector = [1 3; 1 2; 2 3; 3 4; 2 4; 3 5; 3 6; 5 6; 5 7; 6 7; 4 5];

%% 计算节点间的最短路径
ShortestDistMatrix = 10^5*(ones(Ns)-eye(Ns));
K = length(RelationVector);
Tmp  = 3+7*rand(1,length(RelationVector));
% Tmp = randi([3 10],1,K)
for i = 1:K
    x = RelationVector(i,1);
    y = RelationVector(i,2);
    ShortestDistMatrix(x,y) = Tmp(i);
    ShortestDistMatrix(y,x) = Tmp(i);
end
for i = 1:Ns
    for j = 1:Ns
        for k = 1:Ns
            Total_Value = ShortestDistMatrix(i,k) + ShortestDistMatrix(k,j);
            if  Total_Value < ShortestDistMatrix(i,j)
                ShortestDistMatrix(i,j) = Total_Value;
                ShortestDistMatrix(j,i) = Total_Value;
            end
        end
    end
end

eval(['save .\DataContainer\NodeTopology.mat NodeLocation RelationVector ShortestDistMatrix'])