function [ drawback_flag ] = BoundaryHausdorffDist( template_img,drawback_img,source_img)


drawback_boundary = bwperim(drawback_img);
boundary_mask =zeros(size(drawback_boundary));
boundary_mask(2:size(boundary_mask,1)-1,2:size(boundary_mask,2)-1)=1;
%与模板相交的为模板对应边缘，剩余未相交的为检测图像边缘
template_boundary1 = drawback_boundary&(bwperim(~template_img));
template_boundary2 = drawback_boundary&(bwperim(template_img));
% if size(find(template_boundary1),1)>size(find(template_boundary2),1)
%     template_boundary = template_boundary1;
% else
%     template_boundary = template_boundary2;
% end
template_boundary = (template_boundary1 | template_boundary2)&boundary_mask;
[template_boundary_idx(:,1),template_boundary_idx(:,2)] = find(template_boundary);

source_boundary1 = drawback_boundary&(bwperim(~source_img));
source_boundary2 = drawback_boundary&(bwperim(source_img));
% if size(find(source_boundary1),1)>size(find(source_boundary2),1)
%     source_boundary = source_boundary1;
% else
%     source_boundary = source_boundary2;
% end
source_boundary = (source_boundary1 | source_boundary2)&boundary_mask;
[source_boundary_idx(:,1),source_boundary_idx(:,2)]= find(source_boundary);
% figure(2);
% imshow(drawback_img);hold on;
% plot(source_boundary_idx(:,2),source_boundary_idx(:,1),'r*');
% plot(template_boundary_idx(:,2),template_boundary_idx(:,1),'g+');
% hold off;
[tmodel,template_idx,source_idx,source_correspondence,transdist] = ICP(template_boundary_idx ,source_boundary_idx,20,0);
 [ mhd ] = ModHausdorffDist( source_boundary_idx, template_idx );
drawback_flag=0;
if mhd >=1.78
    drawback_flag=1;
end