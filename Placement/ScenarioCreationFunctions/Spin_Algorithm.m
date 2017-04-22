%% 轮盘选择法，一定概率选中下一代个体
function [New_bin, New_fitness] = Spin_Algorithm(Fitness, Bin_gen, Selected_Num, Parameter)
% Fitness：每条基因个体对应的适应度函数
% Bin_gen：需要进行选择的基因个体
% Selected_Num：需要选择下一代基因个体的个数
% Parameter：参数选择，ascend: 值越大概率越高；descend：值越小概率越大
if Fitness >=0
    switch Parameter
        case 'ascend'
            Fitness_tmp = Fitness;
        case 'descend'
            Fitness_tmp = 1./Fitness;
        otherwise
            error('Wrong parameters');
    end
else
    error('Fitness have negative values')
end

ps = Fitness_tmp/sum(Fitness_tmp); % 每条基因个体对应的选中概率值
pscum = cumsum(ps);
r = rand(1, Selected_Num);
selected = sum(ones(Selected_Num,1)*pscum < r'*ones(1,length(pscum)),2)+1;
% selected = sum(pscum'*ones(1, Selected_Num) < ones(Selected_Num, 1)*r)+1;
New_bin = Bin_gen(selected,:);
New_fitness = Fitness(selected);