function [newlist classes] = list_classfilter(MergeClassSpec, oldlist, varargin)
% function newlist = list_classfilter(MergeClassSpec, oldlist, varargin)
%
% Convert a class ID list according to MergeClassSpec.
% If a class is not considered in MergeClassSpec, it is associated to ID of DumpClass (default: 0).
%
% Example:
% list_classfilter({[1 2], [3, 5]},  [1 4 3 2 1 3 3 4 4 ]) 
% 
%   1     0     2     1     1     2     2     0     0
% 
% See also: segment_classfilter
% 
% Copyright 2009 Oliver Amft

[ClassIDMode DumpClassID] = process_options(varargin, 'ClassIDMode', 'renumber', 'DumpClassID', 0);
newlist = oldlist;

classes = zeros(1,length(MergeClassSpec));
changed = false(size(oldlist));
for classno = 1:length(MergeClassSpec)
    thisclass = MergeClassSpec{classno}(1); % new class number, determined from 1st entry

    for oldclass = row(MergeClassSpec{classno})
        changed = changed | (oldlist==oldclass);

        switch lower(ClassIDMode)
            case 'renumber'
                newlist(oldlist==oldclass) = classno;
            case 'keepid'
                newlist(oldlist==oldclass) = thisclass;
            otherwise
                error('ClassIDMode not understood.');
        end;
    end;
end;

% if DumpClassID is empty, entries get removed.
newlist(~changed) = DumpClassID;
classes = unique(newlist);


