% �Ŵ��㷨�еı��촦��
function New_bin_gen = GA_Mutation(bin_gen,pm)
Pos = randi(size(bin_gen,2),size(bin_gen,1),1); % ����ÿһ���������ɱ����λ��
Whether2Mutate = rand(size(bin_gen,1),1)<pm;
Whether2Mutate([1,2]) = 0; % �����ŽⱣ��
for k = find(Whether2Mutate == 1)
    bin_gen(k,Pos(k)) = 1- bin_gen(k,Pos(k));
end
New_bin_gen = bin_gen;
