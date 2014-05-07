function DataStruct = makedatastruct(Repository, Partlist, FeatureString, DSSet, varargin)
% function DataStruct = makedatastruct(Repository, Partlist, FeatureString, DSSet, varargin)
%
% Load DataStruct as requested by FeatureString, Partlist
% 
% Copyright 2006-2008 Oliver Amft

[DynamicLoad Alignment verbose] = process_options(varargin, 'DynamicLoad', false, 'Alignment', true, 'verbose', 1);

usesources = fb_getsources(FeatureString, 'Uniquify', true);
usesystems = unique_nosort(repos_getsysfromsensor(Repository, Partlist(1), usesources));

if isempty(usesystems), error('FeatureString does not match. Nothing to do!'); end;
%BaseRate = repos_getfield(Repository, Partlist(1), 'SFrq');
BaseRate = repos_getmarkersps(Repository, Partlist(1), 'singlesps', true);

DataStruct = [];
for sys = 1:length(usesystems)
	if (verbose)
        if DSSet.(usesystems{sys}).SampleRate
            fprintf('\n%s: Load %s data (index: %s) at rate %u Hz...', ...
                mfilename, usesystems{sys}, mat2str(Partlist), DSSet.(usesystems{sys}).SampleRate);
        else
            % set SampleRate=0 to get orignial datarate
            fprintf('\n%s: Load %s data (index: %s) at recorded data rate...', ...
                mfilename, usesystems{sys}, mat2str(Partlist));
        end;
	end;
    if (DynamicLoad)
        % load data if DataStruct is accessed by makefeatures*() methods
        Data = [];
        DTable = repos_getdtable(Repository, Partlist, usesystems{sys});
        Range = [0 0];
	else
        % static data load
% 		loadchannels = []; % hack to run with large&many WAV tracks find channels to load
% 		if strcmpi(usesystems{sys}, 'WAV'), 
% 			loadchannels = repos_findassoc(Repository, Partlist(1), usesources, 'WAV'); 
% 			fprintf(' channels:%s', mat2str(loadchannels));
% 		end;

        this_usesources = repos_findsensorsforsystem(Repository, Partlist(1), usesystems{sys}, usesources);
        if isemptycell(this_usesources), error('Inconsistency detected: system %s has no sensors.', usesystems{sys}); end;
		[Data, DTable SampleRate] = repos_prepdata(Repository, Partlist, usesystems{sys}, ...
            'SampleRate', DSSet.(usesystems{sys}).SampleRate, 'alignment', Alignment, 'Channels', this_usesources );
        Range = [1 size(Data,1)];
    end;
    
    thisFeatureString = fb_findforsources(FeatureString, ...
        repos_getfield(Repository, Partlist(1), 'Assoc', usesystems{sys}));

    datastruct_sys = fb_createdatastruct(usesystems{sys}, Data,   Repository, Partlist, DTable, ...
        thisFeatureString, SampleRate, BaseRate, 'Range', Range);

    % copy all fields from DSSet to datastruct_sys
    dsfields = fieldnames(DSSet.(usesystems{sys}));
    for setidx = 1:size(dsfields,1)
        if strcmp(dsfields{setidx}, 'SampleRate'), continue; end;  % makes no sense to copy as it is adapted beforehand
        datastruct_sys = fb_modifydatastruct(datastruct_sys, dsfields{setidx}, DSSet.(usesystems{sys}).(dsfields{setidx}));
    end;
        
    DataStruct = [DataStruct; datastruct_sys];
end;
