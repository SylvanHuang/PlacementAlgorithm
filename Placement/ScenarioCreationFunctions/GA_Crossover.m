%% �Ŵ��㷨���򽻲�
function  New_bin_gen = GA_Crossover(Old_bin_gen, pc)
Pair_Num = floor(size(Old_bin_gen,1)/2);
New_bin_gen = [];
RandNum = randperm(size(Old_bin_gen,1));
for i = 1:Pair_Num
    % ���ѡ��2������
    index1 = RandNum(2*i-1);
    index2 = RandNum(2*i);
    % pc�ĸ���ѡ����죬���õ��㽻�棬��������ѡ��
    if rand<pc 
        % �����ѡ��
        Loc = randi(size(Old_bin_gen,2));
        New_bin_gen = [New_bin_gen; [Old_bin_gen([index1,index2],1:Loc), ...
            Old_bin_gen([index2,index1],Loc+1:end)]];
    else
        New_bin_gen = [New_bin_gen; Old_bin_gen([index1,index2],:)];
    end  
end