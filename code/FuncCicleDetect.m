%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Detect the Circle Hongh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function para = FuncCicleDetect(img)
% para:��⵽��Բ��Բ�ġ��뾶

%ģ��Բ�Ĳ���
circle_hough = im2bw(img, graythresh(img));

[m,n,l] = size(circle_hough);
if l>1
    circle_hough = rgb2gray(circle_hough);
end
BW = edge(circle_hough,'sobel');
step_r = 1;
step_angle = 0.1;
minr = 20;
maxr = 30;
thresh = 0.5;

[hough_space,hough_circle,para] = FuncHoughCircle(BW,step_r,step_angle,minr,maxr,thresh);


% figure(2),imshow(img,[]);
% hold on;
% 
% for index = 1 : size(para, 1)   
%     plot(para(index,2), para(index,1), 'r+');
% 
%     t=0:0.01*pi:2*pi;
%     x=cos(t).*para(index,3)+para(index,2);
%     y=sin(t).*para(index,3)+para(index,1);
%     plot(x,y,'r-');      
% end



% ����Բ������λ��
% xcentre_template = (templateCircleParaXYR(1,1) + templateCircleParaXYR(2,1)) / 2;
% ycentre_template = (templateCircleParaXYR(1,2) + templateCircleParaXYR(2,2)) / 2;

% ģ����м�λ��
xcentre_template = m / 2;
ycentre_template = n / 2;

end
