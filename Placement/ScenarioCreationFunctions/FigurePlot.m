%% Figure Plot
clc
clear all
close all
eval('load .\DataContainer\FinalData.mat')
%%%%%%%%%%%%%%%%%%%%%%%%%%% ��ͼ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
b = bar([Opt_TotalTime(1:length(alpha))'*10, TotalTime([3 5 4],:)'*10]); hold on
% set(gca, 'XTickLabel',{['�޴����ӳ�';'(\alpha = 0)'],'����ʱ��ռ�Ƚ�С\alpha = 0.35',...
%     '����ʱ��ռ�Ƚ�С\alpha = 0.65', '�޼����ӳ٣�\alpha = 1��'})
set(gca, 'XTickLabel',{['�޴����ӳ�\newline',' ��\alpha = 0��'],['�����ӳ�ռ�Ƚ�С\newline','   ��\alpha = 0.35��'],...
    ['�����ӳ�ռ�Ƚ�С\newline','   ��\alpha = 0.65��'], ['�޴����ӳ�\newline',' ��\alpha = 1��']})

xlabel('����');
ylabel('�˵���ʱ��(us)');
legend('�����㷨','�����㷨','�����㷨','̰���㷨')
hold off

vpa([Opt_ExcutionTime*10;ExcutionTime([3],:);...
ExcutionTime([5,4],:)],4)