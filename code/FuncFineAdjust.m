function img_out = FuncFineAdjust(img, mark_points)
first_mark= mark_points(1, :);
second_mark = mark_points(3, :);
third_mark = mark_points(6, :);
fourth_mark = mark_points(8, :);

if first_mark(1, 2) == third_mark(1, 2)
    theta1 = 0;
else
    theta1 = atan((first_mark(1, 1) - third_mark(1, 1)) / (first_mark(1, 2) - third_mark(1, 2)));
end

if second_mark(1, 2) == fourth_mark(1, 2)
    theta2 = 0;
else
    theta2 = atan((second_mark(1, 1) - fourth_mark(1, 1)) / (second_mark(1, 2) - fourth_mark(1, 2)));
end

theta = ((theta1+theta2) / 2) / pi * 180;
img_rotate = imrotate(img, theta, 'bilinear');
figure(1),imshow(img);
figure(2),imshow(img_rotate);

img_out = img_rotate;
