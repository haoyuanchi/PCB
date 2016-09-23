function [theta,T] = ICP2D(x,y)

C = mean(x,1);

v = x;
v(:,1) = v(:,1)-C(1);
v(:,2) = v(:,2)-C(2);

w = y;
w(:,1) = C(1) - y(:,1);
w(:,2) = C(2) - y(:,2);

wb = mean(w,1);

% w(:,1) = w(:,1) - wb(1);
% w(:,2) = w(:,2) - wb(2);
% 
% M = v' * w;
% 
% A = -M(1,1)-M(2,2);
% B = M(1,2)-M(2,1);

% theta = atan2(-B,A);
 theta=0;
T = -wb;