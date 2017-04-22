%% 将x_Deploy矩阵转变为Vector存储，去除冗余，提高存储利用率
%  只支持多个x_Deploy转化为vector
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
    %%%%%%%%%%%%%%%%%%%%%%%% 测算时间(调试) %%%%%%%%%%%
    Ind = floor(i/size(Matrix,3)*100);
    if size(Matrix,3)>1000 && mod(Ind,Indicator) == 0 && Ind~=0
        Indicator = Indicator +1;
        disp(['当前进度： ',num2str(Ind),'%'])
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end