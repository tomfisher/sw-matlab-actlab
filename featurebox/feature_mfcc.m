function [mfccCoeffs, mfccCoeffsDCTMatrix] = feature_mfcc(sdata, varargin)
% function [mfccCoeffs, mfccCoeffsDCTMatrix] = feature_mfccCoeffs(sdata, varargin)
%
% Compute Mel-Frequency Cepstrum Coefficients.
% 
% Copyright 2007 Oliver Amft
%
% based on function "mfccCoeffs" in Auditory Toolbox by Malcolm Slaney
% (http://www.slaney.org/malcom) see Auditory Toolbox for details
%
% based on function "ma_mfccCoeffs" from MA Toolbox by Elias Pampalk
% (http://www.ofai.at/~elias.pampalk/ma/index.html)

% 2011-08-05 bugfix (identified by Mirco Rossi): swapped nrTotalFilters, WindowSize parameters
% 2011-08-05 check that nrTotalFilters <= nrCepsCoeffs (voicebox)

mfccCoeffs = []; mfccCoeffsDCTMatrix = [];


[MelMethod SampleRate fftsize max_dB idFirstCoeff nrCepsCoeffs nrTotalFilters WindowSize WindowStep swmode VoiceboxFlags] = process_options(varargin, ...
	'MelMethod', 'Voicebox', 'SampleRate', 44100, 'fftsize', 512, 'max_dB', 0, ...
	'idFirstCoeff', 1, 'nrCepsCoeffs', 12, 'nrTotalFilters', 0, ...
	'WindowSize', 0, 'WindowStep', 0, 'swmode', 'exit', ...
    'VoiceboxFlags', '');

if isempty(WindowSize) || (WindowSize<=0), WindowSize = fftsize; end;
if isempty(WindowStep) || (WindowStep<=0), WindowStep = fftsize; end;

if (length(sdata) < WindowSize)
	fprintf('\n%s: Signal vector is smaller than window.', mfilename);
	return;
end;

switch lower(swmode)
	case 'exit'
		% omit data not fitting to step size
		sdata = sdata(1:(floor((length(sdata)-WindowSize)/WindowStep)*WindowStep) + WindowStep);
end;

switch lower(MelMethod)
	case 'voicebox'
		% internally used filters; for SampleRate=44100, nrTotalFilters=32
		if isempty(nrTotalFilters) || (nrTotalFilters<=0), nrTotalFilters = floor(3*log(SampleRate)); end;
        if nrTotalFilters <= nrCepsCoeffs, fprintf('\n%s: Warning: nrTotalFilters (%u) too small for nrCepsCoeffs (%u).', mfilename, nrTotalFilters, nrCepsCoeffs); end;
		
	case 'auditorynative'
		% nothing to do

	case 'auditory'
		% OAM REVISIT: How to adapt to other sampling rates?
		% auditory toolbox, 11kHz? 16kHz?
		lowestFrequency = 400/3;
		nrLinFilters = 13;
		nrLogFilters = 27;
		linearSpacing = 200/3;
		logSpacing = 1.0711703;

		% Keep this around for later....
		nrTotalFilters = nrLinFilters + nrLogFilters;

		% Now figure the band edges.  Interesting frequencies are spaced
		% by linearSpacing for a while, then go logarithmic.  First figure
		% all the interesting frequencies.  Lower, center, and upper band
		% edges are all consequtive interesting frequencies.
		freqs = lowestFrequency + (0:nrLinFilters-1)*linearSpacing;
		freqs(nrLinFilters+1:nrTotalFilters+2) = ...
			freqs(nrLinFilters) * logSpacing.^(1:nrLogFilters+2);

	case 'matoolbox'
		% MA toolbox parameters (elias 13.6.2004)
		freqband = [20 floor(SampleRate/2)];
		nrTotalFilters = 40;

		f = freqband(1):freqband(2);
		mel = log(1+f/700)*1127.01048;
		m_idx = linspace(1, max(mel), nrTotalFilters+2);
		f_idx = zeros(1,nrTotalFilters+2);
		for i=1:nrTotalFilters+2,
			[dummy f_idx(i)] = min(abs(mel - m_idx(i)));
		end
		freqs = f(f_idx);

end;


if (max_dB)
	% rescale to dB max (default is 96dB = 2^16)
	sdata = sdata * (10^(max_dB/20));
end;



switch lower(MelMethod)
	case 'voicebox'
		sdata = sdata + eps*(sdata==0); % prevent div by zero if signal is zero
		% voicebox does frame window filtering (Hamming) itself
        % bug identified by Mirco Rossi, swapped nrTotalFilters, WindowSize parameters, 2011-08-05
		mfccCoeffs = melcepst(sdata', SampleRate, VoiceboxFlags, nrCepsCoeffs, nrTotalFilters, WindowSize, WindowStep);
        
	case 'auditorynative'
		%  auditory does frame window filtering (Hamming) itself
		mfccCoeffs = mfcc(sdata, SampleRate, round(SampleRate/WindowStep));

	otherwise
		% MelMethod: matoolbox, auditory

		freq_lower  = freqs(1:nrTotalFilters);
		freq_center = freqs(2:nrTotalFilters+1);
		freq_upper  = freqs(3:nrTotalFilters+2);


		% We now want to combine FFT bins so that each filter has unit
		% weight, assuming a triangular weighting function.  First figure
		% out the height of the triangle, then we can figure out each
		% frequencies contribution
		mfccCoeffsFilterWeights = zeros(nrTotalFilters,fftsize/2+1);
		triangleHeight = 2./(freq_upper-freq_lower);
		% fftFreqs = (0:fftSize-1)/fftSize*samplingRate;
		fftFreqs = linspace(0, floor(SampleRate/2), fftsize/2+1);

		% OAM REVISIT: use half or full FFT spectrum?
		for f = 1:nrTotalFilters
			mfccCoeffsFilterWeights(f,:) = ...
				(fftFreqs > freq_lower(f) & fftFreqs <= freq_center(f)) .* ...
				triangleHeight(f).*(fftFreqs-freq_lower(f))/(freq_center(f)-freq_lower(f)) + ...
				(fftFreqs > freq_center(f) & fftFreqs < freq_upper(f)).* ...
				triangleHeight(f).*(freq_upper(f)-fftFreqs)/(freq_upper(f)-freq_center(f));
		end;
		%semilogx(fftFreqs,mfccCoeffsFilterWeights'); axis([0 freq_upper(nrTotalFilters) 0 max(mfccCoeffsFilterWeights(:))]);   title('Filterbank');

		% Figure out Discrete Cosine Transform.  We want a matrix
		% dct(i,j) which is nrTotalFilters x cepstralCoefficients in size.
		% The i,j component is given by
		%                cos( i * (j+0.5)/nrTotalFilters pi )
		% where we have assumed that i and j start at 0.
		mfccCoeffsDCTMatrix = 1/sqrt(nrTotalFilters/2)*cos((1-idFirstCoeff:(nrCepsCoeffs-1))' * ...
			(2*(0:(nrTotalFilters-1))+1) * pi/2/nrTotalFilters);
		mfccCoeffsDCTMatrix(1,:) = mfccCoeffsDCTMatrix(1,:) * sqrt(2)/2; % use first coeff
		%imagesc(mfccCoeffsDCTMatrix); set(gca,'ydir','normal','fontsize',8); xlabel('MFC-Coeff'); ylabel('Mel Band'); colormap gray; title('DCT');


		% determine result size and init variables
		frames = floor(length(sdata)/WindowStep);
		% sswindow mode: exit => ignore remainder of windowing procedure
		mel = zeros(frames, nrTotalFilters);
		%ceps = zeros(frames, nrCepsCoeffs-1+idFirstCoeff, frames);

		% auditory toolbox uses a preemphasis filter and ham window
		% hamWindow = 0.54 - 0.46*cos(2*pi*(0:windowSize-1)/windowSize);
		w = hann(fftsize);

		% process frames
		idx = 1:WindowSize;
		for i=1:frames,
			X = abs( fft(sdata(idx).*w, fftsize) / sum(w)*2 ) .^ 2;
			mel(i,:) = mfccCoeffsFilterWeights * X(1:end/2+1);

			idx = idx + WindowStep;
		end

		if (max_dB), mel(mel<1) = 1; end; % for dB

		% compute dB and compress using DCT
		mfccCoeffs = mfccCoeffsDCTMatrix*10*log10(mel');
		
		% rows: observations (frames), cols: coeffs
		mfccCoeffs = mfccCoeffs';
end; 


% imagesc(mfccCoeffs'); set(gca,'ydir','normal','xtick',[]); title('mfccCoeffs Representation');
% imagesc(mfccCoeffsDCTMatrix' * mfccCoeffs'); set(gca,'ydir','normal','xtick',[]);  title('Reconstructed');
