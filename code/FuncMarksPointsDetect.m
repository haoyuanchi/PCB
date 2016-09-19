function circles = FuncMarksPointsDetect(img, matching_points, template_circle, is_debug, incision_index, img_type)
% INPUT : 
% img: ��marks��ͼ��
% matching_points:  ��marks��ͼ��ģ��ƥ������ĵ�
% template_circle:  markģ��

% OUTPUT
% circles:  ͼ���е� marks ���

%% ��� matching_points �� ģ��ͼƬ��С ȷ��������Χ
[m,n] = size(template_circle);

m = round(m / 2) + 1;
n = round(n / 2) + 1;

circle_center = [];
for i =  1: size(matching_points, 1)
    x_up_left = matching_points(i,2) - n;
    y_up_left = matching_points(i,1) - m;
    x_bottom_right = matching_points(i,2) + n;
    y_bottom_right = matching_points(i,1) + m;
    img_search(:,:,i) = img(y_up_left:y_bottom_right, x_up_left:x_bottom_right);
    if(is_debug)
        figure(2), imshow(img,[]);
        rectangle('Position', [x_up_left, y_up_left, 2*n, 2*m]);
        hold on;
    end
    
    cicle_search = img_search(:,:,i);
    circle_para_xyr = FuncCicleDetect(cicle_search);   

    % ��ȡ����Բ����� 
    circle_para_xyr(:,1) = circle_para_xyr(:,1) + y_up_left - 1;
    circle_para_xyr(:,2) = circle_para_xyr(:,2) + x_up_left - 1;
    
    if(is_debug)        
        for index = 1 : size(circle_para_xyr, 1)
            plot(circle_para_xyr(index,2), circle_para_xyr(index,1), 'r+');

            t=0:0.01*pi:2*pi;
            x=cos(t).*circle_para_xyr(index,3)+circle_para_xyr(index,2);
            y=sin(t).*circle_para_xyr(index,3)+circle_para_xyr(index,1);
            plot(x,y,'r-');      
        end
        hold off;

        image_name = sprintf('%s%s%d%s%d','circle_',img_type,incision_index,'__', i);
        saveas(gcf, image_name, 'bmp');
    end
    
    circle_center = [circle_center; circle_para_xyr];    
end

circles = circle_center(:,1:2);

end


