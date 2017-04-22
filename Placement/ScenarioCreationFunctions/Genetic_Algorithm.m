%% 遗传算法主函数
function [x_Deploy_Algorithm3] = Genetic_Algorithm(PhyPara, LogicPara)
%%%%%%%%%%%%%%%%%%%%%%%%%%%% 调试用 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tic
% clc
% clear all
% eval('load .\DataContainer\InputPara.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
popsize = 1000;           % 种群数量
ratio_poss_solution = 0.3; % 保证可行解数量
max_ite_num = 50;       % 最大迭代次数
pc = 0.6;               % 交叉概率
pm = 0.1;               % 变异概率
min_var = 1;
max_var = 2*PhyPara.Ns;
% 初始化种群数，
while 1
    [bin_gen, bits_num] = GA_Encoding(min_var, max_var, popsize, LogicPara);
    [bin_gen] = CheckINFO(bin_gen, bits_num, min_var, max_var);
    [Poss_bin_gen, NonPoss_bin_gen] = WhetherPossibleSolution(bin_gen, PhyPara, LogicPara, bits_num);
    % 保证可行解数量
    if size(Poss_bin_gen,1) >= ratio_poss_solution*popsize
        break
    end
end
for ite_num = 1:max_ite_num
    % 已有族群
    New_bin_gen = [Poss_bin_gen; NonPoss_bin_gen];
    % 变异，对最优解有保护
    New_bin_gen = GA_Mutation(New_bin_gen,pm);
    New_bin_gen = CheckINFO(New_bin_gen, bits_num, min_var, max_var);
    % 交叉
    New_bin_gen = GA_Crossover(New_bin_gen, pc);
    New_bin_gen = CheckINFO(New_bin_gen, bits_num, min_var, max_var);
    [Poss_bin_gen_new, NonPoss_bin_gen_new] = ...
        WhetherPossibleSolution(New_bin_gen, PhyPara, LogicPara, bits_num);
    % 选择，对于可行解和非可行解采取不同的行动
    %%%%%%%%%%%%%%%%%%%% 该选择方法会过快收敛到次优解，因此暂时用另一算法替代%%%%%%%%%%
%     [Poss_bin_gen, min_Fitness_Poss_bin,...
%     NonPoss_bin_gen, min_Fitness_NonPoss_bin] =...
%     FITNESS([Poss_bin_gen; Poss_bin_gen_new],...
%         [NonPoss_bin_gen; NonPoss_bin_gen_new],...
%         PhyPara, LogicPara, max(size(Poss_bin_gen,1),size(Poss_bin_gen_new,1)),bits_num);
%     min_Fitness_Poss_bin(1,1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [Poss_bin_gen, New_Fitness_Poss_bin,...
        NonPoss_bin_gen, New_Fitness_NonPoss_bin] ...
      = FITNESS_New([Poss_bin_gen; Poss_bin_gen_new],...
        [NonPoss_bin_gen; NonPoss_bin_gen_new],...
        PhyPara, LogicPara, max(size(Poss_bin_gen,1),size(Poss_bin_gen_new,1)),bits_num);
    ite_num
    New_Fitness_Poss_bin(1,1)
    if min(New_Fitness_Poss_bin) == max(New_Fitness_Poss_bin)
        break
    end
  
end
Best_bin = Poss_bin_gen(1,:);
x_Deploy_Algorithm3 = zeros(LogicPara.Nf, 2*PhyPara.Ns);
for i = 1:LogicPara.Nf
    index = bin2dec(num2str(Best_bin((i-1)*bits_num+1:i*bits_num)));
    x_Deploy_Algorithm3(i,index) = 1;
end
toc