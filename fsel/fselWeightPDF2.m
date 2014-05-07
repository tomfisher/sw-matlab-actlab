function veWeight = fselWeightPDF2( maDataTrain, veLabelTrain, veWeight, varargin )
% function veWeight = fselWeightPDF2( maDataTrain, veLabelTrain, veWeight, varargin )
%
% Weighting based on individual feature PDF. This method is used for
% feature selection in detection problems where one class should be
% seperated from the embedding data.
% 
% WARNING: Works for two classes only. Zero class has label=0.

% Copyright 2007, 2008 Oliver Amft, ETH Zurich

[NObs, NrFeatures] = size(maDataTrain);

[Mode PDFRes UsePDFBounds verbose] = process_options(varargin, ...
	'Mode', 'PDFDiff',   'pdfres', round(NObs^(1/3))+(NObs<8), ...
	'UsePDFBounds', [],   'verbose', 1);

if ~isempty(UsePDFBounds), 
	warning('fsel:fselWeightPDF2', 'Use of ''UsePDFBounds'' is depricated.'); 
end;

fmtargets = maDataTrain(veLabelTrain ~= 0,:);
fmembedding =  maDataTrain(veLabelTrain == 0,:);

fscore = zeros(1, size(fmtargets,2));
for f = 1:NrFeatures
	[th thc] = hist(fmtargets(:,f), PDFRes);  th = th/size(fmtargets,1);
	zh = hist(fmembedding(:,f), thc)/size(fmembedding,1);
	switch Mode
		case 'MIExcl'  % MI weight, excluding target class objects in zh
			% OAM REVISIT: Inspired by fselWeightMutualInformation  - not tested!
			fscore(f) = sum( th .* (log2(th) - log2(zh)) );
			
		case 'PDFDiff'		% advantageous at least in small sample sizes (few PDF bins)
			fscore(f) = sum( abs(th - zh) );
			
		case 'PDFDiffNoBounds'
			fscore(f) = sum( abs(th(2:end-1) - zh(2:end-1)) );  % dh(dh<0) = 0;
			
		otherwise
			error('Mode ''%s'' not supported.', Mode);
	end;


	if (0)
		fh = figure; plot(th, 'r'); hold('on'); plot(zh, 'g'); plot([0 dh 0], 'b');  legend({'Target PDF', 'NULL', 'DIFF'});
		title(sprintf('Feature: %u  Score: %1.3f', f, fscore(f)));
		xlim([2 PDFRes-2]);   % ylim([0 0.1]);    xlim([5 35])
		fprintf('\n%s: Break, resume with ''return''.', mfilename);
		keyboard;	close(fh);
	end;
	
	if (verbose>0) && (fscore(f) < 0.1)
		fprintf('\n%s: No diff in PDF for feature %u (%1.3f)', mfilename, f, fscore(f)); 
	end;
end;

veWeight = fscore / max(fscore);
veWeight(isnan(veWeight)) = 0;