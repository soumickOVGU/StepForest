function [imfilt] = MeanFilter(im, wSlider)
% MeanFilter - Apply Mean Filter on the Image
% Syntax: [imfilt] = MeanFilter(im, wSlider)
% Inputs:
%   im: Input Image (Single Channel, grayscale or one channel of RGB)
%   wSlider: Window size of the Slider
% Outputs:
%   imfilt: Output Image, after applying mean filter on the input image
%
% Author: Rupali Khatun (rupali.khatun@live.com)
%         and Soumick Chatterjee (contact@soumick.com)
% Website: http://www.soumick.com
% Sep 2017; Last revision: 11-Dec-2018

    h = 1/wSlider*ones(wSlider,1);
    H = h*h';
    imfilt = filter2(H,im);
end

