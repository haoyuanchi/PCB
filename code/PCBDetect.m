function drawback_info = PCBDetect(source,template,visible,issavefig,log_folder_name,output_folder_name)
%  comapre source image to the template iamge in order to detect the
%  darwbacks in source image. the locations and classes of darwbacks would
%  be recorded in the log file stored under the folder specificated be
%  log_folder_name. All the drawbacks' image will be stored under the
%  folder specificated be output_folder_name.
% 
% source: input image
% template: template image
% visible: visibility of the temporary results 
% output_folder_name: where drawback images are stored
% log_folder_name: where log file is stored, if it's not assigned, log files will be stored under the output folder.

% drawback_info: output structure which contain the types and locations of drawbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% author: Donghao Shen
% log:
% Created:2016/6/4 
% Modify:2016/6/15, 2016/6/23, 2016/7/3, 2016/7/7, 2016/7/14, 2016/7/19, 2016/7/20, 

up_start_pix = 2750;
down_stop_pix = 14000;
up_interval_pix = 400;
down_interval_pix = 400;

%% initialize the file path
path_prefix = datestr(now,30);
output_folder_name = [output_folder_name,'/',path_prefix];
log_folder_name = [log_folder_name,'/',path_prefix];
if exist(output_folder_name,'dir')==0
   mkdir(output_folder_name);
end
output_path=['./',output_folder_name,'/'];

if nargin <=3
    log_file_name=['./',output_folder_name,'/log.txt'];
else
    if exist(log_folder_name,'dir')==0
        mkdir(log_folder_name);
    end
    log_file_name=['./',log_folder_name,'/log.txt'];
end

%% convert RGB image to gary image
source_origin = source;
if size(source_origin,3)>1
	source_gray=rgb2gray(source_origin);
else 
    source_gray=source_origin;
end

template_origin = template; 
if size(template_origin,3)>1
	template_gray=rgb2gray(template_origin);
else 
    template_gray=template_origin;
end

%% convert gary image to binary image
fprintf(1,'image  binary\n');
source_bw = im2bw(source_gray,graythresh(source_gray));
template_bw = im2bw(template_gray,graythresh(template_gray));

%% performs a logical exclusive-OR of source_bw and template_bw
fprintf(1,'Exclusive-OR\n');
drawback_candidate = xor(template_bw,source_bw);
% 
boundary_mask = zeros(size(template_bw));
boundary_mask(up_start_pix+400:down_stop_pix-400,200:size(template_bw,2)-200)=1;
drawback_candidate = drawback_candidate&boundary_mask;

%% morphology filtering
% drawback = bwmorph(drawback_candidate,'open');
se1 = strel('disk',2);
% se2 = strel('diamond',2);
% drawback = imclose(imopen(drawback_candidate,se2),se1);
drawback = imopen(drawback_candidate,se1);
% drawback = imerode(imerode(imerode(drawback_candidate,strel('disk',0)),strel('disk',1)),strel('disk',0));
drawback = bwareaopen(drawback,3);
% figure();imshow(drawback);
% imwrite(drawback,[output_path,'drawback.bmp']);

%% connectivity detection ans label
[drawback_label,drawback_num] = bwlabel(drawback);
% figure();imshow(drawback_label);
fprintf(1,'%d Suspected defect locations are found\n',drawback_num);

%% locate the suspected drawback
drawback_rect  = regionprops(drawback_label, 'BoundingBox');
for i=1:drawback_num
    drawback_box_index = drawback_rect(i).BoundingBox;   
end

%% drawback classify

extra_pixel = 4.5;
drawback_num_output=0;

printf_count=0;
fprintf(1,'drawback classifying\n');
if visible==0
    drawback_show_handle=figure('visible','off');
else
    drawback_show_handle=figure('visible','on');
end
for drawback_idx=1:drawback_num
    
    fprintf(1, repmat('\b',1,printf_count));
    printf_count=fprintf(1,'current progress rate is : %.2f%%, %d drawback found',drawback_idx/drawback_num*100,drawback_num_output);
    
    drawback_box_index = drawback_rect(drawback_idx).BoundingBox;
    [xs,ys] = BorderRevised(drawback_box_index,template_bw,extra_pixel )  ;
    % cut out the needed part from all the images
    template_box = template_bw(ys,xs);
    source_box = source_bw(ys,xs);
    template_gary_box = template_gray(ys,xs);
    source_gary_box = source_gray(ys,xs);
    
    drawback_filtered_box =~( drawback_label(ys,xs)-drawback_idx)  ;
    drawback_centroid  = regionprops(drawback_filtered_box, 'centroid');
    drawback_box_label= bwlabel(xor(template_box,source_box));
    drawback_centroid_label = drawback_box_label(round(drawback_centroid.Centroid(2)),round(drawback_centroid.Centroid(1)));
    drawback_box = ~(drawback_box_label-drawback_centroid_label);
%     set(groot, 'CurrentFigure', drawback_show_handle);
    set(0, 'CurrentFigure', drawback_show_handle);
    subplot(1,3,1);imshow(source_gary_box,[]);title('输入图像局部');
    subplot(1,3,2);imshow(template_gary_box,[]);title('模板图像局部');
    subplot(1,3,3);imshow(drawback_box,[]);title(num2str(drawback_idx));
    % classifying
    drawback_class = DrawbackClassify(template_box,source_box,drawback_box,source_gary_box,template_gary_box,output_path,drawback_idx);
    if ~strcmp(drawback_class, '其他')
        drawback_num_output=drawback_num_output+1;
        drawback_info{drawback_num_output}.rect=drawback_box_index;
        drawback_info{drawback_num_output}.type=drawback_class;
        drawback_info{drawback_num_output}.source=source_gary_box ;
        drawback_info{drawback_num_output}.template=template_gary_box ;
        drawback_gary = double(source_box)+double(~drawback_box)/2;
        drawback_info{drawback_num_output}.drawback=drawback_gary ;
    end
end

fprintf(1,'\n');

fprintf(1,'%d defect locations are found\n',drawback_num_output);


%% saving
fprintf(1,'saving\n');
if issavefig ==1
    imwrite(drawback_candidate,[output_path,'xor.bmp']);
    imwrite(drawback,[output_path,'drawback.bmp']);
    if visible==0
        result_fig_handle=figure('visible','off');
    else
        result_fig_handle=figure('visible','on');
    end
%     imshow(source_gray);
    
    if visible==0
        drawback_fig_handle=figure('visible','off');
    else
        drawback_fig_handle=figure('visible','on');
    end
    result_RGB = cat(3,source_gray,source_gray,source_gray);
    for drawback_idx=1:drawback_num_output
        set(0,'CurrentFigure',result_fig_handle);
        rectangle('Position',drawback_info{drawback_idx}.rect,'EdgeColor','r');
        result_RGB = RectanglePlot(result_RGB,drawback_info{drawback_idx}.rect);
        set(0,'CurrentFigure',drawback_fig_handle);
        subplot(1,3,1);imshow(drawback_info{drawback_idx}.source,[]);title('输入图像局部');
        subplot(1,3,2);imshow(drawback_info{drawback_idx}.template,[]);title('模板图像局部');
        subplot(1,3,3);imshow(drawback_info{drawback_idx}.drawback,[]);title('不同区域');
        title(['缺陷编号:',num2str(drawback_idx)]);
%         print(drawback_fig_handle,[output_path,'drawback',num2str(drawback_idx),'_',drawback_info{drawback_idx}.type],'-dbitmap');
%         saveas(drawback_fig,[output_path,'drawback',num2str(drawback_idx),'_',drawback_info{drawback_idx}.type,'.bmp']);
%         drawback_fig=getimage(drawback_fig_handle); % 获取坐标系中的图像文件数据
%         imwrite(drawback_fig,[output_path,'drawback',num2str(drawback_idx),'_',drawback_info{drawback_idx}.type,'.bmp']);
        drawback_fig=frame2im(getframe(drawback_fig_handle)); % 获取坐标系中的图像文件数据
        imwrite(drawback_fig,[output_path,'drawback',num2str(drawback_idx),'_',drawback_info{drawback_idx}.type,'.bmp']);
    end
    imwrite(result_RGB,[output_path,'result','.bmp']);
end

% result_fig=getimage(result_fig_handle); % 获取坐标系中的图像文件数据
% imwrite(result_fig,[output_path,'result','.bmp']);
% result_fig=frame2im(getframe(result_fig_handle)); % 获取坐标系中的图像文件数据
% imwrite(result_fig,[output_path,'result','.bmp']);
% print(result_fig_handle,[output_path,'result'],'-dbitmap');
% saveas(h,[output_path,'result','.bmp']);

log_file_p=fopen(log_file_name,'w');
for drawback_idx=1:drawback_num_output
    fprintf(log_file_p,[num2str(drawback_idx) '\t']);
    fprintf(log_file_p,[drawback_info{drawback_idx}.type '\t']);
    fprintf(log_file_p,[num2str(drawback_info{drawback_idx}.rect(1)) '\t']);
    fprintf(log_file_p,[num2str(drawback_info{drawback_idx}.rect(2)) '\t']);
    fprintf(log_file_p,[num2str(drawback_info{drawback_idx}.rect(3)) '\t']);
    fprintf(log_file_p,[num2str(drawback_info{drawback_idx}.rect(4)) '\r\n']);
end
fclose(log_file_p);

fprintf(1,'done\n');
 
