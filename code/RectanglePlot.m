function [ img ] = RectanglePlot(img,rct_idx )
%RECTANGLEPLOT Summary of this function goes here
%   Detailed explanation goes here
[xs,ys] = BorderRevised(round(rct_idx),img,0 );
img(ys(1),xs,1)=255;
img(ys(1),xs,2)=0;
img(ys(1),xs,3)=0;
img(ys(size(ys,2)),xs,1)=255;
img(ys(size(ys,2)),xs,2)=0;
img(ys(size(ys,2)),xs,3)=0;
img(ys,xs(1),1)=255;
img(ys,xs(1),2)=0;
img(ys,xs(1),3)=0;
img(ys,xs(size(xs,2)),1)=255;
img(ys,xs(size(xs,2)),2)=0;
img(ys,xs(size(xs,2)),3)=0;

end

