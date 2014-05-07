% main_segstats
%
% Analysis and statistics of SWAB segmentation result

% requires
Partindex;
FeatureString;
thisclass;


SegMode = cell2str(FeatureString, '-');

NoConfig = true;
initmain;


% ------------------------------------------------------------------------
% preparations
% ------------------------------------------------------------------------
filename = dbfilename(RepEntry, 'indices', Partindex, 'prefix', 'SWAB', 'suffix', SegMode, 'subdir', 'SEG');
load(filename, ...
    'FeatureString', 'SWABConfig', 'DSSet');

if (~test('NoLoad'))
    thisDataStruct = makedatastruct(Repository, Partindex, FeatureString, DSSet);
end;


% SampleRate =  cla_getmarkersps(Repository, Partindex, 'singlesps', true);
SampleRate =  thisDataStruct.SampleRate;
partsize = size(thisDataStruct.data,1);

% partsize = cla_getpartsize(Repository, Partindex);
[allseglist partoffsets] = cla_getseglist(Repository, Partindex, 'SampleRate', SampleRate);

% find labels for current class
classseglist = segment_findlabelsforclass(allseglist, thisclass);

% ------------------------------------------------------------------------
% fetch segmentation
% ------------------------------------------------------------------------
aseglist = cla_getsegmentation(Repository, Partindex, 'SampleRate', SampleRate, 'SegMode', SegMode);

fprintf('\n%s: segments: %u', mfilename, size(aseglist,1));
fprintf('\n%s: partsize: %u', mfilename, sum(partsize));
fprintf('\n%s: allseglist: %u', mfilename, size(allseglist,1));
fprintf('\n%s: classseglist: %u', mfilename, size(classseglist,1));

% ------------------------------------------------------------------------
% fetch view data
% ------------------------------------------------------------------------
fprintf('\n%s: Process view data...', mfilename);
fprintf('\n%s: Process features for part %u...', mfilename, Partindex);
thisFeatures = makefeatures([1 partsize], thisDataStruct, 'swmode', 'cont');
% clear FeatureSet partsize;
% features_filename = dbfilename(Repository, Partlist, 'Features_Part', [], 'FEATURES');
% load(features_filename, 'FeatureSet', 'partsize', 'SaveTime');
% fprintf('\n%s: Feature file save at: %s', mfilename, datestr(SaveTime));

%thisFeatures = makefeatures([1 sum(partsize)], DataStruct(1), 'swmode', 'cont');

% %omits max. swsize-1 samples at the end (watch for multiple streams):
%thisFeatures = makefeatures_fusion([1 sum(partsize)], DataStruct); 




% ------------------------------------------------------------------------
% Segmentation eval
% ------------------------------------------------------------------------

figure; hold on;
plot(thisFeatures(:,1)); 
% plot(thisFeatures(:,[1 2])); ylim([0 60]);
segment_plotmark(thisFeatures(:,1), aseglist, 'style', 'ro');

% seglist2 = loadsegmentation(Repository, Partindex, 'SampleRate', SampleRate, 'SegType', 'SWAB_SEG2');
% segment_plotmark(thisFeatures(:,1), seglist2, 'style', 'ko');
% ylim([0 45]); xlim([1 4]*1e3);

segment_plotmark(thisFeatures(:,1), classseglist, 'fill', 'style', 'k');

% segment_plotmark(1:cont_trainslices(tslice,2), this_trainSeg{end}, 'similarity', this_trainDist{end}, 'width', 2, 'style', 'b-');
% plot(thisFeatures(:,3)*300, 'r');

fprintf('\n');
return;



% ------------------------------------------------------------------------
% compare to CRN Toolbox
% ------------------------------------------------------------------------
aseglist2 = load('/home/oam/eth/projects/wearIT/DavidGestures/toolbox/test.txt');
aseglist2(:,1) = aseglist2(:,1)+1;
aseglist2(find(aseglist2(:,2)>partsize),:) = [];

figure; hold on;
plot(thisFeatures(:,1)); 
segment_plotmark(thisFeatures(:,1), aseglist2, 'style', 'ko');

[seglisteq segnumbers segmissed] = segment_compare(aseglist, aseglist2);




% => copied to phc2006.m
% ------------------------------------------------------------------------
% Pervasive Health 2006 swallowing dataset
% EMG segmentation graph from Partindex = 39
% ------------------------------------------------------------------------
thisrange = [202400 sum(partsize)-900];
thisFeatures = makefeatures(thisrange, DataStruct(1), 'swmode', 'cont');
thisseglist = seglist(segment_findincluded(thisrange, seglist),:)-thisrange(1);
thisSegLables = allSegLabels{1}(segment_findincluded(thisrange, allSegLabels{1}),:)-thisrange(1);

fh=figure; hold on;
plot(thisFeatures(:,1)); 
segment_plotmark(thisFeatures(:,1), thisseglist, 'style', 'ko');
segment_plotmark(thisFeatures(:,1), thisseglist, 'style', 'kx');
plotfmt(fh, 'lw', 2, 'ms', 8);
segment_plotmark(thisFeatures(:,1), thisSegLables, 'fill', 'style', 'k');
% plotfmt(fh, 'xl', 'Time [s]', 'xtl', {''});
% plotfmt(fh, 'yl', 'IH-EMG amplitude', 'ytl', {''});
xlim([1 size(thisFeatures,1)]);
plotfmt(fh, 'xl', '', 'xtl', {''}, 'yl', '', 'ytl', {''});
plotfmt(fh, 'box', 'on');
% use figure save instead when resizing the plot.
plotfmt(fh, 'prtif', 'emgswab'); 


