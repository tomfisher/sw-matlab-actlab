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

function [MutInf]=MI_I(x,y)

% x: first feature
% y: second feature

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       determin the unique elements of x and their appearance            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UniqueX: unique elements of x
% AnzUniqueX: appearance of x

[UniqueX Last]=unique(sort(x),'last');
AnzUniqueX=Last-[0;Last(1:(length(Last)-1))];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         determine pdf of x for conditional probability                  %    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Px=AnzUniqueX/length(x); 
 

MutInf=0;

% Points of evaluation 
q=0:1:100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             determine P(x) and P(y) for MI                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PX=ksdensity(x,q,'kernel','epanechnikov','width',h); 
% PY=ksdensity(y,q,'kernel','epanechnikov','width',h);

% alternativ ksdensity -> hist(has to be normed)

PX=hist(x,q)/length(x);
PY=hist(y,q)/length(y);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         Evaluate MI                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



for u=1:length(UniqueX)
    % conditional prob of y when x
    % Pxy=ksdensity(y(x==UniqueX(u)),q,'kernel','epanechnikov','width',h); 
    Pxy=hist(y(x==UniqueX(u)),q)/length(find(x==UniqueX(u)));
    
    %joint probability
    PVer=Pxy.*Px(u);
    for k=1:length(q)
        %MI between feature x and y
        if PVer(k)>0 && PX(k)>0 && PY(k)>0 
            MutInf=MutInf+PVer(k).*log2(PVer(k)/PY(k)/PX(k));
        end
    end
end
















