% 判断当前生成的是否是可行解
function [Poss_bin_gen, NonPoss_bin_gen] = ...
    WhetherPossibleSolution(bin_gen, PhyPara, LogicPara, bits_num)
% 初始化
Poss_bin_gen = [];
NonPoss_bin_gen = [];

for k = 1:size(bin_gen,1) % 针对每一条基因，恢复delpy矩阵
    indicator = 1; % Indicator=1 表明是可行解，否则是非可行解
    x_Deploy = zeros(LogicPara.Nf,2*PhyPara.Ns);
    for i = 1:LogicPara.Nf % 转译每一条基因内的VNF编码
        bin_tmp = bin_gen(k,(i-1)*bits_num+1:i*bits_num);
        dec_tmp = bin2dec(num2str(bin_tmp));
        % 重构x_Deloy变量，为Nf*2Ns 的0-1矩阵
        x_Deploy(i,dec_tmp) = 1;
    end
    % 判断x_Delploy 是否为可行解
    x_G_tmp = x_Deploy(:,1:PhyPara.Ns);
    x_D_tmp = x_Deploy(:,PhyPara.Ns+1:end);
    if sum(LogicPara.RequiredvCPU*x_G_tmp > PhyPara.vCPUNumMax)...
            || sum(LogicPara.RequiredFPGA*x_D_tmp > PhyPara.FPGA_Num)
       indicator = 0;
    end
    % 根据上述判断过程，归类可行解和非可行解
    switch indicator
        case 1
            Poss_bin_gen = [Poss_bin_gen; bin_gen(k,:)];
        case 0
            NonPoss_bin_gen = [NonPoss_bin_gen; bin_gen(k,:)];
        otherwise
            error('Indicator Error')
    end
end