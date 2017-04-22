%% Main function
clear all
clc
close all
popsize = 50;
scale_var = 0.000001;
pc = 0.6;
pm = 0.1;
min_var = 1;
max_var = 6;
max_ite_num = 20;
[bin_gen, bits] = encoding(min_var, max_var, scale_var, popsize);
% bin_gen(1,:) = ones(size(bin_gen(1,:)));
for ite_num = 1:max_ite_num
    % 解码
    [var_gen, fitness] = decoding('Funname', bin_gen, bits, min_var, max_var);
    if max(fitness) == min(fitness)
        break
    end
    % 选择
    [evo_gen, best_indiv, max_fitness(ite_num)] = selection(bin_gen, fitness);
    % 交叉
    new_gen = crossover(evo_gen,pc);
    % 变异
    new_gen = mutation(new_gen, pm);
    bin_gen = [best_indiv;best_indiv;new_gen]; % 保持种群个数不变
end
x = min_var:scale_var:max_var;
max(Funname(x))
bin_gen = rand(popsize*max_ite_num,size(bin_gen,2))>0.5;
[var_gen, fitness] = decoding('Funname', bin_gen, bits, min_var, max_var);
max(fitness)
% plot(x,Funname(x));

[MAX,~] = max(max_fitness)
max(fitness)<MAX
