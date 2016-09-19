%2D transform of point set
% param = (dx,dy,theta);
% transformation is done by first shift the point center back origin,
% rotate, then shift back
function PT = TransformPoint(param,P);

switch length(param);
    case 3
        % Euclidean motion
        center = mean(P,1);
        rt = [cos(param(3)) -sin(param(3)); sin(param(3)), cos(param(3))];
        PT = (rt * [P(:,1)-center(1) P(:,2)-center(2)]')';
        PT(:,1) = PT(:,1) + center(1) + param(1);
        PT(:,2) = PT(:,2) + center(2) + param(2);
    case 6
        % Affine motion
        M = reshape(param,2,3);
        PT = (M * [P'; ones(1,size(P,1))])';
    case 8
        % Projective motion
        M = reshape([param;1],3,3);
        PT2 = (M * [P'; ones(1,size(P,1))])';
        % make sure not divided by zero;
        PT2(:,3) = sign(PT2(:,3)) .* max(abs(PT2(:,3)), 1e-10);
        PT = zeros(size(P,1),2);
        PT(:,1) = PT2(:,1)./PT2(:,3);
        PT(:,2) = PT2(:,2)./PT2(:,3);
    otherwise
        disp('Unknown motion type');
        error('','unknown motion');
end;
