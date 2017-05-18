%% ��С������ʱ�ӵ�����ʽ�㷨
function [x_Deploy] = Min_Transport_Delay_Heuristic(PhyPara, LogicPara,ShortestDistMatrix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%% ������ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clc
% clear all
% eval('load .\DataContainer\InputPara.mat');
% eval('load .\DataContainer\NodeTopology.mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Ns = PhyPara.Ns;
Nf = LogicPara.Nf;
%% ����ʽ�㷨����
%   ȷ������㵽�յ�����·�������ڵ� �ٶ���1������㣬��Ns�����յ�
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
% ȷ�����·���ϵ�����ڵ�˳��
for k = Index
    NodeSequency = [NodeSequency(1:end-1),NodeIndex(k),NodeSequency(end)];
end

% ���·���Ͻڵ�ͽڵ������·��
TraversDistance = zeros(1,length(NodeSequency)-1); 
for k = 1:length(NodeSequency)-1
    TraversDistance(k) = ShortestDistMatrix(NodeSequency(k),NodeSequency(k+1)); 
end

%% �㷨��Ҫ�õ�����Դ
NodeSumCapacity = PhyPara.vCPUNumMax + PhyPara.FPGA_Num; % �ڵ����칹��Դ�ܺ�
% ����������˳�򣬴�����������VNF
VNFSequency = unique(LogicPara.FlowSequency,'stable');
% NodeSequency
% TraversDistance
% LogicPara.FlowNum

%% �㷨˼����ж�ԭ��
% 1. ����ѡ��VNF֮�������ϴ�Ľڵ㣬����ϲ��������ѡ���Ľڵ�
% 2. �������ִ�VNF��˳�򣬰ڷ�֮����Ҫ�ڷ�VNF��˳��
%    ���磬���ȵִ�Ľڵ�Ӧ����������㣬��֮���յ�
x_Deploy = zeros(Nf,2*Ns);
VNF_Pool = 1:Nf; % ��Ҫ����Ľڵ�
VNF_Placed = [];
while ~isempty(VNF_Pool)
    % Ѱ�������������ڵ�
    [~,Ind] = max(LogicPara.FlowNum(:)); 
    VNF_A = rem(Ind,Nf);
    VNF_B = ceil(Ind/Nf); % ���Ⱥϲ�NodeA��NodeB
    if VNF_A == 0
        VNF_A = Nf;
    end
    if VNF_B == 0
        VNF_B = Nf;
    end
    % ���NodeA ���� NodeB �Ƿ��Ѿ�������
    if ~sum(VNF_A==VNF_Placed) && ~sum(VNF_B==VNF_Placed) 
        %% ���һ����û�в���
        disp(['ͬʱ����VNF ',num2str(VNF_A),' ��VNF ',num2str(VNF_B)]);
        if isempty(VNF_Placed)
            % ѡ�����·���ϣ��������Ľڵ�
            [~, ind_tmp] = sort(NodeSumCapacity(NodeSequency),'descend');
            Ordered_Node4Placement = NodeSequency(ind_tmp);
            % ��������õ�Node candidate�����ѡ���Ƿ���Բ���
            % ����VNF_A
            [Node2Place, PlaceSuccessful, PhyPara] = ...
                How2Place(LogicPara, PhyPara, Ordered_Node4Placement, VNF_A);
            switch PlaceSuccessful
                case 0
                    error('���𲻳ɹ�')
                case 1
                    x_Deploy(VNF_A, Node2Place) = 1;
                    VNF_Pool(find(VNF_Pool == VNF_A)) = []; 
                    VNF_Placed = [VNF_Placed; VNF_A];
                otherwise
                    error('�������')
            end
            
            % ����VNF_B
            [Node2Place, PlaceSuccessful, PhyPara] = ...
                How2Place(LogicPara, PhyPara, Ordered_Node4Placement, VNF_B);
            switch PlaceSuccessful
                case 0
                    error('���𲻳ɹ�')
                case 1
                    x_Deploy(VNF_B, Node2Place) = 1;
                    VNF_Pool(find(VNF_Pool == VNF_B)) = []; 
                    VNF_Placed = [VNF_Placed; VNF_B];
                otherwise
                    error('�������')
            end
            LogicPara.FlowNum(VNF_A,VNF_B) = 0;
            LogicPara.FlowNum(VNF_B,VNF_A) = 0;
                
        else
            % ���֮ǰ��VNF�Ѿ�������
            error('�ⲿ�ֻ�û�����')
        end
    
    elseif sum(VNF_A==VNF_Placed) ~= sum(VNF_B==VNF_Placed) 
        %% ���ֻ����������һ��
        if sum(VNF_B==VNF_Placed) == 1
            disp(['VNF ',num2str(VNF_B),'�Ѿ�����ֻ��Ҫ����VNF', num2str(VNF_A)]);
            VNF_ind = VNF_A;
            VNF_Candidate = VNF_B;
        else
            disp(['VNF ',num2str(VNF_A),'�Ѿ�����ֻ��Ҫ����VNF', num2str(VNF_B)]);
            VNF_ind = VNF_B;
            VNF_Candidate = VNF_A;
        end
        % ����ѡ����һ��VNF�Ľڵ㣬Ȼ�����VNF���Ⱥ�˳��ѡ�����ǿ��ҵ�VNF
        % ����Ѿ�����Ľڵ�
        Node_CandidateVNF_Placed = mod(find(x_Deploy(VNF_Candidate,:)), PhyPara.Ns);
        % ������ýڵ�ľ�������ʣ�½ڵ㡣
        [Distance, Node_Ind_tmp] = sort(ShortestDistMatrix(Node_CandidateVNF_Placed,:));
        % Note: �����������VNF����˳������node˳�򣬲��ƽ��Ƿ������·����
        if VNF_ind < VNF_Candidate
            Ordered_Node4Placement = [Node_Ind_tmp(1),...
                Node_Ind_tmp(find(Node_Ind_tmp < Node_Ind_tmp(1))), ...
                Node_Ind_tmp(find(Node_Ind_tmp > Node_Ind_tmp(1)))];
        else
            Ordered_Node4Placement = [Node_Ind_tmp(1),...
                Node_Ind_tmp(find(Node_Ind_tmp > Node_Ind_tmp(1))), ...
                Node_Ind_tmp(find(Node_Ind_tmp < Node_Ind_tmp(1)))];
        end
        % ��������Ľڵ㲿��
        [Node2Place, PlaceSuccessful, PhyPara] = ...
                How2Place(LogicPara, PhyPara, Ordered_Node4Placement, VNF_ind);
            switch PlaceSuccessful
                case 0
                    error('���𲻳ɹ�')
                case 1
                    x_Deploy(VNF_ind, Node2Place) = 1;
                    VNF_Pool(find(VNF_Pool == VNF_ind)) = []; 
                    VNF_Placed = [VNF_Placed; VNF_ind];
                otherwise
                    error('�������')
            end
            LogicPara.FlowNum(VNF_ind,VNF_Candidate) = 0;
            LogicPara.FlowNum(VNF_Candidate,VNF_ind) = 0;
    else
        LogicPara.FlowNum(VNF_A,VNF_B) = 0;
        LogicPara.FlowNum(VNF_B,VNF_A) = 0;
    end
end

