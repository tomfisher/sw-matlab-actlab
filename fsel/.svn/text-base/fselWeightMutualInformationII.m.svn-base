%                       Semesterthesis SS 07 
%               Feature Selection for body-worn sensors
%
%                          Daniel Christen
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
%
%                            Sources: 
%  "Input Feature Selection by Mutual Information Based on Parzen Window"
%           Nojun Kwak, Student Member ,IEEE Computer Society,and 
%           Chong-Ho Choi, Member, IEEE

%  "Input Feature Selection for Classification Problems"
%   Nojun Kwak and Chong-Ho Choi, Member , IEEE
%
%  "Using Mutual Information for Selecting Features in Supervised Neural
%   Net Learning" Roberto Battiti, IEEE 1994
%
%  information theoretic Methode: Mutual Information
%
%..........................................................................
%load( 'data_in/bm_marc_st1_orig.mat');
function [veWeight]=fselWeightMutualInformationII(maDataTrain,veLabelTrain,veWeight)
if (~exist('veWeight', 'var')), veWeight = ones(1,size(maDataTrain,2)); end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         Determine number of features                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[AnzSmp,AnzFeat]=size(maDataTrain);


[R C]=size(veLabelTrain);
if C>R
   veLabelTrain=veLabelTrain'; 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Determine MI between classes and features                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



for f=1:AnzFeat
    veWeight(f)=MI_II(maDataTrain(:,f),veLabelTrain);
end


% veWeight=veWeight/max(veWeight);
% veWeight



