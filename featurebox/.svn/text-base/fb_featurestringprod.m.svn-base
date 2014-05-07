function FeatureString = fb_featurestringprod(varargin)
% function FeatureString = fb_featurestringprod(varargin)
%
% Make a feature string cross-product from indiviudal components, cell
% arrays may be provided for all parts.
%
% No eligibilitiy check is performed.
% 
% Note: To remove '_' (e.g. for other purposes than feature strings) use
%   regexprep(fb_featurestringprod( {'huhu'}, {'haha'}), '_', '')
%
% See also: cellappend.m, cellstringprod.m
% 
% Copyright 2008 Oliver Amft

param1 = varargin{1};

if ~iscell(param1), param1 = { param1 }; end;

% extend first input parameter with content from following ones
for i = 2:nargin
	FeatureString = {};
	this_param = varargin{i};
	if ~iscell(this_param), this_param = { this_param }; end;
	%if length(this_param)~=length(FeatureString), this_param = repmat(this_param, 1, length(FeatureString)); end;

	for f = 1:length(this_param)

		this_FeatureString = cell(1, length(param1));
		for f1 = 1:length(param1)
			this_FeatureString{f1} = [ param1{f1} '_' this_param{f} ];
		end; % for f1
		FeatureString = { FeatureString{:} this_FeatureString{:} };
	end; % for f
	param1 = FeatureString;

end; % for i
