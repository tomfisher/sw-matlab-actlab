function raws = fb_getsources(FeatureString, varargin)
% function raws = fb_getsources(FeatureString, varargin)
%
% Extract 'Sensors' from FeatureString
% 
% Copyright 2006-2008 Oliver Amft

[Uniquify NoSort] = process_options(varargin, ...
    'Uniquify', false, 'NoSort', true);

raws = cell(1, length(FeatureString));
for f = 1:length(FeatureString)
    tokens = fb_getelements(FeatureString{f});
    
    raws{f} = tokens{1};
end;

% find original items in raws
if Uniquify && ~NoSort, raws = unique(raws); end;

% unique has sorted entries in raws, restore original ordering here
% see also: unique_nosort
if Uniquify && NoSort,   raws = unique_nosort(raws);  end;


