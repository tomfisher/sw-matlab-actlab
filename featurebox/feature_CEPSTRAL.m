function thisfeature = feature_CEPSTRAL(din, varargin)
% function thisfeature = feature_CEPSTRAL(din, varargin)
%
% Computes the real-valued DFT ceptral coefficients.
% din should be RMS-nomalised, e.g. using feature_rms.m
%
% optional parameters:
%  nrCoeffs  - # of coeff., (default length of din or fftsize if defined)
%  fftsize 
% 
% (modified version of MATLABs 'rceps' function; 
% s.a. Simulink 'Signal Processing Blockset' Real Cepstrum)
% 
% Copyright 2006-2008 Oliver Amft
% Copyright 2007 Martin Kosserow, ETH Zurich

[nrCoeffs fftsize] = process_options(varargin, 'nrCoeffs', [], 'fftsize', length(din));

if ~isempty(nrCoeffs) && (nrCoeffs > floor(fftsize/2))
    % this just leads to zero padding in fft and does not influence the output signals basic characteristics
    fftsize = bitshift(nrCoeffs,1);
end;

% din = feature_rms(din);
hdata = din(:) .* hann(length(din));

thisfeature = real( ifft( log( abs( fft( hdata, fftsize ) ) + 1e-20 ) ) );

% hdata = real(fft( din(:) .* hanning(length(din)), fftsize )) + 1e-20;
% thisfeature = real( ifft( log( hdata(1:round(fftsize/2) ) ) ) );

if ~isempty(nrCoeffs)
    thisfeature = thisfeature(1:nrCoeffs);
end;

thisfeature = thisfeature(:)';



