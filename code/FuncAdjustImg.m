function img_out = FuncAdjustImg(img, mark_points_template, template_circle, is_vertical, is_debug)
% find the first and the last matching_points

first_group_matching_points = mark_points_template(:,:,1);

first_matching_points = first_group_matching_points(1, : );

% 垂直方面还是水平方向矫正
if is_vertical
    second_matching_points = first_group_matching_points(2, : );
else
    second_matching_points = first_group_matching_points(3, : );
end

[m,n] = size(template_circle);

m = round(m / 2) + 1;
n = round(n / 2) + 1;

circle_center = [];

%% find the circle 
x_up_left = first_matching_points(1,2) - n;
y_up_left = first_matching_points(1,1) - m;
x_bottom_right = first_matching_points(1,2) + n;
y_bottom_right = first_matching_points(1,1) + m;
cicle_search = img(y_up_left:y_bottom_right, x_up_left:x_bottom_right);

first_circle_para_xyr = FuncCicleDetect(cicle_search);   
first_circle_para_xyr(:,1) = first_circle_para_xyr(:,1) + y_up_left - 1;
first_circle_para_xyr(:,2) = first_circle_para_xyr(:,2) + x_up_left - 1;

% sort the circle
temp = first_circle_para_xyr(:, 2);
[temp_sort, sort_index] = sort(temp);
circle_temp(1,:) = first_circle_para_xyr(sort_index(1), :);    
circle_temp(2,:) = first_circle_para_xyr(sort_index(2), :);    

first_circle_para_xyr = circle_temp;

x_up_left = second_matching_points(1,2) - n;
y_up_left = second_matching_points(1,1) - m;
x_bottom_right = second_matching_points(1,2) + n;
y_bottom_right = second_matching_points(1,1) + m;
cicle_search = img(y_up_left:y_bottom_right, x_up_left:x_bottom_right);

second_circle_para_xyr = FuncCicleDetect(cicle_search);   
second_circle_para_xyr(:,1) = second_circle_para_xyr(:,1) + y_up_left - 1;
second_circle_para_xyr(:,2) = second_circle_para_xyr(:,2) + x_up_left - 1;

% sort the circle
temp = second_circle_para_xyr(:, 2);
[temp_sort, sort_index] = sort(temp);
circle_temp(1,:) = second_circle_para_xyr(sort_index(1), :);    
circle_temp(2,:) = second_circle_para_xyr(sort_index(2), :);    

second_circle_para_xyr = circle_temp;


if(is_debug) 
    figure(1),imshow(img);
    hold on;
%     for index = 1 : size(first_circle_para_xyr, 1)
    for index = 1 : 1        
        plot(first_circle_para_xyr(index,2), first_circle_para_xyr(index,1), 'r+');

        t=0:0.01*pi:2*pi;
        x=cos(t).*first_circle_para_xyr(index,3)+first_circle_para_xyr(index,2);
        y=sin(t).*first_circle_para_xyr(index,3)+first_circle_para_xyr(index,1);
        plot(x,y,'r-');      
    end
    hold on;
    
    for index = 1 : 1
        plot(second_circle_para_xyr(index,2), second_circle_para_xyr(index,1), 'r+');

        t=0:0.01*pi:2*pi;
        x=cos(t).*second_circle_para_xyr(index,3)+second_circle_para_xyr(index,2);
        y=sin(t).*second_circle_para_xyr(index,3)+second_circle_para_xyr(index,1);
        plot(x,y,'r-');      
    end
    hold off;
end

if is_vertical
    % 垂直方向矫正
    theta1 = acot((first_circle_para_xyr(1, 1) - second_circle_para_xyr(1, 1)) / (first_circle_para_xyr(1, 2) - second_circle_para_xyr(1, 2)));
    theta2 = acot((first_circle_para_xyr(2, 1) - second_circle_para_xyr(2, 1)) / (first_circle_para_xyr(2, 2) - second_circle_para_xyr(2, 2)));

    %  img rotate thela
    theta = ((theta1+theta2) / 2) / pi * 180;
    img_rotate = imrotate(img, -theta, 'bilinear');
    img_out = FuncPreprocess(img_rotate);

else 
    % 水平方向矫正
    theta1 = atan((first_circle_para_xyr(1, 1) - second_circle_para_xyr(1, 1)) / (first_circle_para_xyr(1, 2) - second_circle_para_xyr(1, 2)));
    theta2 = atan((first_circle_para_xyr(2, 1) - second_circle_para_xyr(2, 1)) / (first_circle_para_xyr(2, 2) - second_circle_para_xyr(2, 2)));

    %  img rotate thela
    theta = ((theta1+theta2) / 2) / pi * 180;
    img_rotate = imrotate(img, theta, 'bilinear');
    img_out = FuncPreprocess(img_rotate);
end

if is_debug == 1
    figure(2),imshow(img_rotate);
    figure(3),imshow(img_out);
end



