function new_gen = crossover(old_gen,pc)
[~, mating] = sort(rand(size(old_gen,1),1));
mat_gen = old_gen(mating,:);
pairs = floor(size(mat_gen,1)/2);
bits = size(mat_gen,2);
cpairs = rand(pairs,1)<pc;  % ���ѡ�񽻲��pair index
cpoints = randi([1, bits-1], pairs, 1); % ������������λ��������һλ�����bits-1λ
cpoints = cpairs.*cpoints;
for i =1:pairs
    new_gen([2*i-1, 2*i],:) = [mat_gen([2*i-1, 2*i],1:cpoints(i)), ...
        mat_gen([2*i, 2*i-1], cpoints(i)+1:bits)];
end