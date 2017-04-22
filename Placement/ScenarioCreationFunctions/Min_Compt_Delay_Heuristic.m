%% ���Ŀ��1����С������ʱ�ӵ�����ʽ�㷨
function [x_Deploy] = Min_Compt_Delay_Heuristic(PhyPara, LogicPara)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%% ������ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clc
% clear all
% eval('load .\DataContainer\InputPara.mat');
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Ns = PhyPara.Ns;
Nf = LogicPara.Nf;
% ÿ��VNF��ÿ���ڵ�Ӳ��ƽ̨�ϵļ���ʱ��
Comp_Time_Pool = [LogicPara.CompTime_vCPU, LogicPara.CompTime_FPGA];
% ���ÿ��VNF�ڲ�ͬӲ���ϵ�KPI����ѡ������ʵ�Ӳ���ڵ�
Num_VNF = Nf;
K = 1;                          % VNF �ڲ�ͬӲ������С�����ӳٺ͵�KС�����ӳ� K<= 2*Ns
Compt_Delay_Substration = [];   % VNF ��С�����ӳٺ͵�K��С�����ӳٵĲ�
VNF_Min_CompTime_NodeIndx = [];             % VNF ʱ����̵Ľڵ�
VNF_Min_CompTime = [];      % VNF ��̼���ʱ��ڵ��Ӧ�ļ���ʱ��
x_Deploy = zeros(Nf,2*Ns);

%% ��ʼ����Ҫ�����VNF��������Compt_Delay_Substration�Ӵ�С����
% ��ΪCompt_Delay_SubstrationԽ���VNF���ڵ㲿��Ĵ���Խ��
% �ó�ÿ��VNFʱ����̵Ľڵ�͵�K��ʱ����̽ڵ�
Matrix_tmp = Comp_Time_Pool;
for i = 1:K
    [VNF_Min_CompTime_tmp, VNF_Min_CompTime_NodeIndx_tmp] = min(Matrix_tmp');
    switch i
        case 1
            VNF_Min_CompTime = VNF_Min_CompTime_tmp;
            VNF_Min_CompTime_NodeIndx = VNF_Min_CompTime_NodeIndx_tmp;
            Compt_Delay_Substration = VNF_Min_CompTime_tmp;
        case K
            Compt_Delay_Substration = VNF_Min_CompTime_tmp...
                -VNF_Min_CompTime;
    end
    for k = 1:length(VNF_Min_CompTime_NodeIndx_tmp)
        Matrix_tmp(k,VNF_Min_CompTime_NodeIndx_tmp(k)) = +Inf;
    end
end


%% �����㷨���㷨ֱ������VNF��ȫ������
% ���������Compt_Delay_Substration �� VNF_Min_CompTime_NodeIndx
while Num_VNF > 0 % ����Ƿ�����VNF���Ѿ��������
    
    % ѡ��ʱ�Ӳ�����VNF����
    if K == 1
        % ���K ==1�� �����Ȳ���ʱ����̵Ľڵ㡣
        [~, VNF_Ind] = min(Compt_Delay_Substration);
    elseif K >1
        [~, VNF_Ind] = max(Compt_Delay_Substration);  % VNF Index
    end
        
    Node_Ind = VNF_Min_CompTime_NodeIndx(VNF_Ind);% VNF ��Ҫ����Ľڵ�
    
    % ���ýڵ㲿���Ƿ�����Ӳ����Լ��
    if Node_Ind <= Ns
        % ������CPU��
        if LogicPara.RequiredvCPU(VNF_Ind) <= PhyPara.vCPUNumMax(Node_Ind)
            Whether2Deploy = 1;
            % Update resource pool
            PhyPara.vCPUNumMax(Node_Ind) = PhyPara.vCPUNumMax(Node_Ind) ...
                - LogicPara.RequiredvCPU(VNF_Ind);
        else
            Whether2Deploy = 0;
        end
    else
        % ������FPGA��
        if LogicPara.RequiredFPGA (VNF_Ind) <= PhyPara.FPGA_Num(Node_Ind-Ns)
            Whether2Deploy = 1;
            % Update resource pool;
            PhyPara.FPGA_Num(Node_Ind-Ns) = PhyPara.FPGA_Num(Node_Ind-Ns)...
                -LogicPara.RequiredFPGA (VNF_Ind);
        else
            Whether2Deploy = 0;
        end
    end
    
    if Whether2Deploy
        % ������ԣ�������������
        x_Deploy(VNF_Ind,Node_Ind) = 1;
        Num_VNF = Num_VNF-1;
        if K>1
            Compt_Delay_Substration(VNF_Ind) = 0;
        elseif K == 1
            Compt_Delay_Substration(VNF_Ind) = 10^5;
        end
    else
        % ��������ԣ�����Ӧ�ڵ�ʱ���������Ϊ�����Ȼ����¸�VNF��ʱ�Ӳ���ڶ����е�λ��
        Comp_Time_Pool(VNF_Ind, Node_Ind) = +Inf;
        % ���¸��¸�VNF��Ӧ������
        Matrix_tmp = Comp_Time_Pool;
        for i = 1:K
            [VNF_Min_CompTime_tmp, VNF_Min_CompTime_NodeIndx_tmp] = min(Matrix_tmp(VNF_Ind,:)');
            switch i
                case 1
                    VNF_Min_CompTime = VNF_Min_CompTime_tmp;
                    VNF_Min_CompTime_NodeIndx(VNF_Ind) = VNF_Min_CompTime_NodeIndx_tmp;
                    Compt_Delay_Substration(VNF_Ind) = VNF_Min_CompTime_tmp;
                case K
                    Compt_Delay_Substration(VNF_Ind) = VNF_Min_CompTime_tmp...
                        -VNF_Min_CompTime;
            end
            Matrix_tmp(VNF_Ind,VNF_Min_CompTime_NodeIndx_tmp) = +Inf;
        end
        
    end
end
% x_Deploy