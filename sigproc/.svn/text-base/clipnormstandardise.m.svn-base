function [Ofmtrain Ofmtest fclips fmeans fstds] = clipnormstandardise(Ifmtrain, Ifmtest, varargin)
% function [Ofmtrain Ofmtest fclips fmeans fstds] = clipnormstandardise(Ifmtrain, Ifmtest, varargin)
% 
% Clip and normalise as instructed. Used for classification and spotting.
% If fmtrain is empty, the training step is omitted. Clipping/normalising
% parameters should be provided in this case.
% 
% See also: main_spotidentify, main_isoclassify, main_spotfusion
% 
% Copyright 2008 Oliver Amft

[DoClip, DoNorm, DoClipLimit DoClipTestData fclips fmeans fstds verbose] = process_options(varargin, ...
	'DoClip', true, 'DoNorm', true, 'DoClipLimit', 10, 'DoClipTestData', false, ...
	'fclips', [], 'fmeans', [], 'fstds', [], 'verbose', 1);

Ofmtrain = Ifmtrain;  Ofmtest = Ifmtest;

% clip data
if (DoClip)
	if ~isempty(Ofmtrain),  [Ofmtrain fclips] = mclipping(Ofmtrain, 'sdlimit', DoClipLimit);  end;
	if (DoClipTestData), Ofmtest = mclipping(Ofmtest, 'limitvals', fclips); end;
else
	if (verbose), fprintf('\n%s: *** Do NOT clip.', mfilename); end;
end;

% standardise/normalise data
if (DoNorm==1)
	% standardise
	if ~isempty(Ofmtrain), [Ofmtrain fmeans fstds] = mstandardise(Ofmtrain); end;
	Ofmtest = mstandardise(Ofmtest, fmeans, fstds);

elseif (DoNorm==2)
	% normalise
	if ~isempty(Ofmtrain),  [Ofmtrain fmeans] = mnormalise(Ofmtrain, 'norm'); end;
	Ofmtest = mnormalise(Ofmtest, 'norm', fmeans);

else
	if (verbose), fprintf('\n%s: *** Do NOT normalise.', mfilename); end;
end;
