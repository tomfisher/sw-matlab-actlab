% main_liveplot EMG
%
% requires:
% SegIndex

initdata;


emg_filename = get_emgfeaturefile(SegIndex);
load(emg_filename, 'EMGFeatures', 'sps');

% adapt begin of data (sometimes artefacts)
emgoffset = 1;
% if (test('RepEntry(Part).DataOffset')) & (~isempty(RepEntry(Part).DataOffset))
%     emgoffset = round(RepEntry(Part).DataOffset/2048*256);
% end;
data = EMGFeatures.Average(emgoffset:end,:);
partsize = size(data,1);



% not used yet => dataviewer()
obj.disp(1).name = 'EMG Channel 1 (regio submentalis 1)';
obj.disp(1).data = data(:,segment_findassoc(RepEntry(SegIndex), 'EMGP5'));
obj.disp(1).func = @plot;
obj.disp(1).ylabel = {'EMG regio submentalis 1 [amp.]'};
obj.splot1 = 1; 

if (size(RepEntry(SegIndex).Sensors,2) > 1)
    obj.disp(2).name = 'EMG Channel 1 (regio sterncleidomatoidea 2)';
    obj.disp(2).data = data(:,segment_findassoc(RepEntry(SegIndex), 'EMGP2'));
    obj.disp(2).func = @plot;
    obj.disp(2).ylabel = {'EMG regio sterncleidomatoidea 2 [amp.]'};
    obj.splot2 = 2;
end;


obj.datainfo = Repository;
obj.index = SegIndex;
obj.viewer = @dataviewer;
% obj.viewermode = 'demand';
% obj.player = @wav_labelplayer;
% obj.printer = @dataprinter;
obj.datasize = partsize;
obj.printscaler = RepEntry(SegIndex).SFrq;

obj.sfreq = 256;
obj.xrange_vis = obj.sfreq*5;
obj.maxLabelNum = size(Repository.Classlist,2);
obj.labelstrings = Repository.Classlist;


obj.title = sprintf('Part: %3u, Subject: %s', SegIndex, 'XXX');
[fdir fname fext] = fileparts(dbfilename(RepEntry, SegIndex, 'LAB', 'cla', 'LABEL'));

sc = get(0,'screensize');
fh = figure( ...
    'Name',['EMG data ' ' - ' obj.title], ...
    'Position', [sc(1) sc(4)-sc(4)*.7 sc(3) sc(4)*.7], ... 
    'NumberTitle', 'off');

xrange = [0 obj.xrange_vis];
increment = 10;
while (1)

    if (xrange(2) > partsize)
        xrange = [0 obj.xrange_vis];
    else
        xrange = xrange + increment;
    end;
    obj.xrange = xrange;
   
    dataviewer(fh, obj);
    drawnow;
    

end;
