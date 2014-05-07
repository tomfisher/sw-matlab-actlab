function [data, dsize, sps, features] = bioexp_readfile(filename, operation, Range, verbose)
% function [data, dsize, sps, features] = bioexp_readfile(filename, operation, Range, verbose)
%
% read data from BioExplorer file
%
% filename      path and file name as string
% operation     valid is 'size' and 'data'
%               'size' returns dsize field but no data
% Range         read begin, end, default: [1 inf]
% verbose       not used
%
% return:
% data          matrix of feature data 
%               (as read from file, with highest sampling rate)
% dsize         data size
% sps           samples per second [Hz]
% features      cell string list of feature names as read from file
%
% WARNING: Due to a bug in BioExplorer as of version 0.99 the CSV output is
% not working. Only "TAB" output is implemented here.
%
% Event markers are returned as 0/1 feature, where 1 marks an event.
% Event markers are returned as constant value in the data. Value is set
% below.
%
% Copyright 2005 Oliver Amft


MarkerValue = 300;



if (exist('verbose')~=1) verbose = 0; end;
data = [];
dsize = 0;
sps = [];
features = {''};

if ~exist(filename)
    fprintf('\n%s: Filename %s does not exist.', mfilename, filename);
    %     error('File does not exist.');
    return;
end;
if (nargin<3)
    Range = [1 inf]
end;

if (Range(2) == inf) Range(2) = -1; end;

% if (Beg < 0)
%     Beg = 0; % Make sure that we read from beginning
% end;

ismarker = 0; filelanguage = 'EN'; 
            
% read in header information
% generate reading mask for textscan()
switch lower(operation)
    case 'size'
        % when called with datatype == 'size', return lines in file (instances)
        dsize = wcl(filename) - 11;  % remove header
        return;
        
        
    case 'data'
        fid = fopen(filename);
        fsep = textscan(fid, 'RAW Data export file (%s separated)',1); %delimiter type
        fsep = cell2mat(fsep{1}); % convert from cell to string array
        if isempty(fsep) 
            % fallback: german version
            fseek(fid, 0, 'bof');
            fsep = textscan(fid, 'Unbearbeiteter Daten-Export (%s separat)',1); %delimiter type
            fsep = cell2mat(fsep{1}); % convert from cell to string array
            if (~isempty(fsep)) filelanguage = 'DE'; end;
        end;

        if (~strcmp(lower(fsep), 'tab')) error('%s: File is not tab separated, read: "%s"', mfilename, fsep); end;

        % determine end of file to break loops
        fseek(fid, 0, 'eof'); eofpos = ftell(fid); fseek(fid, 0, 'bof'); % read again some chars doesnt matter
        
        if strcmp(filelanguage, 'EN') triggerword = 'Samples'; else triggerword = 'Beispiele'; end;
        
        while (ftell(fid)<eofpos) % find 'Samples'
            dummy = textscan(fid, '%s',1); %, 'delimiter', '\n'); % leap over
            if (strcmp(dummy{1}, triggerword)) break; end;
        end;

        if (~strcmp(dummy{1}, triggerword))  error('Read file error (pos: "Samples..."), value is %s', dummy{1}); end;
        while (ftell(fid)<eofpos)
            samples = textscan(fid, '%n SPS',1); 
            if (iscell(samples)) & (isempty(samples{1})) break; end;
            sps = [sps samples{1}]; 
        end;
        fcol = size(sps,2)+1;  % + TIME field (SampleNo)
        fstring = textscan(fid, '%s', fcol, 'delimiter', '\t');
        features = fstring{1}';
        valpos = ftell(fid);    % save data begin position
        
        if strcmp(filelanguage, 'EN') triggerword = 'Events'; else triggerword = 'Ereignisse'; end;
        dummy = textscan(fid, '%s', 1);
        if (strcmp(dummy{1}, triggerword))
            valpos = ftell(fid);    % save data begin position
            features{end+1} = dummy{1}{1};
            ismarker = 1;
        end;

        fclose(fid);
        readmask = '';
        for (element=1:fcol) readmask = [readmask ' %f']; end;
        readmask = readmask(2:end); % omit initial ' ' (space) char
        if (ismarker) readmask = [readmask ' %s']; end;
    otherwise
        fprintf('\n%s: Operation "%s" not understood, aborting.', mfilename, lower(operation));
end;


% process data file
fid = fopen(filename);
fseek(fid, valpos, 'bof');  % fseek(fid, 0, 'bof');

dummy = textscan(fid, readmask, Range(1)-1);
% dummy = textscan(fid, readmask, End-Beg+1);
dummy = textscan(fid, readmask, Range(2)- Range(1)+1);

fclose(fid);

dsize = size(dummy{1},1);

% markers must be de-bounced! (buggy Nexus device)
triggerlimit = 0.5; % bounce limit in seconds (min. seconds btw. consecutive markers)
markersections = [];
if (ismarker)
    markerlist = [ find(cellfun('size',dummy{fcol+1},1) > 0); ]; %dsize
    groupmarkers = find(diff(markerlist)/max(sps) <= triggerlimit);
    groupbounds = [0; find(diff(groupmarkers)>1); length(groupmarkers) ];

    for i = 2:length(groupbounds)
        markersections = [markersections; ...
            [groupmarkers(groupbounds(i-1)+1)  groupmarkers(groupbounds(i))+1] ];
    end;
    markersections = markerlist(markersections);
    dummy(fcol+1) = []; % delete marker column

%     % replace cell string list with simple 0/1 list, 1=valid marker
%     dummy{fcol+1} = repmat(0, dsize, 1);
%     dummy{fcol+1}(markerlist(validmarkers)) = 1;
end;

% % convert cell array to matrix
% data = [];
% for i = 1:max(size(dummy))
%     data(:,i) = col(dummy{i});
% end;
data = cell2mat(dummy);
for i = 1:size(markersections,1)
    data(markersections(i,1):markersections(i,2),:) = MarkerValue;
end;

% remove time field
if strcmp(filelanguage, 'EN') triggerword = 'TIME'; else triggerword = 'ZEIT'; end;
idx = strmatch(triggerword, features);
if (~isempty(idx)) data(:,idx) = []; end;

sps = sps(1);
