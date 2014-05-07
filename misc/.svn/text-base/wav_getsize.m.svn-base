function [WAVSize WAVRate] = wav_getsize(Repository, Part, verbose)
% function DataSize = wav_getsize(Repository, Part, verbose)
%   Repository:     Repository, specifying stimuli (initdata.m)
%   Part:           Repository IDs to read (from initdata.m)
%   WAVSize:        Samples in Part
%   WAVRate:        Samples per second in Part

if (exist('verbose')~=1) verbose = 0; end;

RepEntry = Repository.RepEntries;

filename = wav_filename(Repository, Part);

[dummy1 WAVSize WAVRate] = WAVReader(filename);

if (verbose)
    fprintf('\n%s: WAV file %s size: %s, sps: %u\n', ...
        mfilename, filename, mat2str(WAVSize), WAVRate);
end;

