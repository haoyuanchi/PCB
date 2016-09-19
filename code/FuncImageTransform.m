function img_out = FuncImageTransform(img, R, T)



        %% ͼ����ת
    % 根据R，T求解旋转角度和平移距离
    %     theta1 = acos(R(1,1));
        theta1 = asin(R(2,1));
    %     theta = (theta1 + theta2) / 2;
        theta = theta1 / pi * 180;

    %��ݽǶȺ�ƽ�ƾ�����ת�����ͼ��
    %��ת

    %ƽ��
%     img_rotate = imrotate(img, theta, 'bilinear', 'crop');
    img_rotate = imrotate(img, theta, 'bilinear');
    
    temp1 = size(img_rotate,2) - size(img,2);

    T(2) = T(2) - temp1;
    se=translate(strel(1), round(T'));
    img_trans = imdilate(img_rotate, se);

%         Move_x=round(T(1));
% %     Move_y=round(T(2)) - temp1;
% Move_y=round(T(2)) - (temp1 * 2);
% if Move_y < 0 && Move_x < 0    
%     img_size = size(img_rotate);
%     img_trans(1 : img_size(1) + Move_x,  1 : img_size(2) + Move_y) = img_rotate( abs(Move_x) + 1 : img_size(1) , abs(Move_y)+1 : img_size(2));    
% elseif Move_x < 0 && Move_y > 0   
%     
% elseif Move_x  0 && Move_y > 0   
%     img_size = size(img_rotate);
%     img_trans(Move_x + 1 : img_size(1),  Move_y  + 1 : img_size(2)) = img_rotate(1 : img_size(1) - Move_x , 1 : img_size(2) - Move_y);   
% end
    
    img_out = img_trans;
    
    % row = [0, 0];
    % col = [0;0;1];
    % R1 = [R; row];
    % R1 = [R1 col];
    % %根据角度和平移距离求转换后的图像
    % %旋转
    % T_rotation = maketform('affine', R1);
    % I_rotation = imtransform(img_detect, T_rotation); 
    % 
    % %平移
    % row1 = [0, 0, 1];
    % T1 = [eye(2) T];
    % T1 = [T1; row1];
    % T_x_y = maketform('affine', T1');
    % img_incision_output = imtransform(I_rotation, T_x_y, 'XData',[1 (size(I_rotation, 2) + T1(3,1))], 'YData', ...
    %     [1 (size(I_rotation, 1) + T1(3,2))], 'FillValues', 128); 
