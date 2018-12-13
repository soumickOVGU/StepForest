function [ Lout  ] = TestProcess( TB,mp,w,wSlider,binSize )
% TestProcess - Main function for Test (Segmentation) process
% Syntax: [ Lout  ] = TestProcess( TB,mp,w,wSlider,binSize )
% Inputs:
%   TB: Trained Random Forest (Tree Bagger) Object
%   mp: Mixed Patches from the last random forest prediction
%   w: Window size of the new patches
%   wSlider: Window size of the Slider
%   binSize: Bin size for the 2D Histogram
% Outputs:
%   Lout: Predicted Labels for each patch (mp)
%
% Author: Rupali Khatun (rupali.khatun@live.com)
%         and Soumick Chatterjee (contact@soumick.com)
% Website: http://www.soumick.com
% Sep 2017; Last revision: 11-Dec-2018

    [a,b]=size(mp);
    b=b/3;
    k=1;
    for x=1:w:b
        for y=1:w:a
            im=imcrop(mp,[x y w w]);
            [ Fr(k,:), Fg(k,:), Fb(k,:),FvHist2DR(k,:),FvHaraR(k,:),FvHist2DG(k,:),FvHaraG(k,:),FvHist2DB(k,:),FvHaraB(k,:) ] = FeaturesGeneration( im,wSlider,binSize );
            k=k+1;
        end
    end
    Fv=[Fr Fg Fb FvHist2DR FvHist2DG FvHist2DB FvHaraR FvHaraG FvHaraB];
    [Lp,~] = predict(TB,Fv);%Predict using the traind classifier.
    LintermTemp = sprintf('%s*', Lp{:}); %this and next line is used to convert cell array to double array
    Lout = sscanf(LintermTemp, '%f*');
end

