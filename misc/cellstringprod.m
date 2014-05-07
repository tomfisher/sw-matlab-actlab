function ostr = cellstringprod(varargin)
% function ostr = cellstringprod(varargin)
%
% Make a feature string cross-product from indiviudal components, cell
% arrays may be provided for all parts.
%
% No eligibilitiy check is performed.
% 
% See also: cellappend.m, fb_featurestringprod.m
% 
% Copyright 2008 Oliver Amft

param1 = varargin{1};

if ~iscell(param1), param1 = { param1 }; end;

% extend first input parameter with content from following ones
for i = 2:nargin
	ostr = {};
	this_param = varargin{i};
	if ~iscell(this_param), this_param = { this_param }; end;

	for f = 1:length(this_param)
		this_ostr = cell(1, length(param1));
		for f1 = 1:length(param1)
			this_ostr{f1} = [ param1{f1}  this_param{f} ];
		end; % for f1
		ostr = { ostr{:} this_ostr{:} };
	end; % for f
	param1 = ostr;
end; % for i
