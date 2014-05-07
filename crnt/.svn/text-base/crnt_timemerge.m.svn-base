function [MergedData] = crnt_timemerge(TDataStruct, varargin)
% function [MergedData] = crnt_timemerge(TDataStruct, varargin)
%
% Merge CRNT logfile datastreams using timestamp.
% All timestamps have the format: sec*1e6+usec.
%
% Parameters:
%   TDataStruct().timestampdata(1) - timestamp (sec*1e6+usec)
%   TDataStruct().timestampdata(2..n) - data channels
% Output:
%   MergedData: [Timestamp, <channels>]
%
% Copyright 2008 Oliver Amft
% 
% See also:  crnt_maketimestamp
% 
% Superseeded by main_crnt_mergestreams.m

MergedData = [];

[resamplesps keepbuffer updatelast msgfreq_underrun msgfreq_overflow verbose] = process_options(varargin, ...
    'resamplesps', 0, 'keepbuffer', 0, 'updatelast', true, ...
    'msgfreq_underrun', 1e3, 'msgfreq_overflow', 1e2, 'verbose', 1);

% determine start time, continue relative from there
% timestampdata is assumed to be monotonical increasing
all_starttime = zeros(1, length(TDataStruct));  all_endtime = zeros(1, length(TDataStruct));
totalchannels = zeros(1, length(TDataStruct));
totalsamples = zeros(1, length(TDataStruct)); all_avgsps = zeros(1, length(TDataStruct));
for sys = 1:length(TDataStruct)
    if isempty(TDataStruct(sys).timestampdata),  error('No data available for source %u', sys); end;
    if TDataStruct(sys).timestampdata(:,1) ~= sort(TDataStruct(sys).timestampdata(:,1), 'ascend')
        error('Data source %u has unsorted timestamps.', sys);
    end;

    all_starttime(sys) = TDataStruct(sys).timestampdata(1,1);
    all_endtime(sys) = TDataStruct(sys).timestampdata(end,1);
    totalchannels(sys) = size(TDataStruct(sys).timestampdata, 2)-1;  % remove timestamp channel
    totalsamples(sys) = size(TDataStruct(sys).timestampdata,1);
    all_avgsps(sys) = 1e6 /mean(diff(TDataStruct(sys).timestampdata(:,1)));
    % (totalsamples(sys) *1e6) / (TDataStruct(sys).timestampdata(end,1) - TDataStruct(sys).timestampdata(1,1)) ;
end;

starttime = min(all_starttime); endtime = max(all_endtime);
channelpos = [0 cumsum(totalchannels)] + 1;
if (verbose), fprintf('\n%s: Erliest start time is %u', mfilename, starttime); end;
if (verbose), fprintf('\n%s: Latest end  time is %u', mfilename, endtime); end;
if (verbose), fprintf('\n%s: Total channels: %s', mfilename, mat2str(totalchannels)); end;
if (verbose), fprintf('\n%s: Avg. sample rates: %s', mfilename, num2str(all_avgsps, ' %.1fHz')); end;

mark_upsample = false(1, length(TDataStruct));
mark_downsample = false(1, length(TDataStruct));
mark_willjitter = false(1, length(TDataStruct));
for sys = 1:length(TDataStruct)
    if ( all_avgsps(sys) < resamplesps )
        if (verbose),
            fprintf('\n%s: Source %u will be upsampled (avg sps: %.1fHz, nom: %.1fHz)', mfilename, ...
                sys, all_avgsps(sys), resamplesps);
        end;
        mark_upsample(sys) = true;
    end;
    if ( all_avgsps(sys) > resamplesps )
        if (verbose),
            fprintf('\n%s: Source %u will be downsampled (avg sps: %.1fHz, nom: %.1fHz)', mfilename, ...
                sys, all_avgsps(sys), resamplesps);
        end;
        mark_downsample(sys) = true;
    end;
    if ( abs(all_avgsps(sys) - resamplesps) < 1 )
        if (verbose),
            fprintf('\n%s: Source %u has similar to merged data rate (avg sps: %.1fHz, nom: %.1fHz)', mfilename, ...
                sys, all_avgsps(sys), resamplesps);
            fprintf('\n%s:   Will omit reports of sample jitter.', mfilename);
        end;
        mark_willjitter(sys) = true;
    end;

    % check for severe data rate underflows
    tmp = abs(diff(TDataStruct(sys).timestampdata(:,1))) > (1e6/all_avgsps(sys) *1e1);
    if any(tmp)
        if (verbose),
            fprintf('\n%s: Source %u has lost data at %u of %u positions (%.1f%%)', mfilename, ...
                sys, sum(tmp), length(tmp), sum(tmp)/length(tmp)*100 );
            if sum(tmp) < 10,   fprintf(': %s', mat2str(find(diff(tmp)>0)) );   end;
        end;
    end;
    % check for severe data rate overflows
    tmp = abs(diff(TDataStruct(sys).timestampdata(:,1))) < (1e6/all_avgsps(sys) /1e1);
    if any(tmp)
        if (verbose)
                fprintf('\n%s: Source %u has burst data at %u of %u positions (%.1f%%)', mfilename, ...
                    sys, sum(tmp), length(tmp), sum(tmp)/length(tmp)*100 );
                if sum(tmp) < 10,   fprintf(': %s', mat2str(find(diff(tmp)>0)) );   end;
        end;
    end;

end;

% add samples at rate resamplesps OR aligned to rate of first channel
if resamplesps>0
    rtime = starttime:(1/resamplesps*1e6):endtime;  % rtime is in usec
else
    % advance to next timestep using first source
    rtime = TDataStruct(1).timestampdata(:,1);
end;
merged_avgsps = 1e6/mean(diff(rtime));

prate = 0.1;
cnt_samples = 0;  last_datapos = ones(1, length(TDataStruct));  last_estimated = ones(1, length(TDataStruct));
cont_underrun = zeros(1, length(TDataStruct));  cont_overflow = zeros(1, length(TDataStruct));
MergedData = nan(length(rtime), sum(totalchannels)+1);  MergedData(:,1) = rtime;
if (verbose), fprintf('\n%s: Processing, wait...', mfilename); end;
for cnt_samples = 2:length(rtime)
    %fprintf(' %u', cnt_samples);
    %     if (cnt_samples == 14050)
    %         disp('breakpoint');
    %     end;
    prate = print_progress(prate, cnt_samples/length(rtime));

    for sys = 1:length(TDataStruct)
        % speculated max point for sample search (this optimises search effort)
        % need to account for start and end sample availability
        % if data losses occur: gaps in samples, estimation potentially too far (performance issue)
        % if data bursts occur: samples with similar (faster than avgsps) rate, estimation potentially too short (PROBLEM!)
        estimated_maxpos = min( totalsamples(sys), last_datapos(sys) + ...
            max(last_estimated(sys)-last_datapos(sys)+1, ceil( all_avgsps(sys)/merged_avgsps*10 )) );
        %         estimated_maxpos = min( totalsamples(sys), last_datapos(sys) + ...
        %            max(1, ceil( (rtime(cnt_samples)-rtime(cnt_samples-1))/1e6 * all_avgsps(sys) ) ) );
        if (TDataStruct(sys).timestampdata(estimated_maxpos) <= rtime(cnt_samples)) && (estimated_maxpos < totalsamples(sys))
            %estimated_maxpos = find(TDataStruct(sys).timestampdata(last_datapos(sys):end)>rtime(cnt_samples), 1, 'first');
            % this is faster than find (as above), if many samples have to be searched
            estimated_maxpos = findseqelement(TDataStruct(sys).timestampdata(last_datapos(sys):end), ...
                rtime(cnt_samples), 'mode', 'gt',  'N', 1, 'direction', 'first') + last_datapos(sys)-1;
            estimated_maxpos = min( totalsamples(sys), estimated_maxpos );
        end;
        last_estimated(sys) = estimated_maxpos;

        % perform buffer search
        row = find(isbetween( ...
            TDataStruct(sys).timestampdata(last_datapos(sys):estimated_maxpos,1), ...
            [rtime(cnt_samples-1)+eps rtime(cnt_samples)] ))   + last_datapos(sys)-1;

        % ideal case: one sample found
        if ( length(row)==1 ),
            values = TDataStruct(sys).timestampdata(row,2:end);
            MergedData(cnt_samples, channelpos(sys)+1:channelpos(sys+1)) = values;
            last_datapos(sys) = row;
            continue;
        end;

        % check if samples have been lost
        if ( isempty(row) ) %||  ((rtime( cnt_samples)-TDataStruct(sys).timestampdata(row,1)) > all_avgsps(sys))
            if (verbose) && (~rem(cont_underrun(sys), msgfreq_underrun)) && (~mark_upsample(sys)) ...
                    && ( ~(mark_willjitter(sys)) && rem(cont_underrun(sys), msgfreq_underrun) ),
                fprintf('\n%s: No samples for source %u, at sample %u (buffer underrun) for %u samples.', mfilename, ...
                    sys, cnt_samples, cont_underrun(sys));
            end;
            if updatelast && (cnt_samples>1)
                values = MergedData(cnt_samples-1, channelpos(sys)+1:channelpos(sys+1));
            else
                values = nan(1, totalchannels(sys));
            end;

            cont_underrun(sys) = cont_underrun(sys) + 1;
            %cont_overflow(sys) = 0;
        else
            % if ( length(row)>1 )
            if (verbose) && (~rem(cont_overflow(sys), msgfreq_overflow)) && (~mark_downsample(sys)) ...
                    && ( ~(mark_willjitter(sys)) && rem(cont_overflow(sys), msgfreq_overflow) ),
                fprintf('\n%s: Found accumulated buffer for source %u, at sample %u for %u samples.', mfilename, ...
                    sys, cnt_samples, cont_overflow(sys));
            end;

            values = TDataStruct(sys).timestampdata(row(end), 2:end);
            last_datapos(sys) = row(end);
            %cont_underrun(sys) = 0;
            cont_overflow(sys) = cont_overflow(sys) + 1;
        end;

        MergedData(cnt_samples, channelpos(sys)+1:channelpos(sys+1)) = values;
    end;  % for sys
end;  % for cnt_samples

% remove unused buffer
if size(MergedData,1) > cnt_samples, MergedData(cnt_samples+1:end, :) = []; end;

if (verbose)
    fprintf('\n%s: Underflow count: %s', mfilename, mat2str(cont_underrun));
    fprintf('\n%s: Overflow count: %s', mfilename, mat2str(cont_overflow));
    fprintf('\n%s: Source jitter state: %s', mfilename, mat2str(mark_willjitter));
end;
