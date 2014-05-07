function [seglist, varargout] = segment_delovlist(cmplist, baselist, varargin)
% function [seglist] = segment_delovlist(cmplist, baselist, varargin)
%
% Remove cmplist overlaps from baselist and varargin vectors/matrices.
% WARNING: Only baselist will be used for the comparison. The corresponding 
%          indices will be removed from varargin vectors/matrices.
%
seglist = [];

baselist = cell2matrix(baselist);
cmplist = cell2matrix(cmplist);

% find segments w/o overlap
% novsegs=find(segment_countoverlap(cmplist, baselist) == 0);
novsegs=find(segment_countoverlap(baselist, cmplist) == 0);
if isempty(novsegs)
    %fprintf('\n%s: No overlaps found.', mfilename);
end;

% remove them in baselist and children
seglist = baselist([novsegs],:);

for arg = 1:length(varargin)
    varargout{arg} = varargin{arg}([novsegs],:);
end;
