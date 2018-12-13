function [ histS ] = Hist2Din1D( firstDim,secondDim,binSize )
% Hist2Din1D - Create 2D histogram and then returns it as flatenned 1D Vector
% Syntax: [ histS ] = Hist2Din1D( imfilt,sd,binSize )
% Inputs:
%   firstDim: First dimension of the 2D Histogram
%   secondDim: Second dimension of the 2D Histogram
%   binSize: Bin Size of the 2D Histogram
% Outputs:
%   histS: 2D Histogram, flatenned as 1D Vector
%
% Author: Rupali Khatun (rupali.khatun@live.com)
%         and Soumick Chatterjee (contact@soumick.com)
% Website: http://www.soumick.com
% Sep 2017; Last revision: 11-Dec-2018

    hist2D = histogram2(firstDim,secondDim,binSize);
    histVal = hist2D.Values;
    histValSize = size(histVal);
    histS = reshape(histVal, [1 histValSize(1)*histValSize(2)]);

end

