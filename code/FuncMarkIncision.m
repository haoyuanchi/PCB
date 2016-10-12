function mark_points_img = FuncMarkIncision(img, mark_points, is_debug, incision_index, img_type)

mark_points_img(:, :) = img(mark_points(1, 1) : mark_points(3, 1), mark_points(1, 2) : mark_points(6, 2));