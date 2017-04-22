%% VNF流示意图
function Flow_Illustration(LogicPara)
FlowSequency = LogicPara.FlowSequency;
FlowName = LogicPara.FlowName;
vPosition = strfind(FlowName,'v');
vPosition = [vPosition,length(FlowName)+1];
Ns = max(FlowSequency);
% Check the number of labels 
if length(vPosition)-1 ~= Ns
    error('Label Number Incorrect');
end

LogicNodeLocation = [0 0; 0 1; 1 1; 1 0; 2 0; 3 0];
%%%%%%%%%%%%%%%%%%%%%%%%%% Figure Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:Ns
    plot(LogicNodeLocation(i,1), LogicNodeLocation(i,2), 'ro'); hold on
    Label = FlowName(vPosition(i):vPosition(i+1)-1);
    text(LogicNodeLocation(i,1)+0.05, LogicNodeLocation(i,2)+0.05, ...
        num2str(i));
end
for i = 1:length(FlowSequency)-1
    SourceNodeInd = FlowSequency(i);
    DestNodeInd = FlowSequency(i+1);
    SourceNodeLoc = LogicNodeLocation(SourceNodeInd,:); % 流上一个节点的地址
    DestNodeLoc = LogicNodeLocation(DestNodeInd,:); % 流下一个节点的地址
    draw_arrow(SourceNodeLoc,DestNodeLoc,.2,0.8);
end
axis([-0.5 3.5 -0.2 1.2])
hold off