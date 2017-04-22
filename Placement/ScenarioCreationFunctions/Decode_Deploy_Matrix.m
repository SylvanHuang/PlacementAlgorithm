%% ��x_Deploy Vectorת��ΪMatrix,������ֵ����
%  ֻ֧�ֵ���x_Deployת��Ϊvector
function Matrix = Decode_Deploy_Matrix(Vector, Ns)

Nf = size(Vector,2);
Matrix = zeros(Nf,Ns,size(Vector,1));
for i = 1:size(Vector,1)
    for m = 1:Nf
        Ind = Vector(i,m);
        Matrix(m,Ind,i) = 1;
    end
end