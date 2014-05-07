function data = repos_prepdata4marker(filename, Range, varargin)
% function data = repos_prepdata4marker(filename, Range, varargin)
% 
% Interface function to use repos_prepdata with the Marker
%
% Calling example:
%   v{1} = 'Alignment'; v{2} = false;
%   repos_prepdata4marker('', [1 inf], v{:});

data = [];

[Repository Partindex DataType  SampleRate Alignment WAVTrack ...
    MarkerRate verbose] = process_options(varargin, ...
    'Repository', [], 'Partindex', [], 'DataType', '', ...
    'SampleRate', 0, 'alignment', true, 'wavtrack', [], ...
    'MarkerRate', false, 'verbose', 0);


% Alignment

[Data] = repos_prepdata(Repository, Partindex, DataType, ...
    'SampleRate', SampleRate, 'alignment', Alignment, 'Range', Range, ...
    'wavtrack', WAVTrack, 'MarkerRate', MarkerRate, 'verbose', verbose );

