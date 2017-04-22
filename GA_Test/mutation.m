function new_gen = mutation(old_gen, pm)
mpoints = find(rand(size(old_gen))<pm);
new_gen = old_gen;
new_gen(mpoints) = 1-old_gen(mpoints); % 第多少位bit翻转，变异