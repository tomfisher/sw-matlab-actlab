function seglist = segment_createlist(begendlist, varargin)
% function seglist = segment_createlist(begendlist, varargin)
%
% Returns a segment list with the following columns:
% [START STOP LENGTH LABEL COUNT CONFIDENCE]  (LENGTH is in samples)
%
% Options:
% classlist     List of class labels or single class label
% conflist      List of label confidences or single confidence value
% classconflist     List of class and confidence 
% template      As the name says, template for segment list
% 
% Copyright 2006-2008 Oliver Amft
% 
% See also: segment_makelist

seglist = [];
if isempty(begendlist), return; end;

nrsegments = size(begendlist,1);

% check if classlist available
if (size(begendlist,2) >= 4) 
    default_classlist = begendlist(:,4); 
else
    default_classlist = ones(nrsegments,1); 
end;

% check if conflist available
if (size(begendlist,2) >= 6) 
    default_conflist = begendlist(:,6); 
else
    default_conflist = ones(nrsegments,1); 
end;

[classlist, conflist, classconflist, template] = process_options(varargin, ...
    'classlist', default_classlist, 'conflist', default_conflist, 'classconflist', [], 'template', []);

% classconflist overrides previous settings
if ~isempty(classconflist)
    classlist = classconflist(:,1);  conflist = classconflist(:,2);
end;

% template overwrites previous settings
if ~isempty(template)
    if (length(template)>=4), classlist = template(:,4); end;
    if (length(template)>=6), conflist = template(:,6); end;
end;


% if there are not enough elements in the provided lists expand them using
% first element
if (size(classlist,1) < nrsegments), classlist = repmat(classlist(1), nrsegments,1); end;
if (size(conflist,1) < nrsegments), conflist = repmat(conflist(1), nrsegments,1); end;

% now, build list
seglist = [ begendlist(:,1:2), segment_size(begendlist), ...
    classlist, (1:nrsegments)', conflist ];
