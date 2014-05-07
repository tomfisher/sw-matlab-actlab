% initmain_useslice
% 
% Remove some PIs from evaluation set, provides section UseSlice
% WARNING: Works currently for coninuous PIs at beginning of Partlist only.
% 
% Adapts: Partlist, partoffsets, labellist_load, labellist
% 
% requires
OmitPInrs;

% OAM REVISIT: Move to initmain child script, providing UseSlice
% select subset of slices
if ~exist('OmitPInrs','var') || isempty(OmitPInrs)
    error('\n%s: WARNING: Parameter OmitPInrs not found.', mfilename);
end;

UsePInrs = find(~vec2onehot(OmitPInrs, length(Partlist)));
tmp =  offsets2segments(partoffsets);
UseSlice = segment_distancejoin(tmp(UsePInrs,1:2),2);
clear tmp;

% adapt settings
Partlist = Partlist(UsePInrs);
partoffsets = [ 0 partoffsets(UsePInrs)-UseSlice(1)+1 ];

fprintf('\n%s: OmitPInrs=%s: new setting: Partlist=%s, UseSlice=%s', mfilename, ...
    mat2str(OmitPInrs), mat2str(Partlist), mat2str(UseSlice));


% imitate initmain
% OAM REVISIT: Do not call initmain as long as the concept of initmain child scripts is in place
if (initmain_loadlabellist)
    [labellist_load partoffsets] = repos_getlabellist(Repository, Partlist);
end;
[labellist thisTargetClasses] = segment_classfilter(MergeClassSpec, labellist_load);
if isempty(labellist),
    warning('MATLAB:initmain', 'No target classes found.');
    thisTargetClasses = TargetClasses;
    fprintf('\n%s: Setting thisTargetClasses=%s', mfilename, mat2str(thisTargetClasses));
end;
if any(segment_size(labellist)==0), warning('initmain:zerolabels', 'Some labels have zero size.'); end;

fprintf('\n%s: Classes: %s', mfilename, mat2str(thisTargetClasses));
Classlist = Repository.Classlist(thisTargetClasses);
SampleRate = repos_getmarkersps(Repository, Partlist(1), 'singlesps', true);
