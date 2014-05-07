function ffthist = get_ffthist(signal, WindowSize, WindowStep, verbose)
% function ffthist = get_ffthist(signal, WindowSize, WindowStep, verbose)
%
% Summed power spectrum of input signal. A sliding window is moved over the
% data and the power spectrum is calculated for each window.
%
% signal        - Signal vector
% WindowSize    - Sliding window size (this defines the FFT size as well!)
% WindowStep    - Should be set to WindowSize
% verbose       - Control figure plot: 0=no figure, 1=plot, default: 0
%
% example call: This will use a 512-pt. FFT sliding over mydatavector to
% plot the summed power spectrum
%
% get_ffthist(mydatavector, 512, 512, 1);
%
% Copyright 2007 Oliver Amft

if (exist('verbose')~=1) verbose = 0; end;

if (verbose) fh=figure; end;

if (size(signal,1)-WindowSize+1 < 1)
    error('SWINDOW: Signal vector is smaller than window.');
    return;
end;

result = repmat(0, 1, WindowSize/2);
for startpoint = 1 : WindowStep : size(signal,1)-WindowSize+1
    yt = signal(startpoint:startpoint+WindowSize-1,:);
    
    if (size(yt,1) > 1)
        %         result = result + get_spectrum(yt);
        %Y = get_spectrum(yt);
		
		% Normalize this sequence
		rms = sqrt(sum(yt.^2) / WindowSize);
		yt = yt ./ rms;

		% Hanning Window
		yth = yt .* hanning(WindowSize);

		% Calculate spectrum
		Y = abs(fft(yth, WindowSize));
		Y = Y(1:floor(WindowSize/2)).';
		
        Pyy = Y.* conj(Y) / WindowSize;
        result = result + Pyy;

        if (verbose) 
            plot(result); 
            title(['Progress: ' mat2str(round(startpoint/size(signal,1)*100)) '%']); 
            drawnow; 
        end;
    end;
end;

if (startpoint>size(signal,1)-WindowSize+1)
    error('Something wrong here.');
    return;
end;

if (verbose)
    xlabel('Frequency (Hz)');
    ylabel('Power');
    title('Frequency content of y');
end;

if (nargout)
	ffthist = result;
end;
