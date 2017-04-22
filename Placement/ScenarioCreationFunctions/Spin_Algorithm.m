%% ����ѡ�񷨣�һ������ѡ����һ������
function [New_bin, New_fitness] = Spin_Algorithm(Fitness, Bin_gen, Selected_Num, Parameter)
% Fitness��ÿ����������Ӧ����Ӧ�Ⱥ���
% Bin_gen����Ҫ����ѡ��Ļ������
% Selected_Num����Ҫѡ����һ���������ĸ���
% Parameter������ѡ��ascend: ֵԽ�����Խ�ߣ�descend��ֵԽС����Խ��
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

ps = Fitness_tmp/sum(Fitness_tmp); % ÿ����������Ӧ��ѡ�и���ֵ
pscum = cumsum(ps);
r = rand(1, Selected_Num);
selected = sum(ones(Selected_Num,1)*pscum < r'*ones(1,length(pscum)),2)+1;
% selected = sum(pscum'*ones(1, Selected_Num) < ones(Selected_Num, 1)*r)+1;
New_bin = Bin_gen(selected,:);
New_fitness = Fitness(selected);