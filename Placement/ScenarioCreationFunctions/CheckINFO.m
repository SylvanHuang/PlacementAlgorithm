%% 检测生成基因是否有意义
function [bin_gen] = CheckINFO(bin_gen, bits_num, min_var, max_var)
for k = 1:size(bin_gen,1) % 针对每一条基因，恢复delpy矩阵
    for i = 1:size(bin_gen,2)/bits_num % 转译每一条基因内的VNF编码
        % 该操作只针对 0 0 0 0 和 1 1 1 1 无对应整数的情况，其他情况需要酌情考虑
        % 对0 0 0 0 和 1 1 1 1 强制变异
        while 1
            bin_tmp = bin_gen(k,(i-1)*bits_num+1:i*bits_num);
            dec_tmp = bin2dec(num2str(bin_tmp));
            if dec_tmp < min_var || dec_tmp > max_var
                tmp = randi(bits_num);
                bin_gen(k,(i-1)*bits_num+tmp) = 1 - bin_gen(k,(i-1)*bits_num+tmp);
            else
                break
            end
        end
    end
end