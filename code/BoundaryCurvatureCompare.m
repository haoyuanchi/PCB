function [ contour_curvature_diff_avr,contour_curvature_diff_ratio,contour_curvature_diff_count,contour_transdist] = BoundaryCurvatureCompare( template_img,drawback_img,source_img,source_gary_box,template_gary_box)
%BOUNDARYARCCAL Summary of this function goes here


%计算梯度方向
[source_lx,source_ly] = gradient(double(source_gary_box));
[template_lx,template_ly] = gradient(double(template_gary_box));
drawback_boundary = bwperim(drawback_img);


%与模板相交的为模板对应边缘，剩余未相交的为检测图像边缘
template_boundary1 = drawback_boundary&(bwperim(~template_img));
template_boundary2 = drawback_boundary&(bwperim(template_img));
% if sum(sum(template_boundary))==0
%      template_boundary = drawback_boundary&(bwperim(template_img));
% end
if size(find(template_boundary1),1)>size(find(template_boundary2),1)
    template_boundary = template_boundary1;
else
    template_boundary = template_boundary2;
end
[template_boundary_idx(:,1),template_boundary_idx(:,2)] = find(template_boundary);
% source_boundary = drawback_boundary&(~template_boundary);
source_boundary1 = drawback_boundary&(bwperim(~source_img));
source_boundary2 = drawback_boundary&(bwperim(source_img));

if size(find(source_boundary1),1)>size(find(source_boundary2),1)
    source_boundary = source_boundary1;
else
    source_boundary = source_boundary2;
end
[source_boundary_idx(:,1),source_boundary_idx(:,2)]= find(source_boundary);
% figure();
% imshow(drawback_img);hold on;
% plot(source_boundary_idx(:,2),source_boundary_idx(:,1),'r*');
% plot(template_boundary_idx(:,2),template_boundary_idx(:,1),'g+');
% % 
% template_boundary = bwperim(template_img)&(~bwperim(ones(size(template_img))));
% [template_boundary_idx(:,1),template_boundary_idx(:,2)] = find(template_boundary);
% source_boundary =  bwperim(source_img)&(~bwperim(ones(size(template_img))));
% [source_boundary_idx(:,1),source_boundary_idx(:,2)]= find(source_boundary);

%找对应点
[tmodel,template_idx,source_idx,source_correspondence,transdist] = ICP(template_boundary_idx ,source_boundary_idx,10,0);


%计算对应点梯度方向差
contour_curvature_diff_sum=0;
contour_curvature_diff_count=0;
if isempty(source_correspondence)
    contour_curvature_diff_avr=0;
    contour_curvature_diff_ratio=0;
    contour_transdist=0;
    return;
end
for i=1:size(source_correspondence,2)
%     template_idx_near = [floor(template_idx(i,1)),floor(template_idx(i,2))];
%     if template_idx_near(1) <=0
%         template_idx_near(1)=1
%     elseif template_idx_near(2) <=0
%         template_idx_near(2)=1
%     end
    source_idx_near = [floor(source_boundary_idx(i,1)),floor(source_boundary_idx(i,2))];
    if source_idx_near(1) <=0
        source_idx_near(1)=1;
    elseif source_idx_near(2) <=0
        source_idx_near(2)=1;
    end
    template_idx_near=template_boundary_idx(source_correspondence(i),:);
    contour_curvature_diff(i)=abs(atan(template_ly(template_idx_near(1),template_idx_near(2))/template_lx(template_idx_near(1),template_idx_near(2)))...
        -atan(source_ly(source_idx_near(1),source_idx_near(2))/source_lx(source_idx_near(1),source_idx_near(2))));
    if isnan(contour_curvature_diff(i)) || isinf(contour_curvature_diff(i))
        contour_curvature_diff(i)=0;
    end
    if contour_curvature_diff(i)>pi/12
        contour_curvature_diff_sum = contour_curvature_diff_sum+contour_curvature_diff(i);
        contour_curvature_diff_count = contour_curvature_diff_count+1;
    end
end

% for i=2:size(contour_index,1)
%    contour_curvature
% end
% contour_curvature_var = var(contour_curvature);
% contour_curvature_diff_avr=sum(contour_curvature_diff)/size(template_idx,1);
% contour_curvature_diff_avr=sum(contour_curvature_diff)/(size(source_correspondence,2)-size(find(contour_curvature_diff<pi/8),2));

if contour_curvature_diff_count==0
    contour_curvature_diff_avr = 0;
else
    contour_curvature_diff_avr=contour_curvature_diff_sum/ contour_curvature_diff_count;
end
contour_curvature_diff_ratio=contour_curvature_diff_count/size(source_correspondence,2);
contour_transdist = abs((transdist(1)^2+transdist(1)^2)^(1/2));
end