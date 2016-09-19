close all;
clear all;
clc;

is_debug = 0;
is_show_figure = 0;
is_need_rotate = 1;

%%%%%%%%%%%%%%%%%%%%
%%    preprocess the image   %%
%%%%%%%%%%%%%%%%%%%%

%% load the image
% image_base='../data/72/';
% img_template =  imread([image_base, 'template_13339.bmp']);
% img_detect =  imread([image_base, 'detect_13329.bmp']);
% template_circle = imread([image_base, 'template_circle.bmp']);

% image_base='/home/hychi/Project/PCB/data/234/Grab/2016-09-09/'; 
image_base='/home/hychi/Project/PCB/data/test/Original/2016-07-12/'; 
img_template_name =  '13000/g.bmp';
img_detect_name =  '13001/g.bmp';

% save figure path% image_base='/home/hychi/Project/PCB/data/234/Grab/2016-09-09/'; 
ind = findstr(img_detect_name, '/');
temp_folder_name = ['temp-', img_detect_name(1: ind(1))];
if exist(temp_folder_name,'dir')==0
   mkdir(temp_folder_name);
end
output_path=['./',temp_folder_name,'/'];

img_template =  imread([image_base, img_template_name]);
img_detect =  imread([image_base, img_detect_name]);
% template_circle = imread(['../data/234/template_circle_234.bmp']);
template_circle = imread(['../data/59/template_circle_59.bmp']);

if is_need_rotate==1
    img_template =  imrotate(img_template, 90, 'bilinear');
    img_detect = imrotate(img_detect, 90, 'bilinear');
end

%  segment the black
% add a func to 
if is_show_figure == 1
    imshow(img_template);
end
img_template = FuncPreprocess(img_template);
img_detect = FuncPreprocess(img_detect);
if is_show_figure == 1
    imshow(img_template);
end

%% detect the matching points rough
matching_points_template = FuncMatchingPointsDetect(img_template, template_circle, is_debug);
matching_points_detect = FuncMatchingPointsDetect(img_detect, template_circle, is_debug);

%% adjust image to rectangle
img_template = FuncAdjustImg(img_template, matching_points_template, template_circle);
img_detect = FuncAdjustImg(img_detect, matching_points_detect, template_circle);

% [hight, width] = size(img_template);
% img_detect = imresize(img_detect, [hight, width]);

% save matching_points_detect matching_points_detect;
% save matching_points_template matching_points_template;
% 
% load matching_points_detect;
% load matching_points_template;


%%%%%%%%%%%%%%%%%%%%
%%    xor the image  


%% detect the matching points rough
matching_points_template = FuncMatchingPointsDetect(img_template, template_circle, is_debug);
matching_points_detect = FuncMatchingPointsDetect(img_detect, template_circle, is_debug);

% incision the pixel according to the matching points
overlap_pixel = 500;
for i = 1 : size(matching_points_detect, 3)
    %% image incision pixel
    if(i == 1)
        x_incision_start = 1;
        x_incision_stop_template = matching_points_template(4,2,i) + overlap_pixel;        
        x_incision_stop_detect = matching_points_detect(4,2,i) + overlap_pixel;        
    elseif(i == size(matching_points_detect, 3))
        x_incision_start = matching_points_template(4,2,i-1) - overlap_pixel;
        x_incision_stop_template = size(img_template, 2);
        x_incision_stop_detect = size(img_detect, 2);
    else
        x_incision_start = matching_points_template(1,2,i) - overlap_pixel;
        x_incision_stop_template = matching_points_template(4,2,i) + overlap_pixel;        
        x_incision_stop_detect = matching_points_detect(4,2,i) + overlap_pixel;        
    end
    
    img_incision_template = img_template(: , x_incision_start : x_incision_stop_template);
    img_incision_detect = img_detect(: , x_incision_start : x_incision_stop_detect);
    match_points_template_temp = [matching_points_template(:,1,i), matching_points_template(:,2,i) - x_incision_start+1];
    match_points_detect_temp = [matching_points_detect(:,1,i), matching_points_detect(:,2,i) - x_incision_start+1];
    
    %% detect mark points 
    mark_points_template = FuncMarksPointsDetect(img_incision_template, match_points_template_temp, template_circle, is_debug, i, 'template');  
    mark_points_detect = FuncMarksPointsDetect(img_incision_detect, match_points_detect_temp, template_circle, is_debug, i, 'detect');   
    
%     % fine adjust the img to the rectangle
%     img_incision_template = FuncFineAdjust(img_incision_template, mark_points_template);
%     img_incision_detect = FuncFineAdjust(img_incision_detect, mark_points_detect);
%     
%    %% detect mark points again
%     mark_points_template = FuncMarksPointsDetect(img_incision_template, match_points_template_temp, template_circle, is_debug, i, 'template');  
%     mark_points_detect = FuncMarksPointsDetect(img_incision_detect, match_points_detect_temp, template_circle, is_debug, i, 'detect');  
    
%     %% icp
%     max_iter = 2000;
%     min_iter = 1000;
%     [R, T] = FuncIcp(mark_points_template, mark_points_detect, max_iter, min_iter);   
%     img_incision_detect = FuncImageTransform(img_incision_detect, R, T);      

    mark_points_img_template = img_incision_template(mark_points_template(1,1) : mark_points_template(3, 1), mark_points_template(1,2) : mark_points_template(6,2));
    mark_points_img_detect = img_incision_detect(mark_points_detect(1,1) : mark_points_detect(3, 1), mark_points_detect(1,2) : mark_points_detect(6,2));
    [hight, width] = size(mark_points_img_template);
    mark_points_img_detect = imresize(mark_points_img_detect, [hight, width]);
    img_temp1 = im2bw(mark_points_img_template, graythresh(mark_points_img_template));
    img_temp3 = im2bw(mark_points_img_detect, graythresh(mark_points_img_detect));     
    img_xor = xor(img_temp1, img_temp3);
    imshow(img_xor);
    
    
%     %% resize the image to make marks align
%     distance_template = (mark_points_template(5,2) - mark_points_template(1,2) + mark_points_template(6,2) - mark_points_template(2,2)...
%         + mark_points_template(7,2) - mark_points_template(3,2) + mark_points_template(8,2) - mark_points_template(4,2)) / 4;
%     distance_detect = (mark_points_detect(5,2) - mark_points_detect(1,2) + mark_points_detect(6,2) - mark_points_detect(2,2)...
%         + mark_points_detect(7,2) - mark_points_detect(3,2) + mark_points_detect(8,2) - mark_points_detect(4,2)) / 4;
%     ratio = distance_template / distance_detect;
%     [width, height] = size(img_incision_detect);
%     draw_width = width ;
%     draw_height = height * ratio;
% 
%     % resize
%     img_incision_detect = imresize(img_incision_detect, [draw_width, draw_height]); 
%     
%     % refind the detect marks after RT transform
%     [m,n] = size(match_points_detect_temp);
%     match_points_detect_temp_new = zeros(m, n);
%     for index_points = 1:m
%        a = match_points_detect_temp(index_points,:);
%        match_points_detect_temp_new(index_points,:) = R * a' + T;
%        match_points_detect_temp_new = round(match_points_detect_temp_new);
%     end
%     
%     mark_points_detect_size = FuncMarksPointsDetect(img_incision_detect, match_points_detect_temp_new, template_circle, is_debug, i, 'detect');  
%     
%     % segment the img to make sure marks align
%     [img_incision_detect_draw, img_incision_detect_inside] = FuncSegment(img_incision_detect, mark_points_detect_size, template_circle, 'detect');
%     [img_incision_template_draw, img_incision_template_inside] = FuncSegment(img_incision_template, mark_points_template, template_circle, 'template');
%     
%     % test R and T
%     if(1)
%         [m,n] = size(mark_points_detect);
%         mark_points_template_cal = zeros(m, n);
%         for index_points = 1:m
%            a = mark_points_detect(index_points,:);
%            mark_points_template_cal(index_points,:) = R * a' + T;
%            mark_points_template_cal = round(mark_points_template_cal);
%         end
%         if is_show_figure == 1
%             figure(1)
%             imshow(img_incision_detect_draw);
%             hold on;
%             for index = 1 : size(mark_points_template_cal, 1)
%                 plot(mark_points_template_cal(index,2), mark_points_template_cal(index,1), 'r+');  
%             end
%             hold off;
%         end
%     end
%     
%     if(1)              
%         img_temp1 = im2bw(img_incision_template_draw, graythresh(img_incision_template_draw));
%         img_temp3 = im2bw(img_incision_detect_draw, graythresh(img_incision_detect_draw));       
%         
%         % set the template and detect to the same size       
%         [width_img_temp1, height_img_temp1] = size(img_incision_detect_inside);
%         [width_img_temp3, height_img_temp3] = size(img_incision_template_inside);
%         width_final = min(width_img_temp1, width_img_temp3) + 200;
%         height_final = min(height_img_temp1, height_img_temp3) + 200;
%         img_temp1 = img_temp1(1:width_final, 1:height_final);
%         img_temp3 = img_temp3(1:width_final, 1:height_final);
%         
%         img_xor = xor(img_temp1, img_temp3);
%         
%         if is_show_figure == 1
%             fig_handle = figure(i+1);
%             imshow(img_xor);
%         end        
% %         hold on;
% %         
% %         for index = 1 : size(mark_points_template_cal, 1)
% %             plot(mark_points_template_cal(index,2), mark_points_template_cal(index,1), 'r+');  
% %         end        
% %         hold off;        
%         image_name = sprintf('%s%s%d.bmp',output_path,'xor_',i)
%         imwrite(img_xor, image_name);
%     end
    
    %drawback_info = PCBDetect(img_incision_output, img_incision_template, 0, 1, 'log', 'output');
end




