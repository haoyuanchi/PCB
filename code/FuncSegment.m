function [img_segment, img_inside] = FuncSegment(img,mark_points, template_circle ,img_type)

[m, n] = size(template_circle);
% m = round(m / 2) + 1;
n = round(n / 2) + 1;

img_start_x = min(mark_points(:,2)) - n;
img_stop_x = max(mark_points(:,2)) + n;    
img_start_y = min(mark_points(:,1)) - m ;    
img_stop_y = max(mark_points(:,1)) + m ;

% print out the margin of marks
mark_margin_up = (mark_points(5,2) - mark_points(1,2) + mark_points(6,2) - mark_points(2,2)) / 2;
    
mark_margin_bottom = (mark_points(7,2) - mark_points(3,2) + mark_points(8,2) - mark_points(4,2)) / 2;
    
img_segment = img(img_start_y : img_stop_y, img_start_x : img_stop_x);

img_inside = img( min(mark_points(:,1)) : max(mark_points(:,1)), min(mark_points(:,2)) : max(mark_points(:,2)));
