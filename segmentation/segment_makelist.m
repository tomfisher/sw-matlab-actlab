function seglist = segment_makelist(varargin)
% function seglist = segment_makelist(varargin)
%
% Create a segment list according to specifications
%
% See also: segment_createlist
%
% Copyright 2010 Oliver Amft

[Mode Count verbose] = process_options(varargin, ...
    'Mode', 'randcont', 'Count', 1000, 'verbose', 0);

Mode_tokens = str2cellf(Mode, '_');
for i = 1:length(Mode_tokens)
    
    switch lower(Mode_tokens{i})
        case 'randcont'
            offsetlist = cumsum(randi([1 1000], 1, Count+1));
            seglist = offsets2segments(offsetlist);
            
        case 'rand' % uniformly distributed segments
            
        case 'gsize' % gaussian segment size
            
        otherwise
            error('Mode %s not supported.', lower(Mode));
    end;
end;