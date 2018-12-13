function [imfilt] = SDFilter(im,wSlider)
% SDFilter - Apply Standard Deviation (SD) Filter on the Image
% Syntax: [imfilt] = SDFilter(im,wSlider)
% Inputs:
%   im: Input Image (Single Channel, grayscale or one channel of RGB)
%   wSlider: Window size of the Slider
% Outputs:
%   imfilt: Output Image, after applying SD filter on the input image
%
% Author: Rupali Khatun (rupali.khatun@live.com)
%         and Soumick Chatterjee (contact@soumick.com)
% Website: http://www.soumick.com
% Sep 2017; Last revision: 11-Dec-2018

    nhood = ones(wSlider,wSlider);
    imfilt = stdfilt(im,nhood);
end

