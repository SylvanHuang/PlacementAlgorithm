%% ��x_Deploy����ת��ΪVector�洢��ȥ�����࣬��ߴ洢������
%  ֻ֧�ֶ��x_Deployת��Ϊvector
function Vector = Encode_Deploy_Matrix(Matrix)
Indicator = 1;
Vector = zeros(size(Matrix,3),size(Matrix,1));
Const = 1:size(Matrix,2);
for i = 1:size(Matrix,3)
    M = size(Matrix,1); % Theoretically, m = Nf, n = 2*Ns
%     Vector = zeros(1,M);
%     for m = 1:M
%         Vector(i,m) = find(Matrix(m,:,i)==1);
%     end
    Vector(i,:) = Const*Matrix(:,:,i)';
    %%%%%%%%%%%%%%%%%%%%%%%% ����ʱ��(����) %%%%%%%%%%%
    Ind = floor(i/size(Matrix,3)*100);
    if size(Matrix,3)>1000 && mod(Ind,Indicator) == 0 && Ind~=0
        Indicator = Indicator +1;
        disp(['��ǰ���ȣ� ',num2str(Ind),'%'])
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end