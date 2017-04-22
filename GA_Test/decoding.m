function [var_gen, fitness] = decoding(funname, bin_gen, bits, min_var, max_var)
num_var = length(bits);
popsize = size(bin_gen, 1);
scale_dec = (max_var-min_var)./(2.^bits-1);
bits = cumsum(bits);
bits = [0 bits];
for i = 1:num_var
    bin_var{i} = bin_gen(:, bits(i)+1:bits(i+1));
    var{i} = sum(ones(popsize, 1)*2.^(size(bin_var{i},2)-1:-1:0)...
        .*bin_var{i},2).*scale_dec(i)+min_var(i);
end
var_gen=[var{1,:}];
for i = 1:popsize
    fitness(i) = eval([funname, '(var_gen(i,:))']);
end