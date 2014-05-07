function cmetrics = cmetrics_mkmatrixfromseg(sections_REF, sections_EVAL, varargin)
% function cmetrics = cmetrics_mkmatrixfromseg(sections_REF, sections_EVAL, varargin)
% 
% Compute confusion matrix from spotting result
%
% Apporach (as used by Ward2006 PAMI): Score every sample of the result
% segmentation to GT. For this purpose segmentations are converted into
% labelings and compared samplewise.
% 
% See also: 
%   cmetrics_mkmatrixfromcell, cmetrics_mkmatrix, cmetrics_mkstats 
% 
% Copyright 2007-2008 Oliver Amft

if isempty(sections_REF), totalsize_REF = 0; else totalsize_REF = max(sections_REF(:,2)); end;
if isempty(sections_EVAL), totalsize_EVAL = 0; else totalsize_EVAL = max(sections_EVAL(:,2)); end;
est_totalsize = max( [totalsize_REF totalsize_EVAL] );

[totalsize, LabelConfThres, CountNullClass, ClassIDs, ConvertREF] = process_options(varargin, ...
	'totalsize', est_totalsize, 'LabelConfThres', 0, 'CountNullClass', true, ...
    'ClassIDs', [], 'ConvertREF', false);

if (totalsize<est_totalsize)
	warning('MATLAB:cmetrics_mkmatrixfromseg', 'Param totalsize is smaller than actual sections.');
end;

if LabelConfThres>0
	if size(sections_REF,2)<6, error('\n%s: No confidence information found!', mfilename); end;

	rm_sections_REF = sections_REF( sections_REF(:,6)<LabelConfThres, : );
	sections_REF( sections_REF(:,6)<LabelConfThres, : ) = [];
else
	rm_sections_REF = [];
end;

rm_ovs1 = segment_countoverlap(sections_EVAL, rm_sections_REF) > 0; % overlaps with rm_sections_REF
rm_ovs2 = segment_countoverlap(sections_EVAL, sections_REF) == 0; % NOT overlap with sections_REF
sections_EVAL(rm_ovs1 & rm_ovs2,:) = [];  % excude sections


% convert REF labels class IDs to numbers
if ConvertREF
    this_ClassIDs = unique(sections_REF(:,4));
    for c = 1:length(this_ClassIDs)
        sections_REF( this_ClassIDs(c) == sections_REF(:,4), 4 ) = c;
    end;
end;



% lets hope that sections_REF is not empty
if isempty(ClassIDs), ClassIDs = unique(sections_REF(:,4)); end;


% lets hope that sections_REF is not empty
if CountNullClass && all(ClassIDs ~= 0)
    ClassIDs = unique( [ 0; ClassIDs ] );    % account for NULL (0)
end;

classes = length(ClassIDs);
cmetrics = zeros(classes);


% create confusion matrix
labeling_REF = segments2labeling(sections_REF, totalsize);
labeling_EVAL = segments2labeling(sections_EVAL, totalsize);
for c = 1:classes
    actual = labeling_REF==ClassIDs(c);
    [id cnt] = countele(labeling_EVAL(actual));
    for j = 1:length(id), cmetrics(c, id(j)==ClassIDs) = cnt(j); end;
end;


% OAM REVISIT: Find out, when the code below fails
if (0)
    % % progress = 0.1;
    for i = 1:totalsize
        %progress = print_progress(progress, i/totalsize);

        actual = find(labeling_REF(i)==ClassIDs);
        predicted = find(labeling_EVAL(i)==ClassIDs);
        cmetrics( actual, predicted ) = cmetrics( actual, predicted ) + 1;
    end;
end;