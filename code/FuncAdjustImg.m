function img_out = FuncAdjustImg(img, matching_points, template_circle, is_debug)
% find the first and the last matching_points

first_group_matching_points = matching_points(:,:,1);

first_matching_points = first_group_matching_points(1, : );
second_matching_points = first_group_matching_points(2, : );

[m,n] = size(template_circle);

m = round(m / 2) + 1;
n = round(n / 2) + 1;

circle_center = [];

x_up_left = first_matching_points(1,2) - n;
y_up_left = first_matching_points(1,1) - m;
x_bottom_right = first_matching_points(1,2) + n;
y_bottom_right = first_matching_points(1,1) + m;
cicle_search = img(y_up_left:y_bottom_right, x_up_left:x_bottom_right);

first_circle_para_xyr = FuncCicleDetect(cicle_search);   
first_circle_para_xyr(:,1) = first_circle_para_xyr(:,1) + y_up_left - 1;
first_circle_para_xyr(:,2) = first_circle_para_xyr(:,2) + x_up_left - 1;

x_up_left = second_matching_points(1,2) - n;
y_up_left = second_matching_points(1,1) - m;
x_bottom_right = second_matching_points(1,2) + n;
y_bottom_right = second_matching_points(1,1) + m;
cicle_search = img(y_up_left:y_bottom_right, x_up_left:x_bottom_right);

second_circle_para_xyr = FuncCicleDetect(cicle_search);   
second_circle_para_xyr(:,1) = second_circle_para_xyr(:,1) + y_up_left - 1;
second_circle_para_xyr(:,2) = second_circle_para_xyr(:,2) + x_up_left - 1;

theta1 = acot((first_circle_para_xyr(1, 1) - second_circle_para_xyr(1, 1)) / (first_circle_para_xyr(1, 2) - second_circle_para_xyr(1, 2)));
theta2 = acot((first_circle_para_xyr(2, 1) - second_circle_para_xyr(2, 1)) / (first_circle_para_xyr(2, 2) - second_circle_para_xyr(2, 2)));

%  img rotate thela
theta = ((theta1+theta2) / 2) / pi * 180;
img_rotate = imrotate(img, -theta, 'bilinear');
img_out = FuncPreprocess(img_rotate);

if is_debug == 1
    figure(1),imshow(img);
    figure(2),imshow(img_rotate);
    figure(3),imshow(img_out);
end



