function [Data, DTable, sps] = repos_prepdata(Repository, Partlist, DataType, varargin)
%function [Data, DTable, sps] = repos_prepdata(Repository, Partlist, DataType, varargin)
%
% Fetch data for given part indices.
% 
% Options:
%       Range         Data slice to load, in original sample rate (not yet supported!) 
% 
% See also: repos_loaddata, makedatastruct
% 
% Copyright 2007-2009 Oliver Amft

% OAM REVISIT: removed ClassAsStr, allSegLabels, partoffsets

[SampleRate Alignment Range Channels verbose] = process_options(varargin, ...
    'SampleRate', 0, 'Alignment', true, 'Range', [1 inf], 'Channels', {}, 'verbose', 0);

% ClassAsStr = repos_getclasses(Repository, Partlist);
% DataType = upper(DataType);


Data = []; %partoffsets = 0;
for Partindex = Partlist
    if (verbose), fprintf('\n%s: Processing PI %u...', mfilename, Partindex); end;
	
    % load data
    [Data_part normsps DTable] = repos_loaddata(Repository, Partindex, DataType, ...
        'Range', Range, 'Channels', Channels, 'verbose', verbose);

    
    if isempty(Data_part), error('File not found.'); end;
    
    

    % align data
    % * Need to adapt begin if no alignment was found (since sample rate
    %   changes begin of ranges.
    % * Adapt for equal sizes: Data may have different lengths and
    %   alignment. Need to adapt for shortest dataset. Variable partsize
    %   contains shortest length, adapt each stream accordingly.
    loadsps = normsps;
    if Alignment
        %[alignshift alignsps alignrate] = cla_getalignment(Repository, Partindex);
        [alignshift alignsps alignrate plottypes found] = repos_getalignment(Repository, Partindex);

        %sysidx = repos_getsysindex(Repository, Partindex, DataType);
        sysidx = strmatch(DataType, plottypes, 'exact');
        if isempty(sysidx)
            fprintf('\n%s: WARNING: Cannot find plottype match for DataType %s.', mfilename, DataType); 

            fprintf('\n%s: Trying lazy match for DataType %s...', mfilename, DataType); 
            sysidx = strmatch_substr(DataType, plottypes);
            if isempty(sysidx)
                error('WARNING: Cannot find plottype match for DataType.');
            end;
            fprintf(' => %s', plottypes{sysidx});
        end;
        if length(sysidx) > 1, 
            sysidx = sysidx(1); 
            fprintf('\n%s: WARNING: Found multiple matches for DataType %s in label file.', mfilename, DataType); 
        end;

        markersps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);
        % alignsps is defined as change of markersps to achieve the nominal
        % sampling rate. Here the effectivly sampled rate is needed.
        
        % OAM REVISIT: Is it now 1/alignrate OR markersps - alignsps ??
        %loadsps = (markersps - alignsps(sysidx)) * normsps/markersps;
        loadsps = 1/alignrate(sysidx) * normsps;
    end;
    
    % adapt SampleRate
    if (SampleRate > 0)
        [p q] = rat(SampleRate/loadsps);
        sps = SampleRate;
    else
        if loadsps==0,  [p q] = deal(1, 1);  else  [p q] = rat(normsps/loadsps); end;
        sps = normsps;
    end;
    
    
    Data_part = resample(Data_part, p, q);
    
    
    if Alignment    
        %[p q] = rat(alignrate(sysidx));
        %Data_part = resample(Data_part, p, q);
        
        dbeg = 1 + alignshift(sysidx); % + (alignshift(sysidx)==0);
        if segment_size(Range) >= inf
            partsize = repos_getpartsize(Repository, Partindex);
            if isnan(partsize) || (partsize==0)
                error('No information for alignment available but requested.');
            end;
            Range = segment_resample([1 partsize], markersps, sps);  % Range is in actual sps, not marker!
        else
            partsize = segment_size(segment_resample(Range, sps, markersps));
        end;
        
        % convert from marker sps to nominal sps
        range_r = segment_resample([dbeg dbeg+partsize-1], markersps, sps);

        % due to rounding issues expected data may be larger, adapt it here
        % rationale: issue araise from difference of markersps and actual
        % sampling rate used here
        rdiff = size(Data_part,1) - range_r(2);
        if (rdiff < 0) 
            fprintf('\n%s: Adapting data, partindex %u: %d...\n', mfilename, Partindex, round(rdiff));
            % OAM REVISIT: Verified with datamarker and wavmarker that
            % rdiff should NOT be used here. (Fusion part 13, IEAR)
            %range_r = [range_r(1)+rdiff size(Data_part,1)]; % rdiff is negative!!
            range_r = [range_r(1) size(Data_part,1)];
        end;
        if (rdiff < -sps*0.3)
            fprintf('\n%s: Problem in adapting data!', mfilename);
            fprintf('\n%s: Partindex: %u, DataType: %s, Diff: %d', ...
                mfilename, Partindex, DataType, round(rdiff));
            %range_r = [];
        end;
        
        Data_part = Data_part(range_r(1):range_r(2),:);
    end;

    Data = [Data; Data_part];
    %partoffsets = [partoffsets partoffsets(end)+size(Data_part,1)];
end; % for part