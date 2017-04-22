%% �оٳ����п��н�
function Possible_Ans_Gen(PhyPara, LogicPara)
%%%%%%%%%%%%%%%%%%%%%%%%% Parameter Initial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nf = LogicPara.Nf;
Ns = 2*PhyPara.Ns; % ר��Server��ͨ��Server������
K= PhyPara.K; %% Ns*K should LARGER then Nf
% CPU_Num = PhyPara.CPU_Num; % ���������Դ����
vCPUNumMax = PhyPara.vCPUNumMax;
FPGA_Num = PhyPara.FPGA_Num;
RequiredvCPU = LogicPara.RequiredvCPU;
RequiredFPGA = LogicPara.RequiredFPGA;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ��ʼ����һ��Ƕ�׾���x_Deploy,
x_Deploy = [];
a = zeros(1, Ns);
a(1,end) = 1;
%% �ӳ�ʼ�����������Nf��Ƕ�ף�������������Nf*Nsά����ÿһ��ֻ��һ��1
tmp = x_Deploy;
t1 = clock; %% ��ʼ������ʱ��
for j = 1:Nf % Nf��Ƕ��
    clear x_Deploy
    [m, n, x_Num] = size(tmp);
    if n == 0
        n = Ns;
    end
    for i = 1:x_Num
        InitTemp = reshape(tmp(:,:,i),m,n); %% ֮ǰ�������ÿһ������
        for k = 1:Ns
            a = [a(end),a(1:end-1)];
            Possible_x = [InitTemp;a];   %% ��ԭ�����¼�һ�������µľ���
            x_G = Possible_x(:,1:Ns/2);
            x_D = Possible_x(:,Ns/2+1:end);
            % Լ������1�� һ��Server���಼��K̨VNF
            % Լ������2�� ÿ��Server�ϲ����VNF������Դ���ܳ�������Դ
            if min(sum(Possible_x,1)<=K)...
                && min(RequiredvCPU(1:j)*x_G<=vCPUNumMax)...
                    && min(RequiredFPGA(1:j)*x_D<=FPGA_Num)
                        if exist('x_Deploy', 'var') >0
                            [~,~,Len_tmp] = size(x_Deploy);
                        else
                            Len_tmp = 0;
                        end
                        x_Deploy(1:m+1,:,Len_tmp+1) = reshape(Possible_x,[m+1,n,1]);
                        %%%%%%%%%%%%%%%%%%%%%%%% ����ʱ��(����) %%%%%%%%%%%
                        t2 = clock;
                        if etime(t2,t1) > 10
                            disp('����');
                            disp(Len_tmp)
                            t1 = clock;
                            if j == 6
                                disp(Encode_Deploy_Matrix(Possible_x));
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                          
            else
                continue
            end
        end
    end
    if exist('x_Deploy','var')>0
        tmp = x_Deploy;
    else
        x_Deploy = [];
        return
    end
end
% L = length(x_Deploy);
% if L > 3
%     x0 = floor(L/3);
%     x1 = floor(L/3*2);
%     x_Deploy_a = x_Deploy(:,:,1:x0);
%     x_Deploy_b = x_Deploy(:,:,x0+1:x1);
%     x_Deploy_c = x_Deploy(:,:,x1+1:end);
% else
%     error('�û����н�����3��')
% end
Vector_x_Deploy = Encode_Deploy_Matrix(x_Deploy);
eval('save .\DataContainer\PossibleAction.mat Vector_x_Deploy')



