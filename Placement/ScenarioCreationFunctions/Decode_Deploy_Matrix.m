%% 将x_Deploy Vector转变为Matrix,方便数值计算
%  只支持单个x_Deploy转化为vector
function Matrix = Decode_Deploy_Matrix(Vector, Ns)

Nf = size(Vector,2);
Matrix = zeros(Nf,Ns,size(Vector,1));
for i = 1:size(Vector,1)
    for m = 1:Nf
        Ind = Vector(i,m);
        Matrix(m,Ind,i) = 1;
    end
end