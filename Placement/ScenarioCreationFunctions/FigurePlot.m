%% Figure Plot
clc
clear all
close all
eval('load .\DataContainer\FinalData.mat')
%%%%%%%%%%%%%%%%%%%%%%%%%%% 作图 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
b = bar([Opt_TotalTime(1:length(alpha))'*10, TotalTime([3 5 4],:)'*10]); hold on
% set(gca, 'XTickLabel',{['无传输延迟';'(\alpha = 0)'],'传输时延占比较小\alpha = 0.35',...
%     '计算时延占比较小\alpha = 0.65', '无计算延迟（\alpha = 1）'})
set(gca, 'XTickLabel',{['无传输延迟\newline',' （\alpha = 0）'],['传输延迟占比较小\newline','   （\alpha = 0.35）'],...
    ['处理延迟占比较小\newline','   （\alpha = 0.65）'], ['无处理延迟\newline',' （\alpha = 1）']})

xlabel('场景');
ylabel('端到端时延(us)');
legend('最优算法','迭代算法','启发算法','贪婪算法')
hold off

vpa([Opt_ExcutionTime*10;ExcutionTime([3],:);...
ExcutionTime([5,4],:)],4)