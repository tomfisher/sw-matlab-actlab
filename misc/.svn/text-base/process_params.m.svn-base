function [params options] = process_params(splitsign, varargin)
% function [params options] = process_params(varargin)
%
% Split parameters and options for a routine.
% The split is made where splitsign occurs in the parameter list.
% 
% Example: [required, options] = process_params('options', varargin{:});
%
% See also: process_options
%
% Copyright 2009-2010 Oliver Amft

if ~exist('splitsign', 'var'), splitsign = []; end; % unlikely ;-)

params = {}; options = {};

foundsplit = false;
for i = 1:length(varargin)
    splitsign; % prevent Matlab lint to complain
    
    if test('varargin{i}==splitsign')
        % found split
        if i>1, params = varargin(1:i-1); end;
        if i<length(varargin), options = varargin(i+1:end); end;
        foundsplit = true;
        break;
    end;
    
%     if test('varargin{i}==splitsign') && foundsplit == false, foundsplit = true; continue; end;
%     if foundsplit
%         if isempty(params), clear('params'); end;
%         params = varargin(i);
%     else
%         if isempty(options), clear('options'); end;
%         options(i) = varargin(i);
%     end;
end;

if ~foundsplit, params = varargin; end; % if no split was found, all belongs to required params
    