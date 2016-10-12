function FuncMain(image_base, img_template_name, img_detect_name, img_template_circle_name, config)

%%%%%%%%%%%%%%%%%%%%
%%    preprocess the image   %%
%%%%%%%%%%%%%%%%%%%%  

% save figure path
ind = findstr(img_detect_name, '/');
temp_folder_name = ['temp-', img_detect_name(1: ind(1))];
if exist(temp_folder_name,'dir')==0
   mkdir(temp_folder_name);
end
output_path=['./',temp_folder_name,'/'];

img_template =  imread([image_base, img_template_name]);
img_detect =  imread([image_base, img_detect_name]);
template_circle = imread(img_template_circle_name);

if config.is_need_rotate==1
    img_template =  imrotate(img_template, 90, 'bilinear');
    img_detect = imrotate(img_detect, 90, 'bilinear');
end

%  segment the black
% add a func to 
if config.is_show_figure == 1
    imshow(img_template);
end
img_template = FuncPreprocess(img_template);
img_detect = FuncPreprocess(img_detect);
if config.is_show_figure == 1
    imshow(img_template);
end

%% detect the matching points rough
matching_points_template = FuncMatchingPointsDetect(img_template, template_circle, config);
matching_points_detect = FuncMatchingPointsDetect(img_detect, template_circle, config);

is_vertical = 0;
% adjust image to rectangle
img_template = FuncAdjustImg(img_template, matching_points_template, template_circle, is_vertical, config.is_debug);
img_detect = FuncAdjustImg(img_detect, matching_points_detect, template_circle, is_vertical, config.is_debug);

% save matching_points_detect matching_points_detect;
% save matching_points_template matching_points_template;
% 
% load matching_points_detect;
% load matching_points_template;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    xor the image  


%% detect the matching points rough
matching_points_template = FuncMatchingPointsDetect(img_template, template_circle, config);
matching_points_detect = FuncMatchingPointsDetect(img_detect, template_circle, config);

%% incision the pixel according to the matching points
for i = 1 : size(matching_points_detect, 3)    
    %% detect mark points 
    [mark_points_template, mark_points_img_template] = FuncIncisionAndMarksPointsDetect(img_template, matching_points_template, template_circle, config.is_debug, i, 'template');  
    [mark_points_detect, mark_points_img_detect] = FuncIncisionAndMarksPointsDetect(img_detect, matching_points_detect, template_circle, config.is_debug, i, 'detect');
    
    [hight, width] = size(mark_points_img_template);
    mark_points_img_detect = imresize(mark_points_img_detect, [hight, width]);
    img_temp = im2bw(mark_points_img_template, graythresh(mark_points_img_template));
    img_det = im2bw(mark_points_img_detect, graythresh(mark_points_img_detect));     
    img_xor = xor(img_temp, img_det);
    
    if config.is_show_figure == 1
        fig_handle = figure(i+1);
        imshow(img_xor);
    end

    image_name = sprintf('%s%s%d.bmp',output_path,'xor_',i)
    imwrite(img_xor, image_name);
    
    %% performs a logical exclusive-OR of source_bw and template_bw
    fprintf(1,'Exclusive-OR\n');
    drawback_candidate = xor(img_temp, img_det);
    % 
    boundary_mask = zeros(size(img_temp));
    boundary_mask(15:size(img_temp,1)-15,15:size(img_temp,2)-15)=1;
    drawback_candidate = drawback_candidate&boundary_mask;

    %% morphology filtering
    % drawback = bwmorph(drawback_candidate,'open');
    % se1 = strel('disk',1);
    se2 = strel('disk',1);
    % drawback = imclose(imopen(drawback_candidate,se1),se1);
    drawback = imopen(drawback_candidate,se2);
    % drawback = imerode(imerode(imerode(drawback_candidate,strel('disk',0)),strel('disk',1)),strel('disk',0));
    drawback = bwareaopen(drawback,5);
    
    image_name = sprintf('%s%s%d.bmp',output_path,'filter_xor_',i)
    imwrite(drawback, image_name);
    
end






