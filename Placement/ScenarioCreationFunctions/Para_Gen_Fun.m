function Para_Gen_Fun
%% Input Parameters
%%%%%%%%%%%%%%%%%%%%%%%% Physical Layer %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PhyPara.Ns = 7; 
if exist('.\DataContainer\NodeTopology.mat','file')% Physical node number
    eval('load .\DataContainer\NodeTopology.mat');  % Import substrate topology figures
else
    Node_Location;
end

PhyPara.CPU_Num =  randi([2,4],1,PhyPara.Ns);   % General CPU number for each node
PhyPara.VirtRatioConst = 1;             % Virtualization Ratio Constant
% The maximum number fo vCPU that can support for each node
PhyPara.vCPUNumMax = PhyPara.CPU_Num * PhyPara.VirtRatioConst;
PhyPara.FPGA_Num = randi([1,2],1,PhyPara.Ns);   % Dedicated FPGA number for each node
% The largest number of VNF which can be depolyed on each server
PhyPara.K = 3;

%%%%%%%%%%%%%%%%%%%%%%%% Logical Layer %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LogicPara.Nf = 6;                         % Number of Logical VNF
% Ratio of importance between computation and transmission delay
LogicPara.alpha = 0.2;      
LogicPara.FlowSequency = [1 2 3 4 1 4 3 5 6];
%% 构造Flow在节点间的传输次数
LogicPara.FlowNum = zeros(LogicPara.Nf);
for i = 1:length(LogicPara.FlowSequency)-1
    x = LogicPara.FlowSequency(i);
    y = LogicPara.FlowSequency(i+1);
    LogicPara.FlowNum(x,y) = LogicPara.FlowNum(x,y) + 1;
    LogicPara.FlowNum(y,x) = LogicPara.FlowNum(x,y);
end

LogicPara.FlowName = ['vBBU', 'vBSC', 'vRNC', 'vAC', 'vAG', 'vSeGW'];
LogicPara.RequiredvCPU = randi([1,2],1,LogicPara.Nf); % 用户模板所需计算资源
LogicPara.RequiredFPGA = randi([1,2],1,LogicPara.Nf);
% VNF 在不同服务器上的计算时间——VNF运行时间均值为3到10之间均匀分布
LogicPara.CompTime_vCPU_Mean = 3*(3+7*rand(LogicPara.Nf,1));
LogicPara.CompTime_vCPU = LogicPara.CompTime_vCPU_Mean-4+4*rand(LogicPara.Nf, PhyPara.Ns);
LogicPara.CompTime_FPGA = LogicPara.CompTime_vCPU/3;

eval(['save .\DataContainer\InputPara.mat PhyPara LogicPara'])