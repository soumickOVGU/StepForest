function [ Out ] = RegenerateGT( Out,Lout,cr,w,ImageName,path )
% RegenerateGT - Generate the segmentation mask based on the prediction
% Syntax: [ Out ] = RegenerateGT( Out,Lout,cr,w,ImageName,path )
% Inputs:
%   Out: Input Image 
%   Lout: Reference Image, to be used for normalization
%   cr: Type of normalization
%   w: Type of normalization
%   ImageName: Type of normalization
%   path: Type of normalization
% Outputs:
%   Out: Generated Segmentation Mask
%
% Author: Rupali Khatun (rupali.khatun@live.com)
%         and Soumick Chatterjee (contact@soumick.com)
% Website: http://www.soumick.com
% Sep 2017; Last revision: 11-Dec-2018

    indg=find(Lout==1);
    for i=1:length(indg)
        crd=cr(indg(i),:);
        Out(crd(2):crd(2)+w,crd(1):crd(1)+w)=1;
    end
    outputFileName = char(fullfile(path,strcat(ImageName, '_AfterWindowSize',num2str(w), 'withRGBnHaralick.bmp'))); 
    imwrite(Out, outputFileName);
end

