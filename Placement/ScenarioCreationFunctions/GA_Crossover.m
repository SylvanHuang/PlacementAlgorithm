%% 遗传算法基因交叉
function  New_bin_gen = GA_Crossover(Old_bin_gen, pc)
Pair_Num = floor(size(Old_bin_gen,1)/2);
New_bin_gen = [];
RandNum = randperm(size(Old_bin_gen,1));
for i = 1:Pair_Num
    % 随机选择2个个体
    index1 = RandNum(2*i-1);
    index2 = RandNum(2*i);
    % pc的概率选择变异，采用单点交叉，交叉点随机选择
    if rand<pc 
        % 交叉点选择
        Loc = randi(size(Old_bin_gen,2));
        New_bin_gen = [New_bin_gen; [Old_bin_gen([index1,index2],1:Loc), ...
            Old_bin_gen([index2,index1],Loc+1:end)]];
    else
        New_bin_gen = [New_bin_gen; Old_bin_gen([index1,index2],:)];
    end  
end