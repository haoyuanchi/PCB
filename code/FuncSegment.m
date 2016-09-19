function [img_segment, img_inside] = FuncSegment(img,mark_points, img_type)

img_start_x = min(mark_points(:,2)) - 100;
img_stop_x = max(mark_points(:,2)) + 100;    
img_start_y = min(mark_points(:,1)) - 100;    
img_stop_y = max(mark_points(:,1)) + 100;

% print out the margin of marks
mark_margin_up = (mark_points(5,2) - mark_points(1,2) + mark_points(6,2) - mark_points(2,2)) / 2;
    
mark_margin_bottom = (mark_points(7,2) - mark_points(3,2) + mark_points(8,2) - mark_points(4,2)) / 2;
    
img_segment = img(img_start_y : img_stop_y, img_start_x : img_stop_x);

img_inside = img( min(mark_points(:,1)) : max(mark_points(:,1)), min(mark_points(:,2)) : max(mark_points(:,2)));
