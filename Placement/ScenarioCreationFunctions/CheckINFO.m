%% ������ɻ����Ƿ�������
function [bin_gen] = CheckINFO(bin_gen, bits_num, min_var, max_var)
for k = 1:size(bin_gen,1) % ���ÿһ�����򣬻ָ�delpy����
    for i = 1:size(bin_gen,2)/bits_num % ת��ÿһ�������ڵ�VNF����
        % �ò���ֻ��� 0 0 0 0 �� 1 1 1 1 �޶�Ӧ��������������������Ҫ���鿼��
        % ��0 0 0 0 �� 1 1 1 1 ǿ�Ʊ���
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