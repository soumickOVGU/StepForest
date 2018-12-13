function [Limg,FrImg,FgImg,FbImg,FvHist2DImgR,FvHaraImgR,FvHist2DImgG,FvHaraImgG,FvHist2DImgB,FvHaraImgB,MixPatches,MixGTPatches,ind,mixInd,GTPatchesImg] = TrainProcess(Img,GT,a,b,w,binSize,wSlider,ind,mixInd,MixPatches,MixGTPatches)
% TrainProcess - Main function for Train process - Creates patches, feature and label vectors
% Syntax: [Limg,FrImg,FgImg,FbImg,FvHist2DImgR,FvHaraImgR,FvHist2DImgG,FvHaraImgG,FvHist2DImgB,FvHaraImgB,MixPatches,MixGTPatches,ind,mixInd,GTPatchesImg] = 
%           TrainProcess(Img,GT,a,b,w,binSize,wSlider,ind,mixInd,MixPatches,MixGTPatches)
% Inputs:
%   Img: Input Image/Patch
%   GT: Corresponding grouth truth image/patch
%   a: Size of the input image, dim 1
%   b: Size of the input image, dim 2
%   w: Window size for the new patches
%   binSize: Bin size for the 2D Histogram
%   wSlider: Window slider size for the mean and SD filter
%   ind: Marks the start index of feature vectors (combined for all images)
%   mixInd:  Marks the start mix patch index of feature vectors (combined for all images)
%   MixPatches: Mix image Patches from previous level
%   MixGTPatches: Mix groundtruth Patches from previous level
% Outputs:
%   Limg: Label Vector
%   FrImg: Histogram of the red channel of the image
%   FgImg: Histogram of the green channel of the image
%   FbImg: Histogram of the blue channel of the image
%   FvHist2DImgR: 2D Histogram of the red channel of the image
%   FvHaraImgR: Haralick Texture features of the red channel of the image
%   FvHist2DImgG: 2D Histogram of the green channel of the image
%   FvHaraImgG: Haralick Texture features of the green channel of the image
%   FvHist2DImgB: 2D Histogram of the blue channel of the image
%   FvHaraImgB: Haralick Texture features of the blue channel of the image 
%   MixPatches: New Mix image patches
%   MixGTPatches: New Mix groundtruth patches
%   ind: Marks the end index of feature vectors (combined for all images)
%   mixInd: Marks the end mix patch index of feature vectors (combined for all images)
%   GTPatchesImg: New Grouthtruth patches
%
% Author: Rupali Khatun (rupali.khatun@live.com)
%         and Soumick Chatterjee (contact@soumick.com)
% Website: http://www.soumick.com
% Sep 2017; Last revision: 11-Dec-2018

    noOfPatch = round(a/w)*round(b/w);
    Limg = zeros(noOfPatch, 1);
    FrImg = zeros(noOfPatch, 256);
    FgImg = zeros(noOfPatch, 256);
    FbImg = zeros(noOfPatch, 256);        
    FvHist2DImgR = zeros(noOfPatch, binSize*binSize);
    FvHist2DImgG = zeros(noOfPatch, binSize*binSize);
    FvHist2DImgB = zeros(noOfPatch, binSize*binSize);
    GTPatchesImg = cell(1, noOfPatch); %Only required for last window size, in our case 10
    indImg = 1;
    for x=1:w:b
        for y=1:w:a
            im=imcrop(Img,[x y w w]);
            
            [ FrImg(indImg,:), FgImg(indImg,:), FbImg(indImg,:),FvHist2DImgR(indImg,:),FvHaraImgR(indImg,:),FvHist2DImgG(indImg,:),FvHaraImgG(indImg,:),FvHist2DImgB(indImg,:),FvHaraImgB(indImg,:) ] = FeaturesGeneration( im,wSlider,binSize );
            
            imk=imcrop(GT,[x y w w]);
            GTPatchesImg{indImg} = imk;  %Only required for last window size, in our case 10

            if((max(imk(:))==min(imk(:))) && (min(imk(:))==1))
                Limg(indImg,:)=1; %Gland
            elseif(max(imk(:))~=min(imk(:)))
                Limg(indImg,:)=3; %Mix
                MixPatches{mixInd} = im;
                MixGTPatches{mixInd} = imk;
                mixInd = mixInd + 1;
            elseif((max(imk(:))==min(imk(:))) && (min(imk(:))==0))
                Limg(indImg,:)=2; %Non gland
            else
                Limg(indImg,:)=0; %Error
            end
            ind = ind +1;
            indImg = indImg + 1;
        end
    end
end