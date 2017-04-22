function out = draw_arrow(startpoint,endpoint,headsize,linesize)
%by Ryan Molecke 
% accepts two [x y] coords and one double headsize
if (headsize<=0 || headsize >1 || linesize>1 || linesize<=0)
    error('Wrong Parameters')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a0 = startpoint(1); b0 = startpoint(2);
a1 = endpoint(1); b1 = endpoint(2);
linesize = (1-linesize)/2;
startpoint = [a0 + linesize*(a1-a0), b0 + linesize*(b1-b0)];
endpoint = [a1 - linesize*(a1-a0), b1 - linesize*(b1-b0)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
v1 = headsize*(startpoint-endpoint)/2.5; 
theta = 22.5*pi/180; 
theta1 = -1*22.5*pi/180; 
rotMatrix = [cos(theta)  -sin(theta) ; sin(theta)  cos(theta)];
rotMatrix1 = [cos(theta1)  -sin(theta1) ; sin(theta1)  cos(theta1)];  
v2 = v1*rotMatrix; 
v3 = v1*rotMatrix1; 
x1 = endpoint;
x2 = x1 + v2; 
x3 = x1 + v3; 
hold on; 
fill([x1(1) x2(1) x3(1)],[x1(2) x2(2) x3(2)],[0 0 0]);% this fills the arrowhead (black) 
plot([startpoint(1) endpoint(1)],[startpoint(2) endpoint(2)],'linewidth',1,'color',[0 0 0]);