function [ PSNR ] = appraise(img1,img2)
%% peak-signal-noise ratio
img1=double(img1);
img2=double(img2);
L=length(img1(:));
MSE = sum((img1(:)-img2(:)).^2);
mse = MSE/L;

PSNR=10*log10(255*255/mse);

end

