function matching_points = FuncMatchingPointsDetect(img, template_circle, is_debug)
% INPUT : 
% img: ��marks��ͼ��
% template_circle:  markģ��
% OUTPUT
% circles:  ͼ����ƥ��ģ��ĵ㼯

%% initialize 

up_start_pix = 1;
down_stop_pix = size(img, 1);
up_interval_pix = 400;
down_interval_pix = 400;


%  71
% up_start_pix = 400;
% down_stop_pix = 8200;
% up_interval_pix = 800;
% down_interval_pix = 800;

% 72
% up_start_pix = 4000;
% down_stop_pix = 12300;
% up_interval_pix = 1200;
% down_interval_pix = 1200;

%  234
% up_start_pix = 2600;
% down_stop_pix = 13500;
% up_interval_pix = 1200;
% down_interval_pix = 1200;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Detect the Matching Points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[height, width] = size(img);
up_edge = img(up_start_pix : (up_start_pix + up_interval_pix), 1:width);
bottom_edge = img((down_stop_pix - down_interval_pix + 1):down_stop_pix, 1:width);

up_baseImg = up_edge;
bottom_baseImg = bottom_edge;
[xx_up,yy_up,weight_up] = FuncTemplateAndMatching(template_circle,up_baseImg);
% down_edge = zeros(300, height);
% 
% down_edge = img((width-300+1):end, 1:height);
[xx_bottom,yy_bottom,weight_bottom] = FuncTemplateAndMatching(template_circle,bottom_baseImg);

theta_up = max(max(weight_up)) * 0.98;
theta_bottom = max(max(weight_bottom)) * 0.98;

[X_up, Y_up] = find(weight_up > theta_up);
[X_bottom, Y_bottom] = find(weight_bottom > theta_bottom);

points_up = [X_up, Y_up];
points_bottom = [X_bottom, Y_bottom];

% �������������
points_up(:,1) = points_up(:,1) + up_start_pix;
points_bottom(:,1) = points_bottom(:,1) + (down_stop_pix - down_interval_pix + 1);

points = [points_up; points_bottom];
[rows, columns] = size(points);

% ���о�����������ĵ�ֻ���һ��
points_cluster = [points(1,1), points(1,2)];
for i = 2 : rows
    if(CalL1Distance(points(i,1), points(i,2), points(i-1,1), points(i-1,2)) > 10)
        temp = [points(i,1), points(i,2)];
        points_cluster = [points_cluster; temp];
    end
end

if(is_debug)
    figure(1),imshow(img,[]);
    hold on;
    for i = 1 : size(points_cluster, 1)
        plot(points_cluster(i,2), points_cluster(i,1), '*r');
    end 
    hold off;
end

% ����ݵ�ֿ����
points_cluster = sortrows(points_cluster, 2);
points_out = [];
for i = 1 : (size(points_cluster, 1) / 2 - 1)
    points_temp = [];
    points_temp = points_cluster((2*i -1):(2*i + 2),:);  
    
    % ÿ��ȡ4���� ------ ����������ǰ����ͼ���е�mark������ȫ���ҵ�    
    % sort the points
    temp_sum = sum(points_temp, 2);
    [temp_sum_sort, sort_index] = sort(temp_sum);

    % the first point
    matching_points_temp(1,:) = points_temp(sort_index(1),:);
    % the 4 pointmatching_points
    matching_points_temp(4,:) = points_temp(sort_index(4),:);

    points_2_3 = [points_temp(sort_index(2), :) ; 
                        points_temp(sort_index(3), :)];
    [point_2_3_sort, sort_index_2_3] = sort(points_2_3(:,2));

    matching_points_temp(2,:) = points_2_3(sort_index_2_3(1),:);
    matching_points_temp(3,:) = points_2_3(sort_index_2_3(2),:);
    
    points_out(:,:,i) = matching_points_temp;
end

matching_points = points_out;

end


function distance = CalL1Distance(x1,y1,x2,y2)
%% ����L1����
distance = abs(x1-x2) + abs(y1-y2);

end






