function [bin_gen, bits] = encoding(min_var, max_var, scale_var, popsize)
bits = ceil(log2((max_var-min_var)./scale_var));
bin_gen = rand(popsize, sum(bits))>0.5;