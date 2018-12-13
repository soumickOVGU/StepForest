function [ hR, hG, hB ] = RGBHist( im )
% RGBHist - For generating RGB Histogram
% Syntax: [ hR, hG, hB ] = RGBHist( im )
% Inputs:
%   im: Input Image (RGB)
% Outputs:
%   hR: Histogram of the red channel of the image
%   hG: Histogram of the green channel of the image
%   hB: Histogram of the blue channel of the image
%
% Author: Rupali Khatun (rupali.khatun@live.com)
%         and Soumick Chatterjee (contact@soumick.com)
% Website: http://www.soumick.com
% Sep 2017; Last revision: 11-Dec-2018

    R = im(:,:,1);
    G = im(:,:,2);
    B = im(:,:,3);
    hR = imhist(R);
    hG = imhist(G);
    hB = imhist(B);
end

