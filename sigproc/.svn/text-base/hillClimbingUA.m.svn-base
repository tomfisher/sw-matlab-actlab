function [peakBin, peakMag] = hillClimbingUA(x, negMagThresh, posMagThresh)
% [peakBin, peakMag] = hillClimbingUA(x, negMagThresh, posMagThresh, logLin)
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

% add UA
if xLen<10
    peakBin=inf;
    peakMag=inf;
    return;    
end


slope           = x(i+1)-x(i);

while i < xLen-1
        % positive slope start
        % ---------------------------
        while slope > 0

                i = i+1;       
                if i > xLen-1 % out of bound: > analysis window
		  % add UA
		  %peakCount
        		  if (peakCount==1)
		            peakBin=inf;
		            peakMag=inf;
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
	          %peakCount 
		  %% add UA
		          if (peakCount==1)
		            peakBin=inf;
		            peakMag=inf;
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

% add UA
 if (peakCount==1)
   peakBin=inf;
   peakMag=inf;
 end
 return;
