function [ Fr,Fg,Fb,FvHist2DR,FvHaraR,FvHist2DG,FvHaraG,FvHist2DB,FvHaraB ] = FeaturesGeneration( im,wSlider,binSize )
% FeaturesGeneration - For extracting features from the input images
% Syntax: [ Fr,Fg,Fb,FvHist2DR,FvHaraR,FvHist2DG,FvHaraG,FvHist2DB,FvHaraB ] = FeaturesGeneration( im,wSlider,binSize )
% Inputs:
%   im: Input Image (RGB)
%   wSlider: Window size of the Slider (For Mean and SD Filter)
%   binSize: Bin Size for the 2D Histogram
% Outputs:
%   Fr: Histogram of the red channel of the image
%   Fg: Histogram of the green channel of the image
%   Fb: Histogram of the blue channel of the image
%   FvHist2DR: 2D Histogram of the red channel of the image
%   FvHaraR: Haralick Texture features of the red channel of the image
%   FvHist2DG: 2D Histogram of the green channel of the image
%   FvHaraG: Haralick Texture features of the green channel of the image
%   FvHist2DB: 2D Histogram of the blue channel of the image
%   FvHaraB: Haralick Texture features of the blue channel of the image  
%
% Author: Rupali Khatun (rupali.khatun@live.com)
%         and Soumick Chatterjee (contact@soumick.com)
% Website: http://www.soumick.com
% Sep 2017; Last revision: 11-Dec-2018

    [Fr, Fg, Fb] = RGBHist(im);
    R = im(:,:,1);
    G = im(:,:,2);
    B = im(:,:,3);

    mean = MeanFilter(R,wSlider);
    sd = SDFilter(R,wSlider);
    FvHist2DR = Hist2Din1D(mean,sd,binSize);
    FvHaraR = HaralickFeatures( R );
    
    mean = MeanFilter(G,wSlider);
    sd = SDFilter(G,wSlider);
    FvHist2DG = Hist2Din1D(mean,sd,binSize);
    FvHaraG = HaralickFeatures( G );
    
    mean = MeanFilter(B,wSlider);
    sd = SDFilter(B,wSlider);
    FvHist2DB = Hist2Din1D(mean,sd,binSize);
    FvHaraB = HaralickFeatures( B );

end

