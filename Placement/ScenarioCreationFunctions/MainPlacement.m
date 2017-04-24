%% Placement algorithm of ROSE algorithm packet
clear all
clc
close all

%% 确定是否已经生成基础参数
if exist('.\DataContainer\InputPara.mat','file')% Physical node number
    eval('load .\DataContainer\InputPara.mat');  % Import substrate topology figures
else
    Para_Gen_Fun;
    eval('load .\DataContainer\InputPara.mat');
end
PhyPara
LogicPara
eval('load .\DataContainer\NodeTopology.mat');




% %% 画出基础设施图
% figure(1);
% for i = 1:PhyPara.Ns
%     plot(NodeLocation(i,1),NodeLocation(i,2),'ro'); hold on
%     text(NodeLocation(i,1)+1,NodeLocation(i,2)+1,['Node ',num2str(i)]);
% end
% for i = 1:length(RelationVector)
%     NodeInd = RelationVector(i,:);
%     NodesLineLoc = [NodeLocation(NodeInd(1),:); NodeLocation(NodeInd(2),:)];
%     plot(NodesLineLoc(:,1), NodesLineLoc(:,2), 'b-');
%
% end
% axis([0,100,0,100]);
% hold off
% %% 画出逻辑图
% figure(2); Flow_Illustration(LogicPara);





%%%%%%%%%%%%%%%%%%%%%%%%%% 生成所有可能解 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 不能生成所有可能解，系统无法容纳这么大容量数据，
% 必须在生成的同时就开始判断,"剪枝"
if not(exist('Vector_x_Deploy','var'))
    % 如果内存中没有该数据，从硬盘中提取
    if not(exist('.\DataContainer\PossibleAction.mat','file'))% Physical node number
        Possible_Ans_Gen(PhyPara, LogicPara);
    end
    eval('load .\DataContainer\PossibleAction.mat'); % Import substrate topology figures
    %     tic
    %     x_Deploy(:,:,1:length(x_Deploy_a)) = x_Deploy_a;
    %     x_Deploy(:,:,length(x_Deploy_a)+(1:length(x_Deploy_b))) = x_Deploy_b;
    %     x_Deploy(:,:,length(x_Deploy_b)+(1:length(x_Deploy_c))) = x_Deploy_c;
    %     toc
end

alpha = [0, 0.35, 0.65, 1];


x_Deploy = Decode_Deploy_Matrix(Vector_x_Deploy, PhyPara.Ns*2);

for Index = 1:length(alpha)
    t1 = clock;
    LogicPara.alpha = alpha(Index);
    %% 算法1：计算最优矩阵（最优结果）
    CompTimeThreshold = 10^5;
    TranspTimeThreshold = 10^5;
    TotalTimeThreshold = 10^5;
    Indicator = 1;
    if isempty(x_Deploy) == 1
        error('无可行解')
    else
        for i = 1:size(x_Deploy,3)
            Possible_x = reshape(x_Deploy(:,:,i),LogicPara.Nf,2*PhyPara.Ns);
            x_G_tmp = Possible_x(:,1:PhyPara.Ns);
            x_D_tmp = Possible_x(:,PhyPara.Ns+1:end);
            
            %% 目标1：目标是最小化计算时间
            TotalCompTime = sum(sum(LogicPara.CompTime_vCPU.*x_G_tmp)) ...
                + sum(sum(LogicPara.CompTime_FPGA.*x_D_tmp));
            if CompTimeThreshold > TotalCompTime
                CompTimeThreshold = TotalCompTime;
                x_G_Compt = x_G_tmp;
                x_D_Compt = x_D_tmp;
            end
            
            %% 目标2：目标是最小化传输时间
            x_tmp = x_G_tmp+x_D_tmp;
            TotalTransTime = trace(LogicPara.FlowNum*(x_tmp)...
                *ShortestDistMatrix*(x_tmp)')...
                +x_tmp(1,:)*ShortestDistMatrix(:,1)...
                +x_tmp(end,:)*ShortestDistMatrix(:,end);
            if TranspTimeThreshold > TotalTransTime
                TranspTimeThreshold = TotalTransTime;
                x_G_Trans = x_G_tmp;
                x_D_Trans = x_D_tmp;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%% 以下代码验证上述表达式的正确性 %%%%%%%%%%%%%%%%%%
            %         Total_tmp = 0;
            %         for i1 = 1:LogicPara.Nf
            %             for k = 1:LogicPara.Nf
            %                 for j = 1:PhyPara.Ns
            %                     for l = 1:PhyPara.Ns
            %                         x_tmp = x_G_tmp+x_D_tmp;
            %                         Total_tmp = Total_tmp + ...
            %                             x_tmp(i1,j)*x_tmp(k,l)*ShortestDistMatrix(j,l)*LogicPara.FlowNum(i1,k);
            %                     end
            %                 end
            %             end
            %         end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %% 目标3：目标是计算时间和传输时间之和
            TotalTime = (1-LogicPara.alpha)*TotalCompTime + LogicPara.alpha*TotalTransTime;
            if TotalTimeThreshold > TotalTime
                TotalTimeThreshold = TotalTime;
                x_G_Final = x_G_tmp;
                x_D_Final = x_D_tmp;
            end
            %%%%%%%%%%%%%%%%%%%%%%%% 测算时间(调试) %%%%%%%%%%%%%%%%%%%%%%%%%%%
            Ind = floor(i/size(x_Deploy,3)*100);
            if size(x_Deploy,3)>1000 && mod(Ind,Indicator) == 0 && Ind~=0
                Indicator = Indicator +1;
                disp(['当前进度： ',num2str(Ind),'%'])
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
    Opt_ComptTime(Index) = CompTimeThreshold;
    Opt_TransTime(Index) = TranspTimeThreshold;
    Opt_TotalTime(Index) = TotalTimeThreshold;
    t2 = clock;
    Opt_ExcutionTime(1,Index) = etime(t2,t1);
end
clear Vector_x

TotalTime = zeros(5,length(alpha));
%% 算法2：启发式算法针对目标1_最小化计算时延
for Index = 1:length(alpha)
    t1 = clock;
    LogicPara.alpha = alpha(Index);
    [x_Deploy_Algorithm1] = Min_Compt_Delay_Heuristic(PhyPara, LogicPara);
    Total_Comp_Time_Algorithm1 = sum(sum(x_Deploy_Algorithm1.*...
        [LogicPara.CompTime_vCPU,LogicPara.CompTime_FPGA]));
    
    x_tmp = x_Deploy_Algorithm1(:,1:PhyPara.Ns)+x_Deploy_Algorithm1(:,PhyPara.Ns+1:end);
    TotalTime(1,Index) = (1-LogicPara.alpha)*Total_Comp_Time_Algorithm1 ...
        + LogicPara.alpha*(trace(LogicPara.FlowNum*(x_tmp)...
        *ShortestDistMatrix*(x_tmp)')...
        +x_tmp(1,:)*ShortestDistMatrix(:,1)...
        +x_tmp(end,:)*ShortestDistMatrix(:,end));
    t2 = clock;
    ExcutionTime(1,Index) = etime(t2,t1);
end

%% 算法3：启发式算法针对目标2_最小化传输时延
for Index = 1:length(alpha)
    t1 = clock;
    LogicPara.alpha = alpha(Index);
    [x_Deploy_Algorithm2] = Min_Transport_Delay_Heuristic(PhyPara, LogicPara,ShortestDistMatrix);
    Total_Comp_Time_Algorithm2 = sum(sum(x_Deploy_Algorithm2.*...
        [LogicPara.CompTime_vCPU,LogicPara.CompTime_FPGA]));
    
    x_tmp = x_Deploy_Algorithm2(:,1:PhyPara.Ns)+x_Deploy_Algorithm2(:,PhyPara.Ns+1:end);
    TotalTime(2,Index) = (1-LogicPara.alpha)*Total_Comp_Time_Algorithm2 ...
        + LogicPara.alpha*(trace(LogicPara.FlowNum*(x_tmp)...
        *ShortestDistMatrix*(x_tmp)')...
        +x_tmp(1,:)*ShortestDistMatrix(:,1)...
        +x_tmp(end,:)*ShortestDistMatrix(:,end));
    t2 = clock;
    ExcutionTime(2,Index) = etime(t2,t1);
end


%% 算法4：遗传算法解决目标1+目标2问题
for Index = 1:length(alpha)
    t1 = clock;
    LogicPara.alpha = alpha(Index);
    [x_Deploy_Algorithm3] = Genetic_Algorithm(PhyPara, LogicPara);
    Total_Comp_Time_Algorithm3 = sum(sum(x_Deploy_Algorithm3.*...
        [LogicPara.CompTime_vCPU,LogicPara.CompTime_FPGA]));
    
    x_tmp = x_Deploy_Algorithm3(:,1:PhyPara.Ns)+x_Deploy_Algorithm3(:,PhyPara.Ns+1:end);
    TotalTime(3,Index) = (1-LogicPara.alpha)*Total_Comp_Time_Algorithm3 ...
        + LogicPara.alpha*(trace(LogicPara.FlowNum*(x_tmp)...
        *ShortestDistMatrix*(x_tmp)')...
        +x_tmp(1,:)*ShortestDistMatrix(:,1)...
        +x_tmp(end,:)*ShortestDistMatrix(:,end));
    t2 = clock;
    ExcutionTime(3,Index) = etime(t2,t1);
end



%% 算法5： First Fit 算法，解决目标1+目标2问题
for Index = 1:length(alpha)
    t1 = clock;
    LogicPara.alpha = alpha(Index);
    [x_Deploy_Algorithm4] = FirstFitAlgorithm(PhyPara, LogicPara);
    Total_Comp_Time_Algorithm4 = sum(sum(x_Deploy_Algorithm4.*...
        [LogicPara.CompTime_vCPU,LogicPara.CompTime_FPGA]));
    
    x_tmp = x_Deploy_Algorithm4(:,1:PhyPara.Ns)+x_Deploy_Algorithm4(:,PhyPara.Ns+1:end);
    TotalTime(4,Index) = (1-LogicPara.alpha)*Total_Comp_Time_Algorithm4 ...
        + LogicPara.alpha*(trace(LogicPara.FlowNum*(x_tmp)...
        *ShortestDistMatrix*(x_tmp)')...
        +x_tmp(1,:)*ShortestDistMatrix(:,1)...
        +x_tmp(end,:)*ShortestDistMatrix(:,end));
    t2 = clock;
    ExcutionTime(4,Index) = etime(t2,t1);
end

%% 算法6： 启发式算法，解决目标3问题
TotalTime(5,:) = min(TotalTime(1,:),TotalTime(2,:));
ExcutionTime(5,:) = ExcutionTime(1,:) + ExcutionTime(2,:);
eval(['save ./DataContainer/FinalData.mat alpha' ,...
    ' Opt_TotalTime TotalTime Opt_ExcutionTime ExcutionTime'])

