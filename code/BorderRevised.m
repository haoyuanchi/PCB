function [xs,ys] = BorderRevised(RectPosition,im,EdgeWidth)  

ys = RectPosition(2)-EdgeWidth:RectPosition(2)+RectPosition(4)+EdgeWidth;
xs = RectPosition(1)-EdgeWidth:RectPosition(1)+RectPosition(3)+EdgeWidth;
xs(xs < 1) = 1;
ys(ys < 1) = 1;
xs(xs > size(im,2)) = size(im,2);
ys(ys > size(im,1)) = size(im,1);