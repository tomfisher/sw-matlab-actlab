% setup toolbox search path for ACTLab toolboxes
%
% Run script using: run <path>/initialise.m

currpath = pwd;

actlabtoolboxes = {'crnt', 'fsel', 'isoclass', 'metrics', 'repos', 'sigproc', 'statistics', 'weka', 'featurebox', 'mainscripts', 'misc', 'segmentation', 'spotting', 'tmsif', 'xsens', 'bibtex'};

% path list w/o subdirs to include
% include is made with first entry appearing at top of path
for i = 1:size(actlabtoolboxes,2)
    tpath = [currpath filesep actlabtoolboxes{i}];
    if exist(tpath,'dir'), addpath(tpath, '-BEGIN'); end;
end;

clear actlabtoolboxes currpath tpath;