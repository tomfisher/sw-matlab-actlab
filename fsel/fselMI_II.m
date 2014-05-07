%                         Semesterthesis SS 07 
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
%  external function for fselSortMIFS.m
% 
%
%..........................................................................
%load( 'data_in/bm_marc_st1_orig.mat');
function [MutInf]=MI_II(x,y)


% x: first feature
% y: second feature

MutInf=0;

% Points of evaluation 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Determine the pdf of  X and Y                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PX=ksdensity(x,q,'kernel','epanechnikov','width',h); 
% PY=ksdensity(y,q,'kernel','epanechnikov','width',h);
% X and Y are the rounded to next upper integer of x and y
% alternativ ksdensity -> hist(has to be normed)
q=0:1:100;
PX=hist(x,q)/length(x);
PY=hist(y,q)/length(y);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Determine the joint Probabilty of x and y
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
XY=[x y];

PXY=hist3(XY,{0:1:100 0:1:100})/length(x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         Evaluate MI                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ix=1:1:100
    for iy=1:1:100
        if PXY(ix,iy)~=0 && PX(ix)~=0 && PY(iy)~=0
            MutInf=MutInf+PXY(ix,iy)*log2(PXY(ix,iy)/PX(ix)/PY(iy));
        end
    end
end










