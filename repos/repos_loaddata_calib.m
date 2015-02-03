function [Data orgsps DTable] = repos_loaddata_calib(Repository, Partindex, DataType, varargin)
% function [Data orgsps] = repos_loaddata(Repository, Partindex, DataType, varargin)
%
% Load data as directed by arguments and options.
% 
% Function provides a wrapper for actual data storage formats used. Return value for DTable is based 
% on Repository.RepEntries().Assoc.(DataType), the list is adapted according to specified channels in 
% optional parameter list. This could be used to generate dummy data for non-existent channels as well.
% 
% Return values
%       Data                Loaded data
%       orgsps           Sample rate of loaded data
%       DTable           Channel specification describing each loaded channel
% 
% Optional parameters:
%       Range           Data chunk to load (must be implemented for loading routine)
%       Channels     List (cell array) of strings specifying channels (feature columns) to load.
%
% See also:  repos_prepdata
%
% Example:
%    [Data orgsps DTable] = repos_loaddata(Repository,11,'CRNT_CAP', 'verbose', 1)
% 
% 
% Copyright 2005-2012 Oliver Amft
%
% Bugfix for changed behaviour of cellstrmatch, Gabriele, 07-11-2012


[ApplyFilter Range Channels ErrorOnNoData ErrorOnNoFile orgsps verbose] = process_options(varargin, ...
    'ApplyFilter', false, 'Range', [1 inf], 'Channels', {}, 'ErrorOnNoData', true, 'ErrorOnNoFile', true, 'orgsps', nan, 'verbose', 0);

% DataType = upper(DataType);
DataFile = repos_getfilename(Repository, Partindex, DataType);
if isempty(DataFile) && ErrorOnNoFile
    fprintf('\n%s: ERROR: DataType %s for part %u not available.', mfilename, DataType, Partindex);
    return;
end;

% convert DTable entries
[DTable DTableActual] = repos_getdtable(Repository, Partindex, DataType); %repos_getfield(Repository, Partindex, 'Assoc', DataType);
vchannels = ~cellstrmatch(DTable, DTableActual);

source = repos_getfield(Repository, Partindex, 'Source', DataType);

% determine channels (rows) to read
if ~iscell(Channels), Channels = {Channels}; end;
if isempty(Channels), Channels = DTable; end;
channelnrs = repos_findassoc(Repository, Partindex, Channels, DataType);
if any(channelnrs==0)
    fprintf('\n%s: ERROR: Channels %s not found for PI %u. Stop.', mfilename, cell2str(Channels(channelnrs==0), ', '), Partindex);
    fprintf('\n%s: All requestable channels must be available in Repository.RepEntries(%u).Assoc.%s.',  mfilename, Partindex, DataType);
    return;
end;

if (verbose>1)
    fprintf('\n%s: Load segment %s from PI %u.', mfilename, mat2str(Range), Partindex, DataFile);
    fprintf('\n%s: File: %s', mfilename, DataFile);
    fprintf('\n%s: Channels: %s (%s)', mfilename, cell2str(Channels, ', '), mat2str(channelnrs));
end;

% if isnan(orgsps), orgsps = 0; end;      % if set from caller, use it (if the loader stub supports it)


% loader plugin output: Data, orgsps, DTable (may be adapted to specific needs)
% loader plugin input: Repository, Partindex, DataType_tokens, DataFile, DTable, varargin
Data = []; 
DataType_tokens = str2cellf(DataType, '_');
switch DataType_tokens{1}

    case 'Shimmer'   % supertype
        fid = fopen(DataFile);
        if fid < 0
            Data = [];  orgsps = [];
            fprintf('\n%s: File %s not found.', mfilename, DataFile);
        else
            frewind(fid);
            switch DataType_tokens{2}
                case {'ECG1', 'Sync'} 
                    Data_uncalibrated = fread(fid, [5, Inf], 'uint16')';     % [M,N]  read elements to fill an M-by-N matrix, in column order.
                    
                case {'WristL', 'WristR', 'AnkleR'}
                    Data_uncalibrated = fread(fid, [6, Inf], 'uint16')';     % [M,N]  read elements to fill an M-by-N matrix, in column order.
            end
            Data = calibrate_shimmer_acc(DataType_tokens{2},Data_uncalibrated);
            orgsps = 170.67;
        end;
        if ~isempty(Data)
            Data = Data(:,channelnrs);  DTable = DTable(channelnrs);
        else
            if ErrorOnNoData, error('Data not found.'); end;
        end;  
        
        
        
    case 'Sensatron'   % supertype
        Data = load(DataFile);
        
        switch DataType_tokens{2}
            case {'Acc0', 'Acc1', 'Acc2'},  orgsps = 1/(8000 / 1e6); % 125Hz
            case {'ECG'},  orgsps = 1/(4000 / 1e6); % 250Hz
            case {'Respi'},  orgsps = 1/(16000 / 1e6); % 62.5Hz
            otherwise
                fprintf('\n%s: Source %s not supported for DataType %s.', mfilename, DataType_tokens{2}, DataType_tokens{1});
        end;
        Data = Data(:,channelnrs);  DTable = DTable(channelnrs);
        
    
    case 'UART'    % supertype
        switch lower(source)
            case 'uart_v1'
                if ~exist(DataFile, 'file')
                    % need to do resampling
                    [p,f,e] = fileparts(DataFile);
                    path = [ fileparts(p) filesep ];  % root dir of recordings + slash (expected by importresample code);
                    index = str2double(f(length('ResampledData')+1:end)) + 1;  % apparently index in [1:end+1] considered
                    Data = importresample(path, index);  % file name is following this pattern: ResampledDataXX.mat
                    
                    % store resampled data as a cache file
                    if ~exist(fileparts(DataFile), 'dir'), mkdir(fileparts(DataFile)); end;
                    SaveTime = clock;
                    save(DataFile, 'Data', 'SaveTime');
                else
                    Data = loadin(DataFile, 'Data');
                end;
            otherwise
                fprintf('\n%s: Source not supported for DataType %s.', mfilename, DataType_tokens{1});
        end;
        orgsps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);
        
        Data = Data(:,channelnrs);  DTable = DTable(channelnrs); 
        
    
    case 'CRNT'    % supertype
        switch lower(source)
            case {'toolbox', 'textfile'} % loading without timestamp, depricated
                Data = readtextfilecols(DataFile, [1+2 length(DTable)+2], Range);
                orgsps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);
            
            case { 'timestamped_noeqdist', 'timestampednoeqdist' }  % loading timestamped lines, ignore timestamp
                Data = readtextfilecols(DataFile, [1 inf], Range);                
                Data = crnt_maketimestamp(Data);
                orgsps = roundf( 1e6/mean(diff(Data(:,1))), 1);

            case { 'timestamped_noeqdist_abstime', 'timestampednoeqdistabstime' }  % loading timestamped lines, retain absolute (wall-clock) time
                Data = readtextfilecols(DataFile, [1 inf], Range);
                Data = crnt_maketimestamp(Data, 'RelativeTime', false, 'ErrorOnNoData', false);
                try orgsps = roundf( 1e6/mean(diff(Data(:,1))), 1); 
                catch
                    if ErrorOnNoData, rethrow(lasterror); end; 
                end;
               
            case 'timestamped'  % loading timestamped lines encoded, convert to equidistant samples
                %Data = readtextfilecols(DataFile, [1 length(DTable)], Range);
                Data = readtextfilecols(DataFile, [1 inf], Range);
                Data = crnt_maketimestamp(Data);
                orgsps = roundf( 1e6/mean(diff(Data(:,1))), 1);
                [Data tmp] = equidistdata(Data(:,1)/1e6, Data(:,2:end), 1/orgsps);
                Data = [col(tmp) Data];
                
            case 'timestamped_abstime'  % loading timestamped lines encoded, convert to equidistant samples, retain absolute (wall-clock) time
                % this stub is intended for event-like data
                Data = readtextfilecols(DataFile, [1 inf], Range);
                Data = crnt_maketimestamp(Data, 'RelativeTime', false);
                if isnan(orgsps), orgsps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);  end;      % if set from caller, use it (if the loader stub supports it)
                [Data tmp] = equiresample( Data(:,1)/1e6, Data(:,2:end), 1/orgsps);
                Data = [col(tmp) Data];

                
            case { 'binaryenc', 'binaryenchead8kuint32' }       % binary data, with header, 8kHz, uint32 encoded
                [Data orgsps] = binary_reader(DataFile, 'Range', Range);
                if isempty(orgsps)
                    % OAM REVISIT: this is a hack for the DAW project
                    orgsps = 8000; % 8kHz
                    fprintf('%s: WARNING: No sampling rate information for PI %u %s, assuming %.1fkHz', ...
                        mfilename, Partindex, lower(source), orgsps/1e3);
                end;
            case 'binaryenc16kint16norm'       % binary data, 16kHz, int16 encoded, normalised
                [Data orgsps] = binary_reader(DataFile, 'Range', Range, 'HasHeader', false, 'NumFormat', 'int16', 'DoNormalise', true);
                % binary files do not contain sampling rate information
                if isempty(orgsps), orgsps = 16000; end;
			case 'binaryenc14k2int16norm'       % binary data, 16kHz, int16 encoded, normalised
                [Data orgsps] = binary_reader(DataFile, 'Range', Range, 'HasHeader', false, 'NumFormat', 'int16', 'DoNormalise', true);
                % binary files do not contain sampling rate information
                if isempty(orgsps), orgsps = 14200; end;
            case 'binaryenc44.1k'       % binary data, 44.1kHz, float encoded
                [Data orgsps] = binary_reader(DataFile, 'Range', Range, 'HasHeader', false, 'NumFormat', 'float');
                % binary files do not contain sampling rate information
                if isempty(orgsps), orgsps = 44100; end;
            
           case 'binaryfloatenc44.1k'
                [Data orgsps] = binary_floatreader(DataFile, 'Range', Range);
                % binary files do not contain sampling rate information
                if isempty(orgsps), orgsps = 44100; end;
                
            case 'matlab'
                Data = loadin(DataFile,  'DataSet'); tmp_DTable = loadin(DataFile,  'DTable'); 
                orgsps = loadin(DataFile,  'markersps');
                if Range(2) >= inf, Range(2) = size(Data,1); end;
                Data = Data(Range(1):Range(2),:);

                % compare features that are expected and actually found
                matches = cellstrmatch(tmp_DTable, DTable, 'exact');
                if any(row(matches) ~= 1:length(DTable)), error('Feature lists do not coincide.'); end;
                
            otherwise
                fprintf('\n%s: Source not supported for DataType %s.', mfilename, DataType_tokens{1});
        end;
        
        % add virtual channels of needed
        if any(vchannels) && ~all(cellstrmatch(Channels, DTable(~vchannels)))
            if (verbose), fprintf('\n%s: Source %s has %u virtual channels, patching...', mfilename, DataType, sum(vchannels)); end;
            [VData VDTable] = repos_loaddata_patch(Repository, Partindex, Range, Data, DTableActual, DTable);
            if ~all(cellstrmatch(DTable(vchannels), VDTable)), error('Could not patch all channels.'); end;
            Data = VData; DTable = VDTable;
        end;
        
        if ~isempty(Data)
            Data = Data(:,channelnrs);  DTable = DTable(channelnrs);
        else
            if ErrorOnNoData, error('Data field is empty'); end;
%             DTable = [];
        end;

%         if size(Data,2) ~= max(channelnrs), error('Channel mismatch detected.'); end;
        
        

        
    case 'OPPORTUNITY'
        switch lower(source)
            case 'timestamped'  % loading timestamped lines encoded
                Data = readtextfilecols(DataFile, [1 inf], Range);
                orgsps = roundf( 1e3/mean(diff(Data(:,1))), 1); % timestamp is in milliseconds
                %Data(:,1) = [];  % first channel is timestamp, needed for label conversion
                
                %[Data tmp] = equidistdata(Data(:,1)/1e6, Data(:,2:end), 1/orgsps);
                %Data = [col(tmp) Data];
            otherwise
                fprintf('\n%s: Source not supported for DataType %s.', mfilename, DataType_tokens{1});
        end;
        
        Data = Data(:,channelnrs);  DTable = DTable(channelnrs);
        
    case 'ETHOS'   
        
        switch lower(source)
            case 'timestamped'  % loading timestamped lines encoded
                Data = readtextfilecols(DataFile, [1 inf], Range);
                if isnan(orgsps), orgsps =128; end; % timestamp is in milliseconds       
                %Data(:,1) = [];  % first channel is timestamp, needed for label conversion
                
                %[Data tmp] = equidistdata(Data(:,1)/1e6, Data(:,2:end), 1/orgsps);
                %Data = [col(tmp) Data];
            otherwise
                fprintf('\n%s: Source not supported for DataType %s.', mfilename, DataType_tokens{1});
        end;
        
        Data = Data(:,channelnrs);  DTable = DTable(channelnrs);
        
        
    case {'CRNTMERGED', 'MATLABMERGED'}  % supertype
        % DO NOT USE FOR MERGED CRNT DATA, USE 'CRNT_MERGED' WITH SOURCE 'matlab' INSTEAD.
       
        % used for timestamp-based merged data that contains multiple streams of differing alignment
        % see also: main_crnt_mergestreams.m

        orgsps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);
        switch lower(source)
            case 'CRNT_timestamped'
                Data = readtextfilecols(DataFile, [1 length(DTable)+2], Range);
                %Data = load(DataFile);
                Data(:,1) = Data(:,1) .* 1e6 + Data(:,2);  Data(:,2) = [];
                orgsps = [];

            case 'matlab'
                % according to main_crnt_mergestreams
                Data = loadin(DataFile, 'MergedData');
                orgsps = loadin(DataFile, 'markersps');
                FileDTable = loadin(DataFile, 'newDTable');

                % compare features that are expected and actually found
                %DTable_merged = repos_getdtable(Repository, Partindex, DataType_tokens{1});
                %DTable_merged = repos_getdtable(Repository, Partindex, DataType);
                %if isemptycell(DTable_merged), error('BUG: DTable_merged is empty.'); end;

                % OAM REVISIT: This line is not so useful: cellstrmatch returns complete vector always
                if length(cellstrmatch(Channels, FileDTable)) ~= length(Channels)
                    error('ERROR: Feature lists do not coincide with merged file.');
                end;

                
            case 'matlab_onevar'    % any Matlab file, just providing data in one variable
                % assumes that there is ONE variable of arbitrary name in the mat file
                tmp = load(DataFile);  
                FileDTable = fieldnames(tmp);
                Data = tmp.(FileDTable{1});
                clear('tmp');
                
                FileDTable = DTable; % variable name from mat is assumed to be arbitrary thus override!
                
                % OAM REVISIT: this is a hack to work with officeaudio study files, should be removed.
                Data = double(Data);
                
            otherwise
                fprintf('\n%s: CRNT source not supported!', mfilename);
        end;
        
        % return data for particular subtype only
        % AND adapt feature matrix to DTable (requested features)
        %Data = Data(:, vec2onehot(cellstrmatch(FileDTable, Channels, 'exact')));
%         if(strcmp(FileDTable{1,2},'Speaking_inside') || strcmp(FileDTable{1,2},'Speaking_outside'))
%             Data = Data(:,1);
%              DTable = DTable(channelnrs);
%         else
            Data = Data(:, cellstrmatch(FileDTable, Channels, 'exact')>0);
            DTable = DTable(channelnrs);
%         end
        
        

    case 'ARFF'  % ARFF file format
        [Data dummy SPS] = arff_reader(DataFile);
        orgsps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);


    case {'XSENS', 'MTS'}
        switch lower(source)
            case 'xsens'
                [Data orgsps] = xsens_getdata(Repository, Partindex, 'Range', Range);
            case {'toolbox', 'textfile'}
                Data = readtextfilecols(DataFile, [1+2 length(DTable)+2], Range);
                orgsps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);
            case 'crnt_timestamped'
                Data = readtextfilecols(DataFile, [], Range);Subject 
                Data = crnt_maketimestamp(Data);
                orgsps = 1e6/mean(diff(Data(:,1)));
            case 'matlab'
                Data = loadin(DataFile,  'thisData');
                orgsps = loadin(DataFile,  'markersps');
            otherwise
                fprintf('\n%s: XSENS source not supported!', mfilename);
                error('Stop.');
        end;

        % --- add any processed columns ---
        warning('repos:Channels', 'change this code to use parameter Channels');

        % Euler angles: roll, pitch, yaw
        % (As opposed to phi, theta, psi that are provided from the reading routines directly.)
        % OAM REVISIT: strmatch_substr is part of BNT/KPMtools!
        if ~isempty(strmatch_substr('roll', DTable))
            DTable_raw = DTable;
            %             DTable_raw(strmatch_substr('roll', DTable)) = [];   DTable_raw(strmatch_substr('pitch', DTable)) = [];    DTable_raw(strmatch_substr('yaw', DTable)) = [];

            normsensors = DTable(strmatch_substr('roll', DTable));
            for s = 1:length(normsensors)
                sensorid = normsensors{s}(1:strfind(normsensors{s}, 'roll')-1);
                relsensors = [ ...
                    strmatch([sensorid 'r11'], DTable_raw), strmatch([sensorid 'r12'], DTable_raw), strmatch([sensorid 'r13'], DTable_raw), ...
                    strmatch([sensorid 'r21'], DTable_raw), strmatch([sensorid 'r22'], DTable_raw), strmatch([sensorid 'r23'], DTable_raw), ...
                    strmatch([sensorid 'r31'], DTable_raw), strmatch([sensorid 'r32'], DTable_raw), strmatch([sensorid 'r33'], DTable_raw), ...
                    ];
                eulerdata = rot2eul(Data(:,relsensors));
                Data = [Data, eulerdata];
            end;
        end;

        % distance to head
        if ~isempty(strmatch_substr('head', DTable))  % check if distances required
            headdata = xsens_getdist(Repository, Partindex, 'Range', Range);  % col1: left, col2: right
            if isempty(headdata), headdata = nan(size(Data,1), length(strmatch_substr('head', DTable))); end;
            Data = [Data, headdata];
        end;

        % acc normalisation
        if ~isempty(strmatch_substr('accn', DTable))  % check if acc norm required
            DTable_raw = DTable;
            %             DTable_raw(strmatch_substr('accn', DTable)) = [];

            normsensors = DTable(strmatch_substr('accn', DTable));
            for s = 1:length(normsensors)
                sensorid = normsensors{s}(1:strfind(normsensors{s}, 'accn')-1);
                relsensors = [ strmatch([sensorid 'accx'], DTable_raw), strmatch([sensorid 'accy'], DTable_raw), strmatch([sensorid 'accz'], DTable_raw) ];
                accndata = normv(Data(:,relsensors));
                %Data(:, strmatch([sensorid 'accn'], DTable)) = accndata;
                Data = [Data, accndata];
            end;
            %Data = [Data xsens_getaccn(Repository, Partindex, 'Range', Range)];
        else
            accndata = [];
        end;

        % finally, add processed columns


    case 'EMG'
        switch lower(source)
            case 'bioexp'
                [Data dummy orgsps features] = bioexp_readfile(DataFile, 'data', Range);
                % remove TIME field
                %idx = strmatch('TIME', features);
                %if (~isempty(idx)) Data(:,idx) = []; end;
                clear idx features dummy;
            case 'toolbox'
                SMARKER_PUSHUP = 5000;
                [Data orgsps] = toolbox_readfile(DataFile, 'range', Range, 'columns', [1 length(DTable)]);
                %Data = readtextfilecols(DataFile, [1+2 length(DTable)+2], Range);
                [Data tmp] = tsinterpolate(Data, 'LostsamplesCounter', Data(:,strmatch('LOSSCNT', DTable)) );
                Data(:,strmatch('LOSSCNT', DTable)) = tmp*SMARKER_PUSHUP; % mark inserted samples

                % limit marker channel (strange crosstalk) and pushup marks
                tmp = strmatch('SMARKER', DTable);
                Data(Data(:,tmp) > SMARKER_PUSHUP, tmp) = SMARKER_PUSHUP;
                Data(Data(:,tmp) == 1, tmp) = SMARKER_PUSHUP;

                if (ApplyFilter)
                    % apply bandpass filter
                    pos = 1:length(DTable); pos(strmatch('SMARKER', DTable)) = []; pos(strmatch('LOSSCNT', DTable)) = [];
                    Data(:,pos) = feature_emgfilter(Data(:,pos), 'sps', orgsps, 'mode', 'bandpass');
                    % OAM REVISIT: what about notch filtering?
                end;
        end;
        Data = Data(:,channelnrs);  DTable = DTable(channelnrs); 

        
    case 'WAV'
        % read single WAV file or track set (*-[1-inf].wav)
        %[Data dummy orgsps] = WAVReader(DataFile, Range);
        if isempty(source), source = 'unknown'; end;
        switch lower(source)
            case 'crnt_binaryencoder'
                [Data orgsps] = binary_reader(DataFile, 'Range', Range, 'channels', channelnrs, 'verbose', 0);
                Data = Data / double(intmax+1);
                
            case 'stringenc'
                int16size = 2;  % bytes
                fid = fopen(DataFile, 'r');
                if fid < 0, fprintf('\n%s: Could not open file: %s', mfilename, DataFile); error('File %s not found.', DataFile);  end;
                datapos = ftell(fid); fseek(fid, 0, 'eof'); filesize = ftell(fid); fseek(fid, datapos, 'bof');
                if Range(2) >= inf, Range(2) = filesize/int16size; end;
                Data = double(fread(fid, Range(2)-Range(1)+1, 'int16'));
                Data = Data / double(intmax('int16')+1);
                orgsps = 44100;
                
            otherwise
                [Data, dummy, orgsps] = wav_getdata(Repository, Partindex, ...
                    'Range', Range, 'channels', channelnrs, 'verbose', 0);
        end;
        DTable = DTable(channelnrs);


        % OAM REVISIT: This is a temporary hack and should be removed!
        if (ApplyFilter)
            % apply bandpass filter
            for ch = 1:length(DTable)
                switch DTable{ch}
                    case 'ACC'
                        hf = 12e3;
                        if ((orgsps/2) < hf), hf = orgsps/2; end;
                        Data(:,ch) = feature_filter(Data(:,ch), 'type', 'butter', 'order', 4, 'mode', 'bp', 'sps', orgsps, 'lowfrq', 10, 'highfrq', hf);
                    otherwise
                        % any other sound channel
                        Data(:,ch) = feature_filter(Data(:,ch), 'type', 'butter', 'order', 4, 'mode', 'bp', 'sps', orgsps, 'lowfrq', 50, 'highfrq', orgsps/2);
                end;
            end; % for i
        end;

        % check whether samples are zero (generates NaNs/Div by zero) in feature computation
        zeropos = (abs(Data)<eps); %(Data==0);
        Data(zeropos) = eps;
        if sum(sum(zeropos)),
            fprintf('\n%s: WARNING: WAV file had zeros, corrected %u samples (%.1f%% of data).', mfilename, ...
                sum(sum(zeropos)), sum(sum(zeropos))/sum(size(Data))*100);
        end;

    case 'STR'
        % SA Swallowing (Marcel Scheuerer) elongation sensors
        switch lower(source)
            case {'excel', 'xls'}
                [channel1,channel2,channel3,time,frequency] = xlsconverterplus(DataFile);
                if isempty(channel1), error('File not found'); end;
            case 'mat'
                [pathstr,name,ext] = fileparts(DataFile);
                DataFile = [pathstr filesep name '.mat'];
                load(DataFile, 'channel1', 'channel2', 'channel3', 'frequency');
            otherwise
                fprintf('\n%s: STR source not supported!', mfilename);
        end;
        datatmp = [channel1' channel2' channel3'];
        if (Range(2)<inf), datatmp = datatmp(Range(1):Range(2),:); else datatmp = datatmp(Range(1):end,:); end;

        Data = datatmp;
        orgsps = round(frequency*10)/10;

    case 'SCALES'
        % Matlab scales toolbox
        switch lower(source)
            case 'csv'
                % OAM REVISIT: forgot purpose of this format
                datatmp = dlmread(DataFile, ';', 3,0);
                orgsps = min(diff(datatmp(:,1)));
                Data = equidistdata(datatmp(:,1), datatmp(:,2), 1/orgsps);
            case 'space'
                datatmp = dlmread(DataFile, '', 10,0); % skip header
                %orgsps = 1; % normalise to 1 Hz
                orgsps = 8; % more precise result than 1Hz, will be changed to 128Hz further down
                SMARKER_PUSHUP = 250;

                maxtime = ceil(max(datatmp(end, 3:2:size(datatmp,2))));

                % scales marker (column 2): use last scale to make equidist vector
                Data = [Data ...
                    equidistdata(round(datatmp(:,end-1)), datatmp(:,2), 1/orgsps, maxtime) * SMARKER_PUSHUP];

                % scales values
                for i = 3:2:size(datatmp,2)
                    Data = [Data  equidistdata(round(datatmp(:,i)), datatmp(:,i+1), 1/orgsps, maxtime)];
                end;

                % match Marker label rate  ==>  128 Hz <==
                Data = feature_simpleupsample(Data, orgsps, 128); orgsps = 128;

                clear datatmp i maxtime;
            otherwise
                fprintf('\n%s: SCALES source not supported!', mfilename);
        end;
        if (Range(2)<inf), Data = Data(Range(1):Range(2),:); else Data = Data(Range(1):end,:); end;
        Data = Data(:,channelnrs);  DTable = DTable(channelnrs); 
        
        
    case 'TBRET'
        % Retreat (toolbox output)
        %         if (~isempty(Range)), error('Range parameter not supported for this DataType.'); end;
        orgsps = 128;
        %[dummy DataFile] = fileparts(DataFile); DataFile = [DataFile '.mat'];
        datatmp = [];
        datatmp = [ datatmp loadin(DataFile, 'ECG') ];
        datatmp = [ datatmp loadin(DataFile, 'EOG') ];
        datatmp = [ datatmp loadin(DataFile, 'GSR') ];
        datatmp = [ datatmp loadin(DataFile, 'RESP') ];
        datatmp = [ datatmp loadin(DataFile, 'STRAIN') ];
        datatmp = [ datatmp loadin(DataFile, 'XSENSHEAD') ];
        datatmp = [ datatmp loadin(DataFile, 'XSENSRIGHT') ];
        datatmp = [ datatmp loadin(DataFile, 'XSENSLEFT') ];
        datatmp = [ datatmp loadin(DataFile, 'XSENSTORSO') ];
        datatmp = [ datatmp loadin(DataFile, 'VALID') ];
        datatmp = [ datatmp loadin(DataFile, 'GAME') ];
        if (Range(2)<inf), datatmp = datatmp(Range(1):Range(2), 3:end); else datatmp = datatmp(Range(1):end, 3:end); end;
        Data = datatmp;

    case 'DART'
        % car manufacturing experiment with Clemens, Thomas
        switch lower(source)
            case 'toolbox_hood'
                DTable = Repository.Template_AssocHoodParts;
            case 'toolbox_side'
                DTable = Repository.Template_AssocSideParts;
            case 'toolbox_trunk'
                DTable = Repository.Template_AssocTrunkParts;
            otherwise
                error('Unknown source type');
        end;

        orgsps = 50;
        datatmp = load(DataFile);
        if (Range(2)<inf), datatmp = datatmp(Range(1):Range(2), 3:end); else datatmp = datatmp(Range(1):end, 3:end); end;

        % rearrange sensor columns based on DTable
        % this is a legacy code, will work still
        basepos = strmatch('KEY', DTable) + 1;  % last entry in DTable before tmote sensors
        sensorsToProcess = { ... %{ 'FLIGHT', 'HOOD', 'DRIVER1', 'DRIVER2', 'FDOOR', 'RDOOR', 'RATTLE', 'BLIGHT', 'TRUNK' };
            'FLIGHTaccx', 'FLIGHTaccy', 'FLIGHTaccz', 'FLIGHTseqn', ...
            'HOODaccx', 'HOODaccy', 'HOODaccz', 'HOODseqn', ...
            'DRIVER2accx', 'DRIVER2accy', 'DRIVER2accz', 'DRIVER2seqn', ...
            'DRIVER1accx', 'DRIVER1accy', 'DRIVER1accz', 'DRIVER1seqn', ...
            'FDOORaccx', 'FDOORaccy', 'FDOORaccz', 'FDOORseqn', ...
            'BDOORaccx', 'BDOORaccy', 'BDOORaccz', 'BDOORseqn', ...
            'RATTLEaccx', 'RATTLEaccy', 'RATTLEaccz', 'RATTLEseqn', ...
            'TRUNKaccx', 'TRUNKaccy', 'TRUNKaccz', 'TRUNKseqn', ...
            'BLIGHTaccx', 'BLIGHTaccy', 'BLIGHTaccz', 'BLIGHTseqn', ...
            };
        sensordata = zeros(size(datatmp,1), length(sensorsToProcess));
        for i = 1:length(sensorsToProcess)
            qidx = strmatch(sensorsToProcess{i}, DTable);

            if ~isempty(qidx),
                sensordata(:, i) = datatmp(:, qidx);
            end;
        end;
        datatmp(:, basepos:end) = [];
        datatmp = [ datatmp sensordata ];
        DTable(basepos:end) = [];
        DTable = [ DTable sensorsToProcess ];

        
        % compute euler angles from quarternion and store to structure
        sensorsToProcess = {'CUB', 'RUA', 'RLA', 'RHA', 'LUA', 'LLA', 'LHA'};  % this list must follow the order in DTable
        dtablenames = { 'CUBphi', 'CUBtheta', 'CUBpsi', ...
            'RUAphi', 'RUAtheta', 'RUApsi', 'RLAphi', 'RLAtheta', 'RLApsi', 'RHAphi', 'RHAtheta', 'RHApsi', ...
            'LUAphi', 'LUAtheta', 'LUApsi', 'LLAphi', 'LLAtheta', 'LLApsi', 'LHAphi', 'LHAtheta', 'LHApsi' };
        DTable = [ DTable dtablenames ];
        for i = 1:length(sensorsToProcess)
            qidx = row(strmatch([sensorsToProcess{i} 'qu'], DTable));
            eidx = [ ...
                strmatch([sensorsToProcess{i} 'phi'], DTable) ...
                strmatch([sensorsToProcess{i} 'theta'], DTable) ...
                strmatch([sensorsToProcess{i} 'psi'], DTable) ];
            if (length(eidx) < 3), continue; end;
            datatmp(:, eidx) = quat2euler(datatmp(:, qidx));
        end;
        Data = datatmp;

        % norm acc
        %normsensors = DTable(strmatch_substr('accn', DTable));
        normsensors = { 'CUBaccn', 'RUAaccn', 'RLAaccn', 'RHAaccn', 'LUAaccn', 'LLAaccn', 'LHAaccn', ...
            'FLIGHTaccn', 'HOODaccn', 'DRIVER2accn', 'DRIVER1accn', 'FDOORaccn', 'BDOORaccn', 'RATTLEaccn', 'TRUNKaccn', 'BLIGHTaccn' };
        DTable = [ DTable, normsensors ];
        for s = 1:length(normsensors)
            sensorid = normsensors{s}(1:strfind(normsensors{s}, 'accn')-1);
            relsensors = [ strmatch([sensorid 'accx'], DTable), strmatch([sensorid 'accy'], DTable), strmatch([sensorid 'accz'], DTable) ];
            if length(relsensors) ~= 3, error('Did not match three acc axes!'); end;
            accndata = normv(Data(:,relsensors));
            Data(:, strmatch([sensorid 'accn'], DTable)) = accndata;
            %Data = [Data, accndata];
        end;

        
        
        
    case 'BMAN'
        % backmanager project with Corinne, Holger
        strain = loadin(DataFile, 'strain');

        % sampling rate of 50Hz is assumed
        time_1 = strain.hh(1)*3600 + strain.mm(1)*60 + strain.ss(1) + strain.zzz(1)/1000;
        time_101 = strain.hh(101)*3600 + strain.mm(101)*60 + strain.ss(101) + strain.zzz(101)/1000;
        frequency = roundf(100 / (time_101 - time_1), 1);

        %orgsps = frequency;
        orgsps = 40;

        datatmp = strain.Sensor_Data;
        if (Range(2)<inf), datatmp = datatmp(Range(1):Range(2), 1:end); else datatmp = datatmp(Range(1):end, 1:end); end;
        Data = datatmp;
        clear time_1 time_101 frequency;

    case 'BIBTEX'
        % used for Corina Literature Tools
        % bibtex_load does currently not supprt range
        %if isempty(Channels), Channels = {'author', 'title', 'year'}; end;
        Data = bibtex_load(DataFile, 'readfields', Channels);   % , 'verbose', verbose
        orgsps = 1;
        DTable = DTable(channelnrs);

    case 'REFER'
        % used for Corina Literature Tools
        % bibtex_load does currently not supprt range
        %if isempty(Channels), Channels = {'author', 'title', 'year'}; end;
        Data = bibtex_load(DataFile, 'readfields', Channels, 'readfun', 'refer_readentry', 'verbose', verbose);
        if ~isempty(Data), DTable = row(fieldnames(Data)); else DTable = Channels; end;
        orgsps = 1;
        
        % OAM REVISIT: is bibtex_load performing channel selection correctly?        
        %DTable = DTable(cellstrmatch(Channels, DTable, 'exact'));


    case 'SYM'
        % symbol data (string struct)

        Data = loadin(DataFile, 'strdata_test');
        orgsps = 1;
        Data = Data(:,channelnrs);  DTable = DTable(channelnrs);

    case 'SMASH'
        % smart shirt loader for Holger's shirt data
        orgsps = 15.5; % hack
        if (orgsps ~= Repository.RepEntries(Partindex).SFrq), error('SPS should be 15.5Hz (hack!)'); end;
        %Data = rand(1, orgsps*60*12);  % hack
        %[dummy Data thisDTable] = smash_load(DataFile);
        [dummy Data thisDTable] = smash_load( Repository, Partindex );
        if ~all(cell2str(thisDTable)==cell2str(DTable)), error('DTable does not match (hack!)'); end;
        Data = Data(:,channelnrs);  DTable = DTable(channelnrs); 
        

    case { 'SUUNTOGPS' }
        switch lower(source)

            case { 'toolbox' }
                % Get sample rate from Marker
                orgsps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);
                
                % Load entire data file
                Data = load(DataFile);
                
                % Delete dummy channels to assert SUUNTOGPS assoc structure
                if size(Data,2) > 9,
                    useOldProtocol = false;
                    Data(:,8:9) = [];
                else
                    useOldProtocol = true;
                end;

                % Estimate missing messages
                chSeqNo = repos_findassoc(Repository, Partindex, 'SUUNTOGPSseqno', DataType);
                
                % Non-redundant information, we only consider single errors as
                % GPS switch off periods are hard to detect (maybe 255 flag?)
                nSeqNo = 256;
                dSeqNo = mod(diff(Data(:,chSeqNo)), nSeqNo);
                missing = sum(dSeqNo(dSeqNo > 1) - 1);
                debit = size(Data,1) + missing;
                actual = size(Data,1);

                if (verbose>1)
                    fprintf('\n%s:\n\tMessage stats (data) :\tDebit: %10d (100.00%%),\tActual: %10d (%6.2f%%),\tMissing: %10d (%6.2f%%)', ...
                        DataType, uint32(round(debit)), uint32(round(actual)), double(actual/debit)*100, uint32(round(missing)), missing/debit*100);
                end;

                % Retain first time stamp
                T0s = Data(1,1);
                T0us = Data(1,2);

                % Retain only valid data (mode 120)
                chMode = repos_findassoc(Repository, Partindex, 'SUUNTOGPSmode', DataType);
                Data = Data(Data(:,chMode) == 120, :);

                % Recompute dSeqNo after mode correction (as we needed all samples to determine data loss rates before)
                dSeqNo = mod(diff(Data(:,chSeqNo)), nSeqNo);

                % Replace first valid time stamp with first time stamp ever
                Data(1,1) = T0s;
                Data(1,2) = T0us;

                % Calculate data time vector on host [s]
                T = (Data(:,1) - Data(1,1)) + (Data(:,2) / 10^6);

                % Compute cumulative distance
                chDist = repos_findassoc(Repository, Partindex, 'SUUNTOGPSdist', DataType);

                % Locate discontinuities by first distance derivative
                dDists = diff(Data(:,chDist));
                disconts = dDists < 0;
                % Determine device turn off periods
                offtimes = diff(T) > 600;% 10min
                % Determine data type rollovers
                rollovers = 4096 * and(disconts, ~offtimes);
                % Separate turn off periods from rollovers
                turnoffs = abs(dDists .* and(disconts, ~rollovers));
                % Compute correction signal
                cumDist = cumsum([0; turnoffs(:) + rollovers(:)]);
                % Compute corrected distance signal
                Data(:,chDist) = Data(:,chDist) + cumDist;

                
                % For data recorded prior 31-10-2008
                if useOldProtocol;
                    % Fix Speed error (fix for later!!!)
                    chStatus = repos_findassoc(Repository, Partindex, 'SUUNTOGPSstatus', DataType);
                    chSpeed = repos_findassoc(Repository, Partindex, 'SUUNTOGPSspeed', DataType);
                    Data(:,chSpeed) = Data(:,chSpeed) + (mod(Data(:,chStatus),15) * 4096);
                end;

                % Boost GPS signal status
                gain = 1000;
                chStatus = repos_findassoc(Repository, Partindex, 'SUUNTOGPSstatus', DataType);
                Data(:, chStatus) = gain * (Data(:, chStatus) == 255);

                % Fix time series
                Ts = (Data(:,1) - Data(1,1)) + (Data(:,2) / 10^6);
                % Time vector of interpolation data
                Tinterp = (0:1/orgsps:Ts(end))';
                % Data interpolation
                Data = interp1q(Ts, Data(:,3:end), Tinterp(:));
                Tus = rem(Tinterp, 1) * 10^6;
                Ts = floor(Tinterp);
                Data = [Ts Tus Data];

                % Abuse seqNo for data loss count of activities
                % Find nearest integer of T (approximation!)
                selector = dSeqNo > 1;
                if sum(selector)
                    dSeqNo = dSeqNo(selector) - 1;
                    T = T(logical([1; selector(:)]));
                    T(1) = [];
                    T = quant(T(:), 1/orgsps);
                    T(end) = Tinterp(end);
                    Z = double(ismember(Tinterp(:), T));
                    n = sum(Z);
                    Z(Z==1) = dSeqNo(1:n);
                else
                    Z = 0;
                end;
                Data(:,chSeqNo) = Z;

                % Select requested channels
                Data = Data(:,channelnrs);  DTable = DTable(channelnrs);

            otherwise
                fprintf('\n%s: %s source not supported!', mfilename,DataType);
        end;




        % Suuntos ANT based heart rate belt
        %
        % => NOTE: Method tsFixSuuntoHRMData is NOT yet adapted to the
        % characteristics of the new Suunto Comfort Belt which is much more
        % sensitive and thus reports many more intervals (R peak times)
        % 
        % Data channels:
        % 4. sequence number, um fehlende Pakete zu identifizieren
        % ..
        % 6. Instant HR; computed from 60000/RR
        % 7. HR received from belt (smoothed!)
        % 8. maybe battery status (somehow unknown/unused byte)
        % 9. maybe minutes the device has been active (somehow unknown/unused byte)
    case { 'SUUNTOHRM' }
        switch lower(source)

            case { 'toolbox' }

                % Get sample rate from Marker
                orgsps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);
                
                % Load entire data file
                Data = load(DataFile);

                % Set params
                seqNo = Data(:,4);
                maxSeqNo = 256;

                % Calculate data time vector on host [s]
                Ts = (Data(:,1) - Data(1,1)) + (Data(:,2) / 10^6);

                debit = Ts(end) * 5;
                actual = length(Ts);
                missing = debit - actual;

                fprintf('\n%s:\n\tPacket stats (raw) :\tDebit: %10d (100.00%%),\tActual: %10d (%6.2f%%),\tMissing: %10d (%6.2f%%)', ...
                    DataType, uint32(round(debit)), uint32(round(actual)), double(actual/debit)*100, uint32(round(missing)), missing/debit*100);

                % Fix time series missing data samples
                devId = Data(1,3);
                RR = Data(:,5);
                Data = Data(:,6:end);                
                [Ts RR Data seqNo] = tsFixSuuntoHRMData(RR, Data, Ts, seqNo, maxSeqNo, orgsps, 'verbose', true);
                Tus = rem(Ts, 1) * 10^6;
                Ts = floor(Ts);
                devId = devId(ones(size(Data,1), 1));
                Data = [Ts Tus devId seqNo RR Data];

                % Select requested channels
                Data = Data(:,channelnrs);  DTable = DTable(channelnrs);

            otherwise
                fprintf('\n%s: %s source not supported!', mfilename,DataType);
        end;






        % Martin's fancy ultra-low power acceleration sensor
%     case {  'BODYANT', 'BODYANTLFA', 'BODYANTLTH', 'BODYANTCUB', 'BODYANTRFA', 'BODYANTRTH', 'BODYANTCUF', ...
%             'BODYANT01', 'BODYANT02', 'BODYANT03', 'BODYANT04', 'BODYANT05', 'BODYANT06', 'BODYANT07', 'BODYANT08', 'BODYANT09' }
    case { 'BODYANT', 'BA' }  % treat all these variants as subtype, i.e. by using BODYANT_*
        switch lower(source)
            case { 'toolbox' }

                % Get sample rate from Marker
                % OAM REIVIST: assume 16 Hz sampling rate, needs separate case for other setting
                %orgsps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);
                orgsps = 16; 

                % Load entire data file
                Data = load(DataFile);

                % Set params
                seqNo = Data(:,end);
                maxSeqNo = 256;

                % Calculate data time vector on host [s]
                Ts = (Data(:,1) - Data(1,1)) + (Data(:,2) / 10^6);

                % Detect overruns
                dTs = diff(Ts);
                N = floor(dTs * orgsps/maxSeqNo) * maxSeqNo;

                % Compute number of samples not received
                dSeqNo = mod(diff(seqNo), maxSeqNo);
                
%                 % ---------------------------------------------------------
%                 % MK REVISIT: It might happen that N is out by one period
%                 p = find((dTs * orgsps) - (N + dSeqNo) > round(maxSeqNo/2));
%                 if ~isempty(p), N(p) = N(p) + maxSeqNo; end;
%                 p = find((N + dSeqNo) - (dTs * orgsps) > round(maxSeqNo/2));
%                 if ~isempty(p), N(p) = N(p) - maxSeqNo; end;
%                 % ---------------------------------------------------------
                
                dSeqNo = N(:) + dSeqNo(:);

                % Time vector of transmitter computed from sequence numbers
                T = [0; 1/orgsps * cumsum(dSeqNo(:))];

                debit = T(end) * 2*orgsps;
                actual = size(Data,1);
                missing = debit - actual;
                
                if verbose>0
                    fprintf('\n%s:\n\tPacket stats (raw) :\tDebit: %10d (100.00%%),\tActual: %10d (%6.2f%%),\tMissing: %10d (%6.2f%%)', ...
                        DataType, uint32(round(debit)), uint32(round(actual)), double(actual/debit)*100, uint32(round(missing)), missing/debit*100);
                end;
                
                % Fix time series missing data samples
                [Ts Data seqNo] = tsFixData(Data(:,3:end-1), Ts, seqNo, maxSeqNo, orgsps, 'verbose', verbose);
                % OAM REVISIT: disabled us column (behaviour consistent with CRNT loader)
                %Tus = rem(Ts, 1) * 10^6;
                %Ts = floor(Ts);
                %Data = [Ts Tus Data seqNo];
                Data = [Ts Data seqNo];
                %Data = [Ts Data(:,3:end-1) seqNo];

                % add virtual channels of needed
                if any(vchannels) && ~all(cellstrmatch(Channels, DTable(~vchannels)))
                    if (verbose), fprintf('\n%s: Source %s has %u virtual channels, patching...', mfilename, DataType, sum(vchannels)); end;
                    [VData VDTable] = repos_loaddata_patch(Repository, Partindex, Range, Data, DTableActual, DTable);
                    if ~all(cellstrmatch(DTable(vchannels), VDTable)), error('Could not patch all channels.'); end;
                    Data = VData; DTable = VDTable;
                end;
                
                
                % Select requested channels
                Data = Data(:,channelnrs);  DTable = DTable(channelnrs);

            otherwise
                fprintf('\n%s: %s source not supported!', mfilename, DataType);
        end;



        % AliveTec mobile ECG with integrated 3-axes accelerometer
    case { 'ALIVEECG', 'ALIVEACC' }

        switch lower(source)
            case { 'toolbox' }

                % Get sample rate from Marker
                orgsps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);

                % Load entire data file
                Data = load(DataFile);

                % Get event channel of push button
                ch = repos_findassoc(Repository, Partindex, 'ALIVEevent', DataType);

                % Boost event channel
                gain = 200;
                Data(:,ch) = gain * Data(:,ch);

                % Resample data
                switch(DataType)
                    case {'ALIVEECG'}
                        sps = 300;
                    otherwise
                        sps = 75;
                end;
                [p q] = rat(orgsps/sps);
                Data = resample(Data, p, q);
                
                Data = Data(:,channelnrs);  DTable = DTable(channelnrs);

            otherwise
                fprintf('\n%s: %s source not supported!', mfilename,DataType);
        end;


    % EmoBoard mobile EDA with 2 integrated 3-axes accelerometers
    % (one of them is noisy so only 1 left to use)
    case { 'EMO' }

        switch lower(source)
            case { 'toolbox' }

                % Get sample rate from Marker
                orgsps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);
                
                % True data sample rate
                sps = 20.73; % Emo1 (20.73), Emo2 (20.72)
                                
                % Load entire data file
                Data = load(DataFile);
                    
                if true
                    % Fix missing samples
                    seqNo = Data(:,4);
                    numSeqNo = 512;                    
                    
                    % Calculate data time vector on host [s]
                    Ts = (Data(:,1) - Data(1,1)) + (Data(:,2) / 10^6);
                    
                    % Detect overruns
                    dTs = diff(Ts);
                    N = floor(dTs * sps/numSeqNo) * numSeqNo;
                    
                    % Compute number of samples not received
                    dSeqNo = mod(diff(seqNo), numSeqNo);
                    dSeqNo = N(:) + dSeqNo(:);
                                        
                    % MK REVISIT: Determine corrupted samples -------------
                    % Data channel start index depend on domain
                    switch DataType_tokens{2}
                        case 'ACC'
                            p = 8;
                        case 'EDA'
                            p = 5;
                    end;
                    % Median window half window size 
                    n = 2; 
                    % Max. deviation from median value
                    k = .5;
                    % Candidates are identified by missing sequence numbers
                    candidates = find([dSeqNo > 1; 0]);
                    for i = 1:numel(candidates)
                        sel = candidates(i);
                        medianVals = median(Data(sel-n:sel+n,p:end));
                        thisVals = Data(sel, p:end);
                        upperBound = medianVals + (k * medianVals);
                        lowerBound = medianVals - (k * medianVals);
                        % Delete corrupted samples if outside bounds
                        if any(thisVals > upperBound | thisVals < lowerBound)
                            Data(sel, :) = [];
                            % Correct position of successors
                            candidates = candidates - 1;
                        end;
                    end;
                    % Restore required values                    
                    seqNo = Data(:,4);                                       
                    % Calculate data time vector on host [s]
                    Ts = (Data(:,1) - Data(1,1)) + (Data(:,2) / 10^6);                    
                    % Detect overruns
                    dTs = diff(Ts);
                    N = floor(dTs * sps/numSeqNo) * numSeqNo;                    
                    % Compute number of samples not received
                    dSeqNo = mod(diff(seqNo), numSeqNo);
                    dSeqNo = N(:) + dSeqNo(:);
                    % -----------------------------------------------------
                    
                    
                    
                    % Time vector of transmitter computed from sequence numbers
                    T = [0; 1/sps * cumsum(dSeqNo(:))];
                    
                    debit = T(end) * sps;
                    actual = size(Data,1);
                    missing = debit - actual;
                    
                    if verbose>0
                        fprintf('\n%s:\n\tPacket stats (raw) :\tDebit: %10d (100.00%%),\tActual: %10d (%6.2f%%),\tMissing: %10d (%6.2f%%)', ...
                            DataType, uint32(round(debit)), uint32(round(actual)), double(actual/debit)*100, uint32(round(missing)), missing/debit*100);
                    end;
                    
                    % Fix time series missing data samples
                    [Ts Data seqNo] = tsFixData(Data(:,3:end), Ts, seqNo, numSeqNo, sps, 'verbose', verbose);
                    
                    Tus = rem(Ts, 1) * 10^6;
                    Ts = floor(Ts);
                    Data = [Ts Tus Data];

                    Data(:,4) = seqNo;
                end;
                
                % Resample data                
                [p q] = rat(orgsps/sps);
                Data = resample(Data, p, q);
                
                Data = Data(:,channelnrs);  DTable = DTable(channelnrs);

            otherwise
                fprintf('\n%s: %s source not supported!', mfilename,DataType);
        end;

    otherwise
        error('DataType %s is unknown.', DataType_tokens{1});
end;

if isempty(Data) && ErrorOnNoData, error('No data found, exiting.'); end;






function [VData VDTable] = repos_loaddata_patch(Repository, Partindex, Range, Data, DTableActual, DTable)

% --- add any processed columns ---
%warning('repos:Channels', 'change this code to use parameter Channels');
VDTable = DTable;
VData = zeros(size(Data,1), length(VDTable));

% copy channels from Data to VData
chnrs = col(cellstrmatch(DTableActual, VDTable));
if any(chnrs==0), error('Could not find all channels.'); end;
for i = 1:length(chnrs), VData(:, chnrs(i)) = Data(:, i); end;

% Euler angles: roll, pitch, yaw
% (As opposed to phi, theta, psi that are provided from the reading routines directly.)
if ~isempty(strmatch_substr('roll', VDTable))
    normsensors = DTable(strmatch_substr('roll', DTable));
    for s = 1:length(normsensors)
        sensorid = normsensors{s}(1:strfind(normsensors{s}, 'roll')-1);
        if ~isempty(strmatch_substr('r11', DTable))
            relsensors = [ ...
                strmatch([sensorid 'r11'], DTable), strmatch([sensorid 'r12'], DTable), strmatch([sensorid 'r13'], DTable), ...
                strmatch([sensorid 'r21'], DTable), strmatch([sensorid 'r22'], DTable), strmatch([sensorid 'r23'], DTable), ...
                strmatch([sensorid 'r31'], DTable), strmatch([sensorid 'r32'], DTable), strmatch([sensorid 'r33'], DTable), ...
                ];
            eulerdata = rot2eul(Data(:,relsensors));
        end;
        if ~isempty(strmatch_substr('q0', DTable))  && ~isempty(strmatch_substr('q3', DTable))
            relsensors = [ ...
                strmatch([sensorid 'q0'], DTable), strmatch([sensorid 'q1'], DTable), strmatch([sensorid 'q2'], DTable), strmatch([sensorid 'q3'], DTable), ...
                ];
            eulerdata = quat2euler(Data(:,relsensors));
        end;
        poschannels = cellstrmatch({[sensorid 'roll'], [sensorid 'pitch'], [sensorid 'yaw']}, VDTable);
        VData(:, poschannels) = eulerdata(:, poschannels>0);
    end;
end;

% distance to head
if ~isempty(strmatch_substr('head', VDTable))  % check if distances required
    headdata = xsens_getdist(Repository, Partindex, 'Range', Range);  % col1: right, col2: left
    if isempty(headdata), headdata = nan(size(Data,1), length(strmatch_substr('head', VDTable))); end;

    poschannels = strmatch_substr('head', VDTable);
    for i=1:length(poschannels)
        switch VDTable{poschannels(i)}
            case 'RA2head', VData(:, poschannels(i)) = headdata(:, 1);
            case 'LA2head', VData(:, poschannels(i)) = headdata(:, 2);                
        end;
    end;
end;

% acc normalisation
if ~isempty(strmatch_substr('accn', VDTable))  % check if acc norm required
    normsensors = VDTable(strmatch_substr('accn', VDTable));
    for s = 1:length(normsensors)
        sensorid = normsensors{s}(1:strfind(normsensors{s}, 'accn')-1);
        relsensors = [ strmatch([sensorid 'accx'], DTable), strmatch([sensorid 'accy'], DTable), strmatch([sensorid 'accz'], DTable) ];
        accndata = normv(Data(:,relsensors));

        poschannels = strmatch(normsensors{s}, VDTable);
        VData(:, poschannels) = accndata(:, poschannels>0);
    end;
end;

% mag normalisation
if ~isempty(strmatch_substr('magrn', VDTable))
    normsensors = VDTable(strmatch_substr('magrn', VDTable));
    for s = 1:length(normsensors)
        sensorid = normsensors{s}(1:strfind(normsensors{s}, 'magrn')-1);
        relsensors = [ strmatch([sensorid 'rx'], DTable), strmatch([sensorid 'ry'], DTable), strmatch([sensorid 'rz'], DTable) ];
        magndata = normv(Data(:,relsensors));

        poschannels = strmatch(normsensors{s}, VDTable);
        VData(:, poschannels) = magndata(:, poschannels>0);
    end;
end;
if ~isempty(strmatch_substr('magsn', VDTable))
    normsensors = VDTable(strmatch_substr('magsn', VDTable));
    for s = 1:length(normsensors)
        sensorid = normsensors{s}(1:strfind(normsensors{s}, 'magsn')-1);
        relsensors = [ strmatch([sensorid 'sx'], DTable), strmatch([sensorid 'sy'], DTable), strmatch([sensorid 'sz'], DTable) ];
        magndata = normv(Data(:,relsensors));

        poschannels = strmatch(normsensors{s}, VDTable);
        VData(:, poschannels) = magndata(:, poschannels>0);
    end;
end;
if ~isempty(strmatch_substr('magn', VDTable))
    normsensors = VDTable(strmatch_substr('magn', VDTable));
    for s = 1:length(normsensors)
        sensorid = normsensors{s}(1:strfind(normsensors{s}, 'magn')-1);
        relsensors1 = [ strmatch([sensorid 'rx'], DTable), strmatch([sensorid 'ry'], DTable), strmatch([sensorid 'rz'], DTable) ];
        relsensors2 = [ strmatch([sensorid 'sx'], DTable), strmatch([sensorid 'sy'], DTable), strmatch([sensorid 'sz'], DTable) ];
        magndata = normv(Data(:,relsensors1)-Data(:,relsensors2));

        poschannels = strmatch(normsensors{s}, VDTable);
        VData(:, poschannels) = magndata(:, poschannels>0);
    end;
end;
