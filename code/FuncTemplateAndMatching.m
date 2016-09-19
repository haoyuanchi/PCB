function [x,y,I_SSD]=FuncTemplateAndMatching(T,I,IdataIn)



% -------------------------------------------------------------------------
% ����ģ���ƥ��;


if(nargin<3), IdataIn=[]; end

if(size(I,3)>1)
    
    I = rgb2gray(I);
end

if(size(T,3)>1)
    
    T = rgb2gray(T);
end

% Convert images to double
T=double(T); I=double(I);
if(size(T,3)==3) 
    % Color Image detected
    [I_SSD,I_NCC,Idata]=template_matching_color(T,I,IdataIn); 
else
    % Grayscale image or 3D volume
    [I_SSD,I_NCC,Idata]=template_matching_gray(T,I,IdataIn);
end

[x,y] = find(I_SSD==max(I_SSD(:)));

[rows_I, cols_I] = size(I);
[rows_T, cols_T] = size(T);
% if (rows_I == rows_T && cols_I == cols_T)
%     I_SSD=I_SSD(round(rows_I/2),round(cols_I/2));
% else
%     I_SSD=max(I_SSD(:));

% end
% 
% [row,col]=size(T);
% y = y-col/2+1;
% x = x-row/2+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [I_SSD,I_NCC,Idata]=template_matching_color(T,I,IdataIn)
if(isempty(IdataIn)), IdataIn.r=[];  IdataIn.g=[]; IdataIn.b=[];  end
% Splite color image, and do template matching on R,G and B image
[I_SSD_R,I_NCC_R,Idata.r]=template_matching_gray(T(:,:,1),I(:,:,1),IdataIn.r);
[I_SSD_G,I_NCC_G,Idata.g]=template_matching_gray(T(:,:,2),I(:,:,2),IdataIn.g);
[I_SSD_B,I_NCC_B,Idata.b]=template_matching_gray(T(:,:,3),I(:,:,3),IdataIn.b);
% Combine the results
I_SSD=(I_SSD_R+I_SSD_G+I_SSD_B)/3;
I_NCC=(I_NCC_R+I_NCC_G+I_NCC_B)/3;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [I_SSD,I_NCC,Idata]=template_matching_gray(T,I,IdataIn)
% Calculate correlation output size  = input size + padding template
T_size = size(T); I_size = size(I);
outsize = I_size + T_size-1;

% calculate correlation in frequency domain
if(length(T_size)==2)
    FT = fft2(rot90(T,2),outsize(1),outsize(2));
    if(isempty(IdataIn))
        Idata.FI = fft2(I,outsize(1),outsize(2));
    else
        Idata.FI=IdataIn.FI;
    end
    Icorr = real(ifft2(Idata.FI.* FT));
else
    FT = fftn(rot90_3D(T),outsize);
    FI = fftn(I,outsize);
    Icorr = real(ifftn(FI.* FT));
end

% Calculate Local Quadratic sum of Image and Template
if(isempty(IdataIn))
    Idata.LocalQSumI= local_sum(I.*I,T_size);
else
    Idata.LocalQSumI=IdataIn.LocalQSumI;
end

QSumT = sum(T(:).^2);

% SSD between template and image
I_SSD=Idata.LocalQSumI+QSumT-2*Icorr;

% Normalize to range 0..1
I_SSD=I_SSD-min(I_SSD(:)); 
I_SSD=1-(I_SSD./max(I_SSD(:)));

% Remove padding
I_SSD=unpadarray(I_SSD,size(I));

if (nargout>1)
    % Normalized cross correlation STD
    if(isempty(IdataIn))
        Idata.LocalSumI= local_sum(I,T_size);
    else
        Idata.LocalSumI=IdataIn.LocalSumI;
    end
    
    % Standard deviation
    if(isempty(IdataIn))
        Idata.stdI=sqrt(max(Idata.LocalQSumI-(Idata.LocalSumI.^2)/numel(T),0) );
    else
        Idata.stdI=IdataIn.stdI;
    end
    stdT=sqrt(numel(T)-1)*std(T(:));
    % Mean compensation
    meanIT=Idata.LocalSumI*sum(T(:))/numel(T);
    I_NCC= 0.5+(Icorr-meanIT)./ (2*stdT*max(Idata.stdI,stdT/1e5));

    % Remove padding
    I_NCC=unpadarray(I_NCC,size(I));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T=rot90_3D(T)
T=flipdim(flipdim(flipdim(T,1),2),3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function B=unpadarray(A,Bsize)
Bstart=ceil((size(A)-Bsize)/2)+1;
Bend=Bstart+Bsize-1;
if(ndims(A)==2)
    B=A(Bstart(1):Bend(1),Bstart(2):Bend(2));
elseif(ndims(A)==3)
    B=A(Bstart(1):Bend(1),Bstart(2):Bend(2),Bstart(3):Bend(3));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_sum_I= local_sum(I,T_size)
% Add padding to the image
B = padarray(I,T_size);

% Calculate for each pixel the sum of the region around it,
% with the region the size of the template.
if(length(T_size)==2)
    % 2D localsum
    s = cumsum(B,1);
    c = s(1+T_size(1):end-1,:)-s(1:end-T_size(1)-1,:);
    s = cumsum(c,2);
    local_sum_I= s(:,1+T_size(2):end-1)-s(:,1:end-T_size(2)-1);
else
    % 3D Localsum
    s = cumsum(B,1);
    c = s(1+T_size(1):end-1,:,:)-s(1:end-T_size(1)-1,:,:);
    s = cumsum(c,2);
    c = s(:,1+T_size(2):end-1,:)-s(:,1:end-T_size(2)-1,:);
    s = cumsum(c,3);
    local_sum_I  = s(:,:,1+T_size(3):end-1)-s(:,:,1:end-T_size(3)-1);
end

