%% ��ʼ����Ⱥ��
function [bin_gen, bit_num] = GA_Encoding(min_var, max_var, popsize, LogicPara)
bit_num = ceil(log2(max_var-min_var+1)); % DCӲ���Ķ����Ʊ��������
bin_gen = rand(popsize, bit_num*LogicPara.Nf)>0.5;
