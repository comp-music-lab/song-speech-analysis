%Written by JooSeuk Kim(2011/07/12)
function K = gauss_kern(dist,h,d)
%
% evaluate gaussian kernel of dataset based on squared distances to kernel
% centers; 
% K: Gaussian kernel
% dist: matrix of squared distances
% h: bandwidth
% d: dimension
%

K = exp(-dist/(2*h^2))/((2*pi*h^2)^(d/2)); 
