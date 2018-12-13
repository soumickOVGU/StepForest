function [ OutputImage ] = Normalize( SourceImage,RefImage,TypeOfNormalization )
% Normalize - Normalize the input image
% Syntax: [ OutputImage ] = Normalize( SourceImage,RefImage,TypeOfNormalization )
% Inputs:
%   SourceImage: Input Image 
%   RefImage: Reference Image, to be used for normalization
%   TypeOfNormalization: Type of normalization
% Outputs:
%   OutputImage: Normalized output image
%
% Author: Rupali Khatun (rupali.khatun@live.com)
%         and Soumick Chatterjee (contact@soumick.com)
% Website: http://www.soumick.com
% Sep 2017; Last revision: 11-Dec-2018

    verbose = 0; %dont show results    
    TargetImage = imread(RefImage);    
    [ NormImg ] = Norm( SourceImage, TargetImage, TypeOfNormalization, verbose );    
    OutputImage = NormImg;
    
end

