close all;
clear all;
clc;

% set the flag
config.is_debug = 0;
config.is_show_figure = 0;
config.is_need_rotate = 1;

%% load the image

for i = 0 : 9    
    image_base='/home/hychi/Project/PCB/data/72/Grab/2016-09-09/'; 
    img_template_name =  '13329/g.bmp';
    img_num = 13329 + i;
    img_detect_name =  [num2str(img_num), '/g.bmp'];
    img_template_circle_name = '../data/72/template_circle_72.bmp';
    config.interval_pix = 1500;

    % image_base='/home/hychi/Project/PCB/data/test/'; 
    % img_template_name =  '13000/g.bmp';
    % img_detect_name =  '13002/g.bmp';
    % img_template_circle_name = '../data/59/template_circle_59.bmp';

    % image_base='/home/hychi/Project/PCB/data/234/Grab/2016-09-09/'; 
    % img_template_name =  '44277/g.bmp';
    % img_num = 44277 + i;
    % img_detect_name =  [num2str(img_num), '/g.bmp'];
    % img_template_circle_name = '../data/234/template_circle_234.bmp';
    %config.interval_pix = 400;

    FuncMain(image_base, img_template_name, img_detect_name, img_template_circle_name, config);
end

