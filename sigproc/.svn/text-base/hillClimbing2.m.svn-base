function [NewPeakBin, NewPeakMag] = hillClimbing2(x, negMagThresh, posMagThresh,LeftPeakWidthInSamples,RightPeakWidthInSamples)
% [peakBin, peakMag] = hillClimbing(x, negMagThresh, posMagThresh, logLin)
%
% x				: signal
% negMagThresh	: negative magnitude threshold value for search
% posMagThresh	: positive magnitude threshold value for search
%
% peak detector:
% picks peaks eg. FFT spectrum
%
% returns arrays peakBin[] and peakMag[]
%
% Tae Hong Park
% Princeton University
% park@music.princeton.edu
%
% updated May 2001
%

xLen            = length(x);
maxMag          = max(x);
minPeakMag      = min(x);
tempPeakMag 	 = minPeakMag;
foundPeak       = 0;
peakCount       = 1;

i               = 1;
outOfBound      = 0;
slope           = x(i+1)-x(i);

while 1%i < xLen-1
    % positive slope start
    % ---------------------------
    while slope > 0
        
        i = i+1;        
        if i > xLen-1                           % out of bound: > analysis window
            if ~isempty(peakBin)
            [NewPeakBin,NewPeakMag]=DeletePeaksWithLargeWidth(peakBin,peakMag, x, negMagThresh, posMagThresh,LeftPeakWidthInSamples,RightPeakWidthInSamples);
        end
            return;
        end
        
        slope = x(i+1)-x(i);
        
        if foundPeak == 1
            if x(i) > tempPosMagThreshOffset + posMagThresh;
                % reset, new hill to climb
                tempPeakMag 		= minPeakMag;
                foundPeak       = 0;
            end
        end
        
    end % positive slope end
    
    % temporarily store peak candidate      
    if x(i) > tempPeakMag
        tempPeakBin      = i;
        tempPeakMag = x(i);
    end
    
    % negative slope start
    % ----------------------------
    while slope <=0
        
        if foundPeak == 0               
            if tempPeakMag - x(i) > negMagThresh
                foundPeak = 1;
                peakBin(peakCount)      = tempPeakBin;
                peakMag(peakCount)      = tempPeakMag;
                peakCount					  = peakCount+1;
            end     
        end
        
        i = i+1;
        if i > xLen-1                                   % out of bound: > analysis window
            if ~isempty(peakBin)
            [NewPeakBin,NewPeakMag]=DeletePeaksWithLargeWidth(peakBin,peakMag, x, negMagThresh, posMagThresh,LeftPeakWidthInSamples,RightPeakWidthInSamples);
        end
            return;
        end
        
        slope = x(i+1)-x(i);    
        
    end % negative slope end
    
    % found peak 
    % ----------------------------- 
    if foundPeak == 1
        tempPosMagThreshOffset = x(i);
    end
end

%Check Width of peaks;
%If width larger than MaxPeakWidth delete peakbin

function [NewPeakBin,NewPeakMag]=DeletePeaksWithLargeWidth(peakBin,peakMag, x, negMagThresh, posMagThresh,LeftPeakWidthInSamples,RightPeakWidthInSamples);

NewPeakBin=[];
NewPeakMag=[];

for i=1:length(peakBin)
    %get points left and right of peakbin
    leftpoint=peakBin(i)-LeftPeakWidthInSamples;
    rightpoint=peakBin(i)+RightPeakWidthInSamples;
    if leftpoint<1
        leftpoint=1;
    end;
    if rightpoint>length(x)
        rightpoint=length(x);
    end;
    leftidxbelowleftthreshold=find(x(leftpoint:peakBin(i))<peakMag(i)-posMagThresh);
    rightidxbelowrightthreshold=find(x( peakBin(i):rightpoint)<peakMag(i)-negMagThresh);
    
    if  ~isempty(leftidxbelowleftthreshold) & ~isempty(rightidxbelowrightthreshold)
        NewPeakBin=[NewPeakBin peakBin(i)];
        NewPeakMag=[NewPeakMag peakMag(i)];
    end;
end;