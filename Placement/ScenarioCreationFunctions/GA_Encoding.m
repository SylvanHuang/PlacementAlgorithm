%% 初始化种群，
function [bin_gen, bit_num] = GA_Encoding(min_var, max_var, popsize, LogicPara)
bit_num = ceil(log2(max_var-min_var+1)); % DC硬件的二进制编码比特数
bin_gen = rand(popsize, bit_num*LogicPara.Nf)>0.5;
