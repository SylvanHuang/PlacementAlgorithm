%% Figure Plot
clc
close all
eval('load .\DataContainer\FinalData.mat')
%%%%%%%%%%%%%%%%%%%%%%%%%%% 作图 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
plot(alpha, Opt_TotalTime,'r^-'); hold on
plot(alpha, TotalTime1, 'b*-');
plot(alpha, TotalTime2, 'bs-');
plot(alpha, TotalTime3, 'bo-');
plot(alpha, TotalTime4, 'k--'); 
grid on
legend('最优遍历算法','启发式：最小计算时延','启发式：最小传输时延',...
    '遗传算法：最小E2E时延','贪婪算法FF:最小E2E时延');
xlabel('\alpha');
ylabel('E2E时延');

hold off