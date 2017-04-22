%% 针对目标1：最小化计算时延的启发式算法
function [x_Deploy] = Min_Compt_Delay_Heuristic(PhyPara, LogicPara)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%% 调试用 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clc
% clear all
% eval('load .\DataContainer\InputPara.mat');
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Ns = PhyPara.Ns;
Nf = LogicPara.Nf;
% 每个VNF在每个节点硬件平台上的计算时间
Comp_Time_Pool = [LogicPara.CompTime_vCPU, LogicPara.CompTime_FPGA];
% 针对每个VNF在不同硬件上的KPI，挑选出最合适的硬件节点
Num_VNF = Nf;
K = 1;                          % VNF 在不同硬件上最小计算延迟和第K小计算延迟 K<= 2*Ns
Compt_Delay_Substration = [];   % VNF 最小计算延迟和第K个小计算延迟的差
VNF_Min_CompTime_NodeIndx = [];             % VNF 时延最短的节点
VNF_Min_CompTime = [];      % VNF 最短计算时间节点对应的计算时间
x_Deploy = zeros(Nf,2*Ns);

%% 初始化需要排序的VNF，并根据Compt_Delay_Substration从大到小排序。
% 因为Compt_Delay_Substration越大的VNF换节点部署的代价越大。
% 得出每个VNF时延最短的节点和第K个时延最短节点
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


%% 部署算法，算法直到所有VNF均全部部署
% 输入参数：Compt_Delay_Substration 和 VNF_Min_CompTime_NodeIndx
while Num_VNF > 0 % 检测是否所有VNF都已经部署完毕
    
    % 选出时延差最大的VNF部署
    if K == 1
        % 如果K ==1， 则优先部署时延最短的节点。
        [~, VNF_Ind] = min(Compt_Delay_Substration);
    elseif K >1
        [~, VNF_Ind] = max(Compt_Delay_Substration);  % VNF Index
    end
        
    Node_Ind = VNF_Min_CompTime_NodeIndx(VNF_Ind);% VNF 将要部署的节点
    
    % 检测该节点部署是否满足硬件池约束
    if Node_Ind <= Ns
        % 部署于CPU中
        if LogicPara.RequiredvCPU(VNF_Ind) <= PhyPara.vCPUNumMax(Node_Ind)
            Whether2Deploy = 1;
            % Update resource pool
            PhyPara.vCPUNumMax(Node_Ind) = PhyPara.vCPUNumMax(Node_Ind) ...
                - LogicPara.RequiredvCPU(VNF_Ind);
        else
            Whether2Deploy = 0;
        end
    else
        % 部署于FPGA中
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
        % 如果可以，将参数部署于
        x_Deploy(VNF_Ind,Node_Ind) = 1;
        Num_VNF = Num_VNF-1;
        if K>1
            Compt_Delay_Substration(VNF_Ind) = 0;
        elseif K == 1
            Compt_Delay_Substration(VNF_Ind) = 10^5;
        end
    else
        % 如果不可以，将对应节点时间参数设置为正无穷，然后更新该VNF的时延差和在队列中的位置
        Comp_Time_Pool(VNF_Ind, Node_Ind) = +Inf;
        % 重新更新该VNF对应的数据
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