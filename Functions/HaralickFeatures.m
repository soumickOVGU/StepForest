function [ FvHaralick ] = HaralickFeatures( im )
% HaralickFeatures - Generate Haralick Texture Features of the image
% Syntax: [ FvHaralick ] = HaralickFeatures( im )
% Inputs:
%   im: Input Image (Single Channel, grayscale or one channel of RGB)
% Outputs:
%   FvHaralick: Haralick Texture Features of the input image
%
% Author: Rupali Khatun (rupali.khatun@live.com)
%         and Soumick Chatterjee (contact@soumick.com)
% Website: http://www.soumick.com
% Sep 2017; Last revision: 11-Dec-2018

    glcm = graycomatrix(im, 'offset', [0 1], 'Symmetric', true); %need to know the meaning of each parameter, curretnly using default params
    features = haralickTextureFeatures(glcm);
    FvHaralick = features';
    
end

