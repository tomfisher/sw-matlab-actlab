function [fmatrix found seglist partoffsets FeatureString] = fb_loadfeatures(Repository, Partlist, varargin)
% function [fmatrix found seglist partoffsets FeatureString] = fb_loadfeatures(Repository, Partlist, varargin)
%
% Load features for given informations and create fmatrix, seglist.
% If some feature file(s) cannot be found, returns empty matrices.
%
% Optional parameters:
% StopOnNotFound  Exit when a part feature file was not found
% PartFiles         Save/Load a file for each Partindex; default=true
% fidx              Filename suffix for feature files; default='test'
% IgnoreFileVersion Disable feature file version checking; bool, default=false
%
% For more parameters, see source code. See also: fb_computefeatures.m

fmatrix = []; seglist = []; partoffsets = []; FeatureString = {};
found = false;

DEFAULT_VERSION = 'V005';

[FeaturePathPriority StopOnNotFound PartFiles Subject ...
    fidx IgnoreFileVersion VERSION verbose] = process_options(varargin, ...
    'FeaturePathPriority', 0, 'StopOnNotFound', true, 'PartFiles', true, 'Subject', 'ALLUSERS', ...
    'fidx', 'unknown', 'IgnoreFileVersion', false, 'VERSION', DEFAULT_VERSION, 'verbose', 1);

if (verbose), fprintf('\n%s: %s', mfilename, VERSION); end;


% load all features
% OAM REVISIT: Implement priority scheme

% filename = dbfilename(Repository, 'prefix', 'Features', 'indices', Partlist, 'suffix', fidx, 'subdir', FeatureDir, 'GlobalPath', GlobalPath);
filename = fb_findfeaturefile(Repository, Partlist, fidx, Subject, 'priority', FeaturePathPriority);
if exist(filename,'file') && ~PartFiles
    if strcmp(VERSION, loadin(filename, 'VERSION')) || IgnoreFileVersion
        if (verbose), fprintf('\n%s: Load features from %s...', mfilename, filename); end;
        load(filename, 'fmatrix', 'seglist', 'partoffsets');
        found = true;
        return;
    else
        if (verbose)
            fprintf('\n%s: Feature file version mismatch (file=%s)...', mfilename, loadin(filename, 'VERSION'));
        end;
        return;
    end;
end;


% load features from partwise files
partoffsets = zeros(1, length(Partlist)+1);
seglist = [];
for partno = 1:length(Partlist)
    Partindex = Partlist(partno);

    % load feature file, if possible
    %filename = dbfilename(Repository, 'prefix', 'Features', 'indices', Partindex, 'suffix', fidx, 'subdir', FeatureDir, 'GlobalPath', GlobalPath);
    filename = fb_findfeaturefile(Repository, Partindex, fidx, Subject, 'priority', FeaturePathPriority);

    if exist(filename,'file') && (strcmp(VERSION, loadin(filename, 'VERSION')) || IgnoreFileVersion)

        % compare feature strings of all files
        % (mk) bugfix: if partno > 1 and filename of partno==1 does not
        % exists, this must work anyway! 
        if (partno==1) || isempty(FeatureString)
        %if (partno==1)
            FeatureString = loadin(filename, 'FullFeatureString');
        else
            if strvcat(FeatureString) ~= strvcat(loadin(filename, 'FullFeatureString'))
                fprintf('\n%s: Features do not match for PI %u.', mfilename, Partindex);
                %found = false;
                error('');
            end;
        end;


        if (verbose), fprintf('\n%s: Load features for PI %u from %s...', mfilename, Partindex, filename); end;
        fmatrix_part = []; partseglist = []; partsize = [];
        load(filename, 'fmatrix_part', 'partseglist', 'partsize');

        fmatrix = [fmatrix; fmatrix_part];

        % OAM REVISIT: USE of reconstructed labels is a bad idea!
        partoffsets(partno+1) = partoffsets(partno) + partsize;
        seglist = [ seglist; [partseglist(:, 1:2)+partoffsets(partno)  partseglist(:, 3:end)] ];

        found = true;

    else

        if (verbose)
            if ~exist(filename,'file'), fprintf('\n%s: Not found: %s.', mfilename, filename); end;
            if exist(filename,'file') && ~(strcmp(VERSION, loadin(filename, 'VERSION')) || IgnoreFileVersion)
                fprintf('\n%s: Feature file: %s has different version (%s), expected: %s', mfilename, ...
                    filename, loadin(filename, 'VERSION'), VERSION);
            end;
        end;
        if (StopOnNotFound)
            fmatrix = []; partoffsets = []; seglist = [];
            found = false;
            return;
        end;
        % (mk) fixed obsolete function call
        %partoffsets(partno+1) = partoffsets(partno) + cla_getpartsize(Repository, Partindex);
        partoffsets(partno+1) = partoffsets(partno) + repos_getpartsize(Repository, Partindex);

    end; % if exist(filename,'file')
end; % for partno

