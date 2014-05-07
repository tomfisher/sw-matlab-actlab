function [peakBin, peakMag] = hillClimbing(x, negMagThresh, posMagThresh)
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

peakBin(1)      =-1;
peakMag(1)      =-1;
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