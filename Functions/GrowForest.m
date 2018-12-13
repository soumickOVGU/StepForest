function [ TB,minErr ] = GrowForest( Fv,L,NumOfTrees )
% GrowForest - Create Random Forest
% Syntax: [ TB,minErr ] = GrowForest( Fv,L,NumOfTrees )
% Inputs:
%   Fv: Feature Vector
%   L: Label Vector
%   NumOfTrees: No of Trees in the Random Forest
% Outputs:
%   TB: Trained Random Forest
%   minErr: Minimum out-of-bag error of the random forest
%
% Author: Rupali Khatun (rupali.khatun@live.com)
%         and Soumick Chatterjee (contact@soumick.com)
% Website: http://www.soumick.com
% Sep 2017; Last revision: 11-Dec-2018

    TB = TreeBagger(NumOfTrees,Fv,L,'OOBPrediction','On');%Training the random forest.
    %TB = TreeBagger(NumOfTrees,Fv,L,'oobpred','On');
    err = oobError(TB);
    minErr = min(err);

end

