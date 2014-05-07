% main_segvis
% 
% visualise segmentation result
%
% configuration:
% Partindex = 507
% SegConfig.Name = 'SWAB';
% SegConfig.Mode = 'RLAaccx_value';

Partindex;

fprintf('\n');
VERSION = 'V001';
fprintf('\n%s: %s', mfilename, VERSION);

if (~exist('SegConfig','var')), error('Variable SegConfig not provided.'); end;
initdata;

filename = dbfilename(Repository, 'indices', Partindex, 'prefix', SegConfig.Name, 'suffix', SegConfig.Mode, 'subdir', 'SEG');
load(filename, 'seglist', 'segsps');

fprintf('\n%s: Segmentation stats:', mfilename);
fprintf('\n  largest: %u  smallest: %u', max(segment_size(seglist)), min(segment_size(seglist)));
fprintf('\n  # smaller than 3sa: %u', sum(segment_size(seglist)<3));



fprintf('\n%s: Load data set %u...', mfilename, Partindex);
thisDataStruct = makedatastruct(Repository, Partindex, FeatureString, DSSet);
if (length(thisDataStruct) > 1), error('Works on one feature only!'); end;
datasize = fb_getdatasize(thisDataStruct);

fprintf('\n%s: Process features for part %u...', mfilename, Partindex);
thisFeatures = makefeatures([1 datasize], thisDataStruct, 'swmode', 'cont');

fh = figure;
plot(thisFeatures);
xlim([0 1000]);

% see also: segment_plotposition.m
segment_plotmark(thisFeatures, seglist); %, 'style', 'o');

