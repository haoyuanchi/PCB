function drawback_class = DrawbackClassify(template_img, source_img,drawback_img,source_gary_box,template_gary_box,output_path,drawback_idx )
% template_img: ģ��ͼ��
% source_img: ����ͼ��
% drawback_img: ȱ��ͼ��
% if visible==0
%     drawback_fig=figure('visible','off');
% else
%     drawback_fig=figure('visible','on');
% end

drawback_pixel = bwmorph(drawback_img,'clean'); 
% drawback_pixel = drawback_img;
[drawback_pixel_row,drawback_pixel_col] = find(drawback_pixel);

[source_lable,source_lable_num] = bwlabel(source_img);
source_lable_num = source_lable_num+1;
drawback_gray_sum = 0;
for i=1:size(drawback_pixel_row,1)
    source_lable(drawback_pixel_row(i),drawback_pixel_col(i)) = source_lable_num;
end
%��ʾȱ������
% figure();
% subplot(2,2,1);imshow(source_img);title('����ͼ��ֲ�');
% subplot(2,2,2);imshow(template_img);title('ģ��ͼ��ֲ�');
% subplot(2,2,3);imshow(drawback_pixel);title('��ͬ����');
% subplot(2,2,4);imshow(source_lable,[]);

for i=1:size(drawback_pixel_row,1)  
    drawback_gray_sum = source_img(drawback_pixel_row(i),drawback_pixel_col(i)) + drawback_gray_sum;
end
drawback_gray_average = drawback_gray_sum/size(drawback_pixel_row,1);

% %% ȱ����Χ�����һ����
% [ neighbor_consist ] = NeighborConsistDecide( source_lable,drawback_pixel,source_lable_num);
% if (neighbor_consist > 0.9) && (drawback_gray_average > 0.5)
%     [ area_consist ] = AreaConsistDecide( source_lable,drawback_img,template_img );
%     if area_consist > 0.1
%         drawback_class = 'ͭȱ��';
%         figure();
%         subplot(2,2,1);imshow(source_img);title('����ͼ��ֲ�');
%         subplot(2,2,2);imshow(template_img);title('ģ��ͼ��ֲ�');
%         subplot(2,2,3);imshow(drawback_pixel);title('��ͬ����');
%         subplot(2,2,4);imshow(source_lable,[]);title(drawback_class);
% 
%         return
%     else 
%         drawback_class = '���';
%         figure();
%         subplot(2,2,1);imshow(source_img);title('����ͼ��ֲ�');
%         subplot(2,2,2);imshow(template_img);title('ģ��ͼ��ֲ�');
%         subplot(2,2,3);imshow(drawback_pixel);title('��ͬ����');
%         subplot(2,2,4);imshow(source_lable,[]);title(drawback_class);
% 
%         return
%     end
% elseif (neighbor_consist > 0.9) && (drawback_gray_average < 0.5)
%      [ area_consist ] = AreaConsistDecide( source_lable,drawback_img,template_img );
%     if area_consist > 0.1
%         drawback_class = '����';
%         figure();
%         subplot(2,2,1);imshow(source_img);title('����ͼ��ֲ�');
%         subplot(2,2,2);imshow(template_img);title('ģ��ͼ��ֲ�');
%         subplot(2,2,3);imshow(drawback_pixel);title('��ͬ����');
%         subplot(2,2,4);imshow(source_lable,[]);title(drawback_class);
%         return
%     else 
%         drawback_class = '¶ͭ';
%         title(drawback_class);
%         return
%     end
% end
% 
% %% �߽����ͨ��
% [ boundary_continuity ] = BoundaryContinuityDecide( source_lable,drawback_img );
% if (boundary_continuity > 2) && (drawback_gray_average <0.5)    
%     drawback_class = '��·';
%     figure();
%     subplot(2,2,1);imshow(source_img);title('����ͼ��ֲ�');
% 	subplot(2,2,2);imshow(template_img);title('ģ��ͼ��ֲ�');
% 	subplot(2,2,3);imshow(drawback_pixel);title('��ͬ����');
% 	subplot(2,2,4);imshow(source_lable,[]);title(drawback_class);
%     return
% elseif (boundary_continuity > 2) && (drawback_gray_average >0.5)  
%     drawback_class = '��·';
%     figure();
% 	subplot(2,2,1);imshow(source_img);title('����ͼ��ֲ�');
% 	subplot(2,2,2);imshow(template_img);title('ģ��ͼ��ֲ�');
% 	subplot(2,2,3);imshow(drawback_pixel);title('��ͬ����');
%     subplot(2,2,4);imshow(source_lable,[]);title(drawback_class);
%     return
% end
%% compare the boundary of source and template image
% 
source_corner=corner(source_img,'QualityLevel',0.48);
template_corner=corner(template_img,'QualityLevel',0.48);

[ contour_curvature_diff_avr,contour_curvature_diff_ratio,contour_curvature_diff_count,contour_transdist] = BoundaryCurvatureCompare( template_img,drawback_img,source_img,source_gary_box,template_gary_box);
 [ contour_space_diff_var,contour_space_diff_ratio,contour_transdist] = BoundarySpaceCompare( template_img,drawback_img,source_img,source_gary_box,template_gary_box);
% change_ranpe = (((abs(contour_curvature_diff_avr) > 1.2)  && (contour_curvature_diff_ratio>0.5 )) || ...
%     ((abs(contour_curvature_diff_avr) > 0.6)  && (contour_curvature_diff_ratio>0.4 ) && contour_curvature_diff_count>=20) ||  contour_transdist >=5);
% curvature_change_ranpe = (((abs(contour_curvature_diff_avr) > 1.2)  && (contour_curvature_diff_ratio>0.45)) || contour_transdist >=5);
space_change_ranpe = (contour_space_diff_var>3 || contour_transdist >=5);
if  space_change_ranpe && abs(size(template_corner,1)-size(source_corner,1))>=0 && (drawback_gray_average <=0.5)
    drawback_class = 'ë��';   
%     subplot(2,2,1);imshow(source_img);title('����ͼ��ֲ�');
%     subplot(2,2,2);imshow(template_img);title('ģ��ͼ��ֲ�');
%     subplot(2,2,3);imshow(drawback_pixel);title('��ͬ����');
%     subplot(2,2,4);imshow(source_lable,[]);
%     title([drawback_class,'avr',num2str(contour_curvature_diff_avr),'ratio',num2str(contour_curvature_diff_ratio),'dist',num2str(contour_transdist)]);
%     print(drawback_fig,[output_path,'drawback',num2str(drawback_idx),'_',drawback_class],'-djpeg');
    return
elseif space_change_ranpe  && abs(size(template_corner,1)-size(source_corner,1))>=0 && (drawback_gray_average >0.5)
    drawback_class = 'ȱ��';
%     subplot(2,2,1);imshow(source_img);title('����ͼ��ֲ�');
%     subplot(2,2,2);imshow(template_img);title('ģ��ͼ��ֲ�');
%     subplot(2,2,3);imshow(drawback_pixel);title('��ͬ����');
%     subplot(2,2,4);imshow(source_lable,[]);
%     title([drawback_class,'avr',num2str(contour_curvature_diff_avr),'ratio',num2str(contour_curvature_diff_ratio),'dist',num2str(contour_transdist)]);
%     print(drawback_fig,[output_path,'drawback',num2str(drawback_idx),'_',drawback_class],'-djpeg');
    return
end
% 
drawback_class='����';%������ָ��������޷����������


% subplot(2,2,1);imshow(source_img);title('����ͼ��ֲ�');
% subplot(2,2,2);imshow(template_img);title('ģ��ͼ��ֲ�');
% subplot(2,2,3);imshow(drawback_pixel);title('��ͬ����');
% subplot(2,2,4);imshow(source_lable,[]);
% title([drawback_class,'avr',num2str(contour_curvature_diff_avr),'ratio',num2str(contour_curvature_diff_ratio)]);
% print(drawback_fig,[output_path,'drawback',num2str(drawback_idx),'_',drawback_class],'-djpeg');
end