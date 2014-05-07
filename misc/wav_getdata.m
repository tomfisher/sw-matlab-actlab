function [Data, DataSize, DataRate] = wav_getdata(Repository, Partindex, varargin)
% function [Data, DataSize, DataRate] = wav_getdata(Repository, Partindex, varargin)
%   Data:           Requested data cell array, one sensor per cell
%   DataSize:       Samples read per part from Part
%   Repository:     Repository, specifying stimuli (initdata.m)
%   Partindex:      Repository ID to read (from initdata.m)
%
% Options:
%   Range:          Selection of WAV range (in samples) from the full vector
%                   Called without WAVRange returns all data, e.g. [0 inf].
%                   If Range is too large (end), returns remaining data.
%   Channels:       WAV tracks to read
%   verbose:        Console messages
%

[Range, Channels, verbose] = process_options(varargin, ...
    'Range', [1 inf], 'Channels', [], 'verbose', 0);

Data = []; DataSize = []; DataRate = [];

% find file(s)
if isempty(repos_getfield(Repository, Partindex, 'File', 'WAV')) 
    fprintf('\n%s: No audio file(s) found for Partindex %u', mfilename, Partindex);
    return; 
end;
% filename = fullfile(Repository.Path, repos_getfield(Repository, Partindex, 'Dir', 'WAV'), ...
%     repos_getfield(Repository, Partindex, 'File', 'WAV'));
filename = repos_getfilename(Repository, Partindex, 'WAV');

if exist(filename, 'file')
    % singe file audio
    if (verbose), fprintf('\n%s: Reading single audio file %s...', mfilename, filename); end;
    [Data DataSize DataRate] = WAVReader(filename, Range, 'Channels', Channels);
    
else
    % multi-track audio
    idx = 1;
    thisfilename = [filename '-' num2str(idx) '.wav'];
    if (~exist(thisfilename, 'file')) 
        fprintf('\n%s: No audio files found at %s', mfilename, thisfilename);
        return; 
    end;
    
    while (exist(thisfilename, 'file'))
        % read only if track is in WAVTrack
        if (~isempty(Channels)) && (~any(Channels == idx)) 
            idx = idx + 1;  thisfilename = [filename '-' num2str(idx) '.wav'];
            continue; 
        end;
        
        if (verbose), fprintf('\n%s: Reading track %u (%s)...', mfilename, idx, thisfilename); end;

        [thisData thisDataSize thisDataRate] = WAVReader(thisfilename, Range); %, 'Channels', Channels);
        if (idx == 1) || ( (~isempty(Channels)) && (Channels(1) == idx) )
            DataSize = thisDataSize; DataRate = thisDataRate;
        else
            diffDataSize = DataSize-thisDataSize;
            
            if (abs(diffDataSize)>DataRate) || (thisDataRate ~= DataRate)
                fprintf('\n%s: Incompatible audio tracks of mulit track set.', mfilename);
                error('');
            end;
            if (abs(diffDataSize)>0)
                fprintf('\n%s: Correcting track %u of mulit track set, length by %d.', mfilename, idx, diffDataSize);
                if (diffDataSize > 0) 
                    % less data, pad
                    thisData = [thisData; zeros(diffDataSize, size(thisData,2))];
                else
                    % too much of it, omit last
                    % OAM REIVIST: Not used.
                    thisData = thisData(1:DataSize,:);
                end;
            end;
            
        end;

        Data = [Data thisData];
        
        idx = idx + 1;
        thisfilename = [filename '-' num2str(idx) '.wav'];
    end;
end;


if (verbose)
    fprintf('\n%s: WAV channels read: %u length: %u (%.3fs) \n', ...
        mfilename, size(Data,2), size(Data,1), size(Data,1)/DataRate);
end;


