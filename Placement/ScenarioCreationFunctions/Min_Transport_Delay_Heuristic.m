%% 最小化传输时延的启发式算法
function [x_Deploy] = Min_Transport_Delay_Heuristic(PhyPara, LogicPara,ShortestDistMatrix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%% 调试用 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clc
% clear all
% eval('load .\DataContainer\InputPara.mat');
% eval('load .\DataContainer\NodeTopology.mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Ns = PhyPara.Ns;
Nf = LogicPara.Nf;
%% 启发式算法主体
%   确定从起点到终点的最短路径经过节点 假定第1个是起点，第Ns个是终点
NodeSequency = [1,PhyPara.Ns];
Node2Select = 2:PhyPara.Ns-1;
Time_tmp = [];
NodeIndex = [];
for i = 1:length(Node2Select)
    k = Node2Select(i);
    if ShortestDistMatrix(1,k)+ShortestDistMatrix(k,PhyPara.Ns) == ShortestDistMatrix(1,PhyPara.Ns)
        Time_tmp = [Time_tmp ShortestDistMatrix(1,k)];
        NodeIndex = [NodeIndex, k];
    end
end
clear Node2Select;

[~,Index] = sort(Time_tmp);
% 确定最短路径上的物理节点顺序
for k = Index
    NodeSequency = [NodeSequency(1:end-1),NodeIndex(k),NodeSequency(end)];
end

% 最短路径上节点和节点间的最短路径
TraversDistance = zeros(1,length(NodeSequency)-1); 
for k = 1:length(NodeSequency)-1
    TraversDistance(k) = ShortestDistMatrix(NodeSequency(k),NodeSequency(k+1)); 
end

%% 算法需要用到的资源
NodeSumCapacity = PhyPara.vCPUNumMax + PhyPara.FPGA_Num; % 节点内异构资源总和
% 根据流访问顺序，从先往后排序VNF
VNFSequency = unique(LogicPara.FlowSequency,'stable');
% NodeSequency
% TraversDistance
% LogicPara.FlowNum

%% 算法思想和判断原则
% 1. 优先选出VNF之间流量较大的节点，将其合并后放置至选定的节点
% 2. 根据流抵达VNF的顺序，摆放之后需要摆放VNF的顺序，
%    例如，流先抵达的节点应尽量部署靠起点，反之靠终点
x_Deploy = zeros(Nf,2*Ns);
VNF_Pool = 1:Nf; % 需要部署的节点
VNF_Placed = [];
while ~isempty(VNF_Pool)
    % 寻找流最多的两个节点
    [~,Ind] = max(LogicPara.FlowNum(:)); 
    VNF_A = rem(Ind,Nf);
    VNF_B = ceil(Ind/Nf); % 优先合并NodeA和NodeB
    if VNF_A == 0
        VNF_A = Nf;
    end
    if VNF_B == 0
        VNF_B = Nf;
    end
    % 检测NodeA 或者 NodeB 是否已经被部署
    if ~sum(VNF_A==VNF_Placed) && ~sum(VNF_B==VNF_Placed) 
        %% 如果一个都没有部署
        disp(['同时部署VNF ',num2str(VNF_A),' 和VNF ',num2str(VNF_B)]);
        if isempty(VNF_Placed)
            % 选择最短路径上，容量最大的节点
            [~, ind_tmp] = sort(NodeSumCapacity(NodeSequency),'descend');
            Ordered_Node4Placement = NodeSequency(ind_tmp);
            % 根据排序好的Node candidate，逐次选择是否可以部署
            % 部署VNF_A
            [Node2Place, PlaceSuccessful, PhyPara] = ...
                How2Place(LogicPara, PhyPara, Ordered_Node4Placement, VNF_A);
            switch PlaceSuccessful
                case 0
                    error('部署不成功')
                case 1
                    x_Deploy(VNF_A, Node2Place) = 1;
                    VNF_Pool(find(VNF_Pool == VNF_A)) = []; 
                    VNF_Placed = [VNF_Placed; VNF_A];
                otherwise
                    error('错误参数')
            end
            
            % 部署VNF_B
            [Node2Place, PlaceSuccessful, PhyPara] = ...
                How2Place(LogicPara, PhyPara, Ordered_Node4Placement, VNF_B);
            switch PlaceSuccessful
                case 0
                    error('部署不成功')
                case 1
                    x_Deploy(VNF_B, Node2Place) = 1;
                    VNF_Pool(find(VNF_Pool == VNF_B)) = []; 
                    VNF_Placed = [VNF_Placed; VNF_B];
                otherwise
                    error('错误参数')
            end
            LogicPara.FlowNum(VNF_A,VNF_B) = 0;
            LogicPara.FlowNum(VNF_B,VNF_A) = 0;
                
        else
            % 如果之前有VNF已经部署了
            error('这部分还没有完成')
        end
    
    elseif sum(VNF_A==VNF_Placed) ~= sum(VNF_B==VNF_Placed) 
        %% 如果只部署了其中一个
        if sum(VNF_B==VNF_Placed) == 1
            disp(['VNF ',num2str(VNF_B),'已经部署，只需要部署VNF', num2str(VNF_A)]);
            VNF_ind = VNF_A;
            VNF_Candidate = VNF_B;
        else
            disp(['VNF ',num2str(VNF_A),'已经部署，只需要部署VNF', num2str(VNF_B)]);
            VNF_ind = VNF_B;
            VNF_Candidate = VNF_A;
        end
        % 优先选择另一个VNF的节点，然后根据VNF流先后顺序选择靠左还是靠右的VNF
        % 获得已经部署的节点
        Node_CandidateVNF_Placed = mod(find(x_Deploy(VNF_Candidate,:)), PhyPara.Ns);
        % 根据与该节点的距离排序剩下节点。
        [Distance, Node_Ind_tmp] = sort(ShortestDistMatrix(Node_CandidateVNF_Placed,:));
        % Note: 这里仅仅根据VNF流的顺序排列node顺序，不计较是否在最短路径上
        if VNF_ind < VNF_Candidate
            Ordered_Node4Placement = [Node_Ind_tmp(1),...
                Node_Ind_tmp(find(Node_Ind_tmp < Node_Ind_tmp(1))), ...
                Node_Ind_tmp(find(Node_Ind_tmp > Node_Ind_tmp(1)))];
        else
            Ordered_Node4Placement = [Node_Ind_tmp(1),...
                Node_Ind_tmp(find(Node_Ind_tmp > Node_Ind_tmp(1))), ...
                Node_Ind_tmp(find(Node_Ind_tmp < Node_Ind_tmp(1)))];
        end
        % 根据排序的节点部署
        [Node2Place, PlaceSuccessful, PhyPara] = ...
                How2Place(LogicPara, PhyPara, Ordered_Node4Placement, VNF_ind);
            switch PlaceSuccessful
                case 0
                    error('部署不成功')
                case 1
                    x_Deploy(VNF_ind, Node2Place) = 1;
                    VNF_Pool(find(VNF_Pool == VNF_ind)) = []; 
                    VNF_Placed = [VNF_Placed; VNF_ind];
                otherwise
                    error('错误参数')
            end
            LogicPara.FlowNum(VNF_ind,VNF_Candidate) = 0;
            LogicPara.FlowNum(VNF_Candidate,VNF_ind) = 0;
    else
        LogicPara.FlowNum(VNF_A,VNF_B) = 0;
        LogicPara.FlowNum(VNF_B,VNF_A) = 0;
    end
end

