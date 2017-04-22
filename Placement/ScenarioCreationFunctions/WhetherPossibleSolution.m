% �жϵ�ǰ���ɵ��Ƿ��ǿ��н�
function [Poss_bin_gen, NonPoss_bin_gen] = ...
    WhetherPossibleSolution(bin_gen, PhyPara, LogicPara, bits_num)
% ��ʼ��
Poss_bin_gen = [];
NonPoss_bin_gen = [];

for k = 1:size(bin_gen,1) % ���ÿһ�����򣬻ָ�delpy����
    indicator = 1; % Indicator=1 �����ǿ��н⣬�����Ƿǿ��н�
    x_Deploy = zeros(LogicPara.Nf,2*PhyPara.Ns);
    for i = 1:LogicPara.Nf % ת��ÿһ�������ڵ�VNF����
        bin_tmp = bin_gen(k,(i-1)*bits_num+1:i*bits_num);
        dec_tmp = bin2dec(num2str(bin_tmp));
        % �ع�x_Deloy������ΪNf*2Ns ��0-1����
        x_Deploy(i,dec_tmp) = 1;
    end
    % �ж�x_Delploy �Ƿ�Ϊ���н�
    x_G_tmp = x_Deploy(:,1:PhyPara.Ns);
    x_D_tmp = x_Deploy(:,PhyPara.Ns+1:end);
    if sum(LogicPara.RequiredvCPU*x_G_tmp > PhyPara.vCPUNumMax)...
            || sum(LogicPara.RequiredFPGA*x_D_tmp > PhyPara.FPGA_Num)
       indicator = 0;
    end
    % ���������жϹ��̣�������н�ͷǿ��н�
    switch indicator
        case 1
            Poss_bin_gen = [Poss_bin_gen; bin_gen(k,:)];
        case 0
            NonPoss_bin_gen = [NonPoss_bin_gen; bin_gen(k,:)];
        otherwise
            error('Indicator Error')
    end
end