function [Data, DTable, sps] = repos_prepdata(Repository, Partlist, DataType, varargin)
%function [Data, DTable, sps] = repos_prepdata(Repository, Partlist, DataType, varargin)
%
% Fetch data for given part indices. 
% 
% Options:
% Range         Data slice to load, in original sample rate
% 
% Copyright 2007 Oliver Amft

error('\nThis code is not working. Use repos_prepdata.m instead.');


[SampleRate Alignment Range WAVTrack MarkerRate verbose] = process_options(varargin, ...
    'SampleRate', 0, 'alignment', true, 'Range', [1 inf], 'wavtrack', [], ...
    'MarkerRate', false, 'verbose', 0);

% ClassAsStr = cla_getclasses(Repository, Partlist);
DataType = upper(DataType);

% fetch DTable
DTable = repos_getdtable(Repository, Partlist, DataType);


Data = []; %partoffsets = 0;
for Partindex = Partlist
    % OAM REVISIT: What if Range is given and Partlist contains multiple
    % indices? => Need to find correct part using BaseRate. Is this critical?
    % Alternative: Find true datasize from source data.
    thisRange = Range;

    
    if Alignment
        % align data preparations
        % thisRange must be adapted using alignment here
        %
        % thisRange is supplied under the assumption of correct sampling rate. At
        % this point the sampling rate for the real uncorrected sensor data
        % must be used to fetch the data slice however.

        if (verbose) fprintf('\n%s: Adapt load ranges...', mfilename); end;
        
        % fake load to get sample rate
        [dummy orgsps] = repos_loaddata(Repository, Partindex, DataType, ...
            'Range', [1 2], 'WAVTrack', WAVTrack);

        sysidx = repos_getsysindex(Repository, Partindex, DataType);
        %[alignshift alignsps alignrate] = cla_getalignment(Repository, Partindex, 'adaptshift', true);
        [alignshift alignsps alignrate found] = cla_getalignment(Repository, Partindex, 'SampleRate', orgsps);
        if (found == 0) % || (partsize==0)
            fprintf('\n%s: No information for alignment available but requested.', mfilename);
            fprintf('\n%s: To disable alignment, use parameter ''alignment''=false .', mfilename);
            error;
        end;

        thisRangeCorr = thisRange + alignshift(sysidx);
        
        %markersps = cla_getmarkersps(Repository, Partindex, 'singlesps', true);
        [p,q] = rat( (orgsps + alignsps(sysidx)) / orgsps ); % newsps / oldsps
        thisRangeCorr = segment_resample(thisRangeCorr, orgsps, orgsps - alignsps(sysidx));
        
        %partsize = cla_getpartsize(Repository, Partindex);
    end;
    

    % load data
    [Data_part orgsps] = repos_loaddata(Repository, Partindex, DataType, ...
        'Range', thisRangeCorr, 'WAVTrack', WAVTrack);
    
    
%     % adapt SampleRate
%     if (SampleRate > 0)
%         if (verbose)
%             fprintf('\n%s: Adapt sample rate: orgsps: %u, newsps: %u.', ...
%                 mfilename, orgsps, SampleRate);
%         end;
% 
%         [p q] = rat( SampleRate/(orgsps + alignsps) );
%         Data_part = resample(Data_part, p, q);
%         %partsize = ceil(partsize .* SampleRate/orgsps);
%         sps = SampleRate;
%     else
%         sps = orgsps;
%     end;

    
    % align data
    % * Need to adapt begin if no alignment was found (since sample rate
    %   changes begin of ranges.
    % * Adapt for equal sizes: Data may have different lengths and
    %   alignment. Need to adapt for shortest dataset. Variable partsize
    %   contains shortest length, adapt each stream accordingly.
    if Alignment
        if (verbose) fprintf('\n%s: Adapt data after loading...', mfilename); end;

        partsize = cla_getpartsize(Repository, Partindex);
        if isnan(partsize) || (partsize==0) 
            fprintf('\n%s: No information for alignment available but requested.', mfilename); 
            fprintf('\n%s: To disable alignment, use parameter ''alignment''=false .', mfilename); 
            error;
        end;

%         %range_r = segment_resample([dbeg dbeg+partsize-1], markersps, sps, 'segmentmode', false);
%         range_r = segment_resample([dbeg dbeg+partsize-1], markersps, sps);

%         [p q] = rat(alignrate(sysidx));
        if (SampleRate > 0)
            if (verbose)
                fprintf('\n%s: Adapt sample rate: orgsps: %u, newsps: %u.', mfilename, orgsps, SampleRate);
            end;
            
            [p q] = rat(SampleRate/(orgsps+alignsps)); % newsps / oldsps
            Data_part = resample(Data_part, p, q);
            sps = SampleRate;
        else
            % p,q have been computed above already
            Data_part = resample(Data_part, p, q);
            sps = orgsps;
        end;

        % due to rounding issues expected data may be larger, adapt it here
        % assumption: issue araise from difference of markersps and actual
        % sampling rate used here
        rdiff = size(Data_part,1) - segment_size(thisRange);
        if (rdiff < 0) 
            fprintf('\n%s: Adapting data part %u: %d...\n', mfilename, Partindex, round(rdiff));
            range_r = []; % rdiff is negative!!

            if (abs(rdiff) > sps*0.25) 
                fprintf('\n%s: Problem in adapting data!', mfilename);
                fprintf('\n%s: Partindex: %u, DataType: %s, Diff: %d', ...
                    mfilename, Partindex, DataType, round(rdiff));
                range_r = [];
            end;
        else
            if (rdiff > 0)
                fprintf('\n%s: Adapting data part %u: %d...\n', mfilename, Partindex, round(rdiff));
            end;
            range_r = [1 size(Data_part,1)-rdiff];
        end;
        
        Data_part = Data_part(range_r(1):range_r(2),:);
    end;

    
    
    Data = [Data; Data_part];
    %partoffsets = [partoffsets partoffsets(end)+size(Data_part,1)];
end; % for part
