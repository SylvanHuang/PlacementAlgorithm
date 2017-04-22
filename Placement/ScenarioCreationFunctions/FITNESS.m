%% 遗传算法适应度函数，分为两类，可行解和非可行解的适应度函数
function [New_Poss_bin_gen, min_Fitness_Poss_bin,...
    New_NonPoss_bin_gen, min_Fitness_NonPoss_bin]=...
    FITNESS(Poss_bin_gen, NonPoss_bin_gen,...
    PhyPara, LogicPara, Selected_Num_Poss_bin, bits_num)
eval('load .\DataContainer\NodeTopology.mat');
% Selected_Num_Poss_bin 为选择后种群可行解个数。
Len_bin = size(Poss_bin_gen,2); % 每条个体的长度
Total_Num_bin = size(Poss_bin_gen,1) + size(NonPoss_bin_gen,1);

%% 第一步针对可行解选择适当的个体
Num_Poss_bin = size(Poss_bin_gen,1);
Fitness_Poss_bin = zeros(1,Num_Poss_bin);
for i = 1:Num_Poss_bin
    x_Deploy = zeros(LogicPara.Nf,2*PhyPara.Ns);
    for k = 1:LogicPara.Nf % 转译每一条基因内的VNF编码
        bin_tmp = Poss_bin_gen(i,(k-1)*bits_num+1:k*bits_num);
        dec_tmp = bin2dec(num2str(bin_tmp));
        % 重构x_Deloy变量，为Nf*2Ns 的0-1矩阵
        x_Deploy(k,dec_tmp) = 1;
    end 
    x_G_tmp = x_Deploy(:,1:PhyPara.Ns);
    x_D_tmp = x_Deploy(:,PhyPara.Ns+1:end);
    TotalCompTime = sum(sum(LogicPara.CompTime_vCPU.*x_G_tmp)) ...
        + sum(sum(LogicPara.CompTime_FPGA.*x_D_tmp));
    x_tmp = x_G_tmp+x_D_tmp;
    TotalTransTime = trace(LogicPara.FlowNum*(x_tmp)...
        *ShortestDistMatrix*(x_tmp)')...
        +x_tmp(1,:)*ShortestDistMatrix(:,1)...
        +x_tmp(end,:)*ShortestDistMatrix(:,end);
    Fitness_Poss_bin(i) = (1-LogicPara.alpha)*TotalCompTime+LogicPara.alpha*TotalTransTime;
end
% 选择时延最小的一部分
[Fitness_tmp, index1] = sort(Fitness_Poss_bin);
min_Fitness_Poss_bin = Fitness_tmp(1:Selected_Num_Poss_bin);
New_Poss_bin_gen = Poss_bin_gen(index1(1:Selected_Num_Poss_bin),:);

%% 第二部针对非可行解选择适当的个体
Num_NonPoss_bin = size(NonPoss_bin_gen,1);
Fitness_NonPoss_bin = zeros(1,Num_NonPoss_bin);
for i = 1:Num_NonPoss_bin
    x_Deploy = zeros(LogicPara.Nf,2*PhyPara.Ns);
    for k = 1:LogicPara.Nf % 转译每一条基因内的VNF编码
        bin_tmp = NonPoss_bin_gen(i,(k-1)*bits_num+1:k*bits_num);
        dec_tmp = bin2dec(num2str(bin_tmp));
        % 重构x_Deloy变量，为Nf*2Ns 的0-1矩阵
        x_Deploy(k,dec_tmp) = 1;
    end 
    x_G_tmp = x_Deploy(:,1:PhyPara.Ns);
    x_D_tmp = x_Deploy(:,PhyPara.Ns+1:end);
    Fitness_NonPoss_bin(i) = sum(max(LogicPara.RequiredvCPU*x_G_tmp-PhyPara.vCPUNumMax,0)...
        + max(LogicPara.RequiredFPGA*x_D_tmp-PhyPara.FPGA_Num,0));
end
% 选择时延最小的一部分
[Fitness_tmp, index2] = sort(Fitness_NonPoss_bin);
min_Fitness_NonPoss_bin = Fitness_tmp(1:Total_Num_bin/2-Selected_Num_Poss_bin);
New_NonPoss_bin_gen = NonPoss_bin_gen(index2(1:Total_Num_bin/2-Selected_Num_Poss_bin),:);
