function img_out = FuncPreprocess(img, pro_type)

%  adjust image to rectangle

img_gray =  im2bw(img, graythresh(img));

[hight, width] = size(img_gray);

left_index = 1;
right_index = 1;
up_index = 1;
down_index = 1;

for i = 1 : width
    temp = sum(img_gray(:, i));
    if temp > width / 100
        left_index = i;
        break;
    end
end

for i = width : -1: 1
    temp = sum(img_gray(:, i));
    if temp > width / 100
        right_index = i;
        break;
    end
end

for i = 1 : hight
    temp = sum(img_gray(i, :));
    if temp > hight / 100
        up_index = i;
        break;
    end
end

for i = hight : -1: 1
    temp = sum(img_gray(i, :));
    if temp > hight / 100
        down_index = i;
        break;
    end
end

img_out = img(up_index :down_index, left_index : right_index);

