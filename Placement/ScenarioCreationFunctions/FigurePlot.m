%% Figure Plot
clc
close all
eval('load .\DataContainer\FinalData.mat')
%%%%%%%%%%%%%%%%%%%%%%%%%%% ��ͼ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
plot(alpha, Opt_TotalTime,'r^-'); hold on
plot(alpha, TotalTime1, 'b*-');
plot(alpha, TotalTime2, 'bs-');
plot(alpha, TotalTime3, 'bo-');
plot(alpha, TotalTime4, 'k--'); 
grid on
legend('���ű����㷨','����ʽ����С����ʱ��','����ʽ����С����ʱ��',...
    '�Ŵ��㷨����СE2Eʱ��','̰���㷨FF:��СE2Eʱ��');
xlabel('\alpha');
ylabel('E2Eʱ��');

hold off