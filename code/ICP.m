%Find the transformation that registers model with the
%   scene, S <== T M.
% Output:
%   param =[dx dy theta]
function [tmodel,template_point,source_point,model_correspondence,transdist] = ICP(templates,source,thr,display_it)

if nargin < 3
    thr = 20;
    display_it = 0;
end;

if nargin < 4
    display_it = 0;
end;

%finding correspondence
correspondence = zeros(size(templates));
model_correspondence=[];
len = size(templates,1);


old_param = 1e20*ones(1,3);
param = 1e10*ones(1,3);
step = 0;
transdist = 0;
while norm(old_param-param)>1e-10 && step <200;
    step = step+1;
    old_param = param;
    indx = [];
    for ii = 1:len;
        dist = (source(:,1)-templates(ii,1)).^2 + ...
            (source(:,2)-templates(ii,2)).^2;
        [mn,idx] = min(dist);
        if(mn<thr)
            indx=[indx,ii];
            correspondence(ii,:) = source(idx,:);
        end;
    end;

    if display_it
        figure(1); hold off;
        set(gca,'FontSize',12);
        plot(templates(:,2),templates(:,1),'r+');
        hold on;
        plot(source(:,2),source(:,1),'go');
        for ii = 1:length(indx);
            plot([templates(indx(ii),2),correspondence(indx(ii),2)],...
                [templates(indx(ii),1),correspondence(indx(ii),1)])
        end;
        pbaspect([1,1,1]);
        drawnow;
    end;
        
    %estimating the parameters;
%     [theta,dxy] = ICP2D(templates(indx,:),correspondence(indx,:));
%     param = [dxy,theta];
%     templates = TransformPoint(param,templates);
    [theta,dxy] = ICP2D(templates(indx,:),correspondence(indx,:));
    param = [dxy,0];
    templates = TransformPoint(param,templates);
%     se=translate(strel(1),dxy);
%     source_gary_box=imdilate(source_gary_box,se);
    transdist = dxy+transdist;
end;

tmodel = templates;
template_point=templates(indx,:);
source_point=correspondence(:,:);
if size(templates,1)==0||size(source,1)==0
    return;
else
    for ii = 1:len
        dist = (source(:,1)-templates(ii,1)).^2 + ...
        (source(:,2)-templates(ii,2)).^2;
        [~,idx] = min(dist);
        model_correspondence(ii) = idx;
    end
end;
