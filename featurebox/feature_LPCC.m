function coeffs = feature_LPCC(din, varargin)
% function coeffs = feature_LPCC(din, varargin)
% 
% LPCC implementation
% 
% Copyright 2008 Oliver Amft

[LPCRoutine FScale nrCoeffs fftsize] = process_options(varargin, ...
	'LPCRoutine', 'native', 'FScale', 'cepstral', 'nrCoeffs', [], 'fftsize', length(din));

wdata = din .* hann(length(din));

% compute LPCs
switch lower(LPCRoutine)
	case 'native'  % MATLAB Signal Processing Toolbox implementation
		lpcs = real(lpc(wdata, fftsize));
	case 'voicebox'
		% not yet implemented; sliding window handling!
end;


% OAM REVISIT: Here are some steps unclear. 
% (1) need to convert to spectrum ??
% (2) computation of coeffs, according to Watts2006, p60 there is a recursive procedure to do this:
%
%  c(n) = a(n) + sum(k=1:n-1)( (k/n)(c(k)a(n-k) )

% convert to cepstral
hlpcs = real(fft( lpcs(:) .* hann(length(lpcs)), fftsize )) + 1e-20;

switch lower(FScale)
	case 'cepstral'
		coeffs = real( ifft( log( hlpcs(1:round(fftsize/2)) ) ) );
	case 'mel'  % mel-scale frequency warping
		tmp = 2595 * log10( hlpcs(1:round(fftsize/2)) / 700);
		coeffs = real( ifft( tmp ) );
end;

if ~isempty(nrCoeffs)
    coeffs = coeffs(1:nrCoeffs);
end;

coeffs = coeffs(:)';
