function mappedlabels = repos_translatelabels(Repository, SceneID, inlabels)
% function mappedlabels = repos_translatelabels(Repository, SceneID, inlabels)
%
% Map labels from another ID scheme (SceneID) to Repository.Classlist. Alternatively SceneID
% may be a list of cell strings for the mapping.
% 
% SceneID should indicate a translation string list to match each inlabel with Repository.Classlist.
% Todo: Implement alternative of providing mapping labels directly as parameter (autodetect option).
% 
% Copyright 2009, 2011 Oliver Amft
mappedlabels = inlabels;
if isempty(SceneID) || isempty(inlabels), return; end;

if isfield(Repository, ['Classtranslation', SceneID])
    translationlist = Repository.(['Classtranslation', SceneID]);
else
    translationlist = SceneID;
end;

useNumMapping = isnumeric(translationlist{2});
if useNumMapping, incr = 2; else incr = 1; end;

mappedlabels = zeros(size(inlabels, 1), 1);
for i = 1:incr:length(translationlist)
    
    % use either the provided ID (if useNumMapping) or enumeration order  to determine foreign class ID
    if useNumMapping
        foreignclass = translationlist{i+1};
    else
        foreignclass = i; %strmatch(lower(translationlist{i}), lower(foreignclasslist), 'exact');
    end;
    
    % find out which class to map to
    mapclass = strmatch(lower(translationlist{i}), lower(Repository.Classlist), 'exact');
    if isempty(mapclass)
        fprintf('\n%s: Could not find map for %s in Repository.Classlist.', mfilename, translationlist{i});
        error('Error in translation list');
    end;

    % find instances of foreignclass
    mappedlabels(inlabels==foreignclass) = mapclass;
end;

if size(mappedlabels,1) ~= size(inlabels,1), error('Something wrong here.'); end;