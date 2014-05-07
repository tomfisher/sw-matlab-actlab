% main_prepmarker
%
% requires
Partlist;
% GlobalPath;

initdata;
StartTime = clock;
fprintf('\n%s() start: %s\n', mfilename, datestr(now));

if ~exist('MarkerFileLocation', 'var'), MarkerFileLocation = '*'; end;
    
if ~exist('GlobalPath', 'var'), GlobalPath = Repository.Path; 
else fprintf('\n%s: GlobalPath = ''%s''', mfilename, GlobalPath); end;

if ~exist('forcewrite', 'var'), forcewrite = false; end;
if ~exist('StopOnReadFailure', 'var'), StopOnReadFailure = false; end;
if ~exist('DefAllSystems', 'var'), DefAllSystems = {}; end;

for Partindex = Partlist
	if any(isemptycell(repos_getsystems(Repository, Partindex))), continue; end;
    if isemptycell(DefAllSystems), allsystems = repos_getsystems(Repository, Partindex);
    else allsystems = DefAllSystems; end;
    
    if isempty(allsystems), continue; end;

  
    
    fprintf('\n%s: Process data set %u...', mfilename, Partindex);

    % determine MARKERDATA file location
    markerdata_filename = findmarkerdatafile(Repository, Partindex, 'MarkerFileLocation', MarkerFileLocation);
	if exist(markerdata_filename,'file') && (forcewrite==false)
		fprintf('\n%s: File %s exist and forcewrite not set, skipping.', mfilename, markerdata_filename);
		fprintf('\n');	continue;
	end;
    
    
    
    partsize = []; 
	clear FeatureSet;  SysFeatureString = cell(1, length(allsystems));
    for sysno = 1:length(allsystems)
        thissys = allsystems{sysno};
        
        markersps =  repos_getmarkersps(Repository, Partindex, 'singlesps', true);
        %markersps = repos_getfield(Repository, Partindex, 'SFrq');
        newsps = markersps;
        
        fprintf('\n%s:    Read stream %s...', mfilename, thissys);
        try
%             [thisData, DTable, oldsps] = ...
%                 repos_prepdata(Repository, Partindex, lower(thissys), 'alignment', false);
            
            [thisData oldsps DTable] = repos_loaddata(Repository, Partindex, thissys, 'ErrorOnNoFile', false);
            
        catch
            if StopOnReadFailure
                fprintf('\n%s:    Failed to read stream %s, stop.', mfilename, thissys);
                error(' Failed to read stream.');
            else
                fprintf('\n%s:    Failed to read stream %s, skipping...', mfilename, thissys);
                continue;
            end;
        end;
        rawpartsize = size(thisData,1);
        
        % setting for: (windowsize), (windowstep), (thisFeatureString), (newsps)
        windowsize = 1; %sec
        windowstep = 1;
        %channels = repos_getfield(Repository, Partindex, 'Assoc', thissys);
        thisFeatureString = {};
        % this will match all channels listed
        for ch = DTable
            thisFeatureString = {thisFeatureString{:} [ch{:} '_resample']};
        end;
		
		source = repos_getfield(Repository, Partindex, 'Source', thissys);

        % non-default setting for: (windowsize), (windowstep), (thisFeatureString), (newsps)
        DataType_tokens = str2cellf(thissys, '_');
        switch DataType_tokens{1}
            case 'XSENS'
                % OAM REVISIT
                % This is a hack to select Euler or inertial features,
                % requires RLA sensor since strmatch() needs match from begin
                if strmatch('LHSphi', DTable) 
%                     thisFeatureString = { ...
%                         'LLAphi_resample', 'LLAtheta_resample', 'LLApsi_resample', ...
%                         'RLAphi_resample', 'RLAtheta_resample', 'RLApsi_resample'  };
%                     thisFeatureString = { ...
%                         'LLAphi_resample', 'LLAtheta_resample', 'LLApsi_resample', ...
%                         'RLAphi_resample', 'RLAtheta_resample', 'RLApsi_resample', ...
% 						'LHSphi_resample', 'LHStheta_resample', 'LHSpsi_resample' };
%                     thisFeatureString = { ...
%                         'LLAphi_resample', 'LLAtheta_resample', 'LLApsi_resample', ...
%                         'RLAphi_resample', 'RLAtheta_resample', 'RLApsi_resample', ...
% 						'RLAaccx_resample', 'RLAaccy_resample', 'RLAaccz_resample', 'RLAgyrx_resample', 'RLAgyry_resample', 'RLAgyrz_resample', ...
% 						'LLAaccx_resample', 'LLAaccy_resample', 'LLAaccz_resample', 'LLAgyrx_resample', 'LLAgyry_resample', 'LLAgyrz_resample', ...
% 						'LHSaccx_resample', 'LHSaccy_resample', 'LHSaccz_resample', 'LHSgyrx_resample', 'LHSgyry_resample', 'LHSgyrz_resample' };
                    thisFeatureString = { ...
                        'LLAphi_resample', 'LLAtheta_resample', 'LLApsi_resample', 'LLAaccx_resample', 'LLAaccy_resample', 'LLAaccz_resample', 'LLAgyrx_resample', 'LLAgyry_resample', 'LLAgyrz_resample', ...
                        'RLAphi_resample', 'RLAtheta_resample', 'RLApsi_resample', 'RLAaccx_resample', 'RLAaccy_resample', 'RLAaccz_resample', 'RLAgyrx_resample', 'RLAgyry_resample', 'RLAgyrz_resample', ...
						'LHSphi_resample', 'LHStheta_resample', 'LHSpsi_resample', 'LHSaccx_resample', 'LHSaccy_resample', 'LHSaccz_resample', 'LHSgyrx_resample', 'LHSgyry_resample', 'LHSgyrz_resample', ...
                        'CUBphi_resample', 'CUBtheta_resample', 'CUBpsi_resample', 'CUBaccx_resample', 'CUBaccy_resample', 'CUBaccz_resample', 'CUBgyrx_resample', 'CUBgyry_resample', 'CUBgyrz_resample', ...
                        };
                else
                    thisFeatureString = thisFeatureString(1:6);
                end;
            case 'EMG'
                windowsize = round(newsps*0.150); %sec; step = 1!
                windowstep = 1;
                thisFeatureString = {};
				if strcmpi(source, 'bioexp')
					for ch = DTable
						thisFeatureString = {thisFeatureString{:} [ch{:} '_resample_abs_mean']};
					end;
				else
					% toolbox reader: assume 4 channel EMG and remaining for control 
					for ch = DTable(1:4)
						thisFeatureString = {thisFeatureString{:} [ch{:} '_emgfilter_resample_abs_mean']};
					end;
					for ch = DTable(5:end)
						thisFeatureString = {thisFeatureString{:} [ch{:} '_resample']};
					end;					
				end;					

            case 'WAV'
% %                 adasps = 2^floor(log2(oldsps));
%                 windowsize = round(oldsps * 0.05); %sec
%                 windowstep = oldsps / newsps;
%                 if (rem(oldsps, newsps)) 
%                     fprintf('\n%s: windowstep is not integer.', mfilename); 
%                     error; 
%                 end;
%                 
% %                 newsps = adasps;
%                 % this will match all channels listed
%                 thisFeatureString = {};
%                 for ch = DTable
%                     thisFeatureString = {thisFeatureString{:} [ch{:} '_abs_mean']};
%                 end;
                ch = strmatch('ACC', DTable);
                if ~isempty(ch)
                    thisFeatureString{ch} = 'ACC_butterbp4_resample';
                end;
                

            case 'STR'
                % nothing to do here
            case 'SCALES'
                thisFeatureString = {};
                for ch = DTable
                    %thisFeatureString = {thisFeatureString{:} [ch{:} '_simpleupsample']};
					thisFeatureString = {thisFeatureString{:} [ch{:} '_value']};  % data loaded at 128Hz
                end;

            case {'CRNT', 'BODYANT', 'BA'}
                if strcmp(DataType_tokens{2}, 'LABEL'), continue; end;
                
                ch = strmatch('CRNTtime', DTable);
                thisFeatureString(ch) = [];  % omit time (resampling this channel makes no sense)
                
            otherwise
                error('Unknown system type %s', thissys);
        end;                

        fprintf('\n%s:    Process features for stream %s (raw partsize: %usa @%uHz)...', mfilename, thissys, rawpartsize, oldsps);
        thisDataStruct = fb_createdatastruct(thissys, thisData, Repository, Partindex, DTable, thisFeatureString, oldsps, newsps);
        thisFeatures = makefeatures([1 size(thisData,1)], thisDataStruct, ...
            'swmode', 'cont', ...
            'oldsps', oldsps, 'newsps', newsps, ...
            'swsize', windowsize, 'swstep', windowstep, ...
            'lowfrq', 25, 'highfrq', 4410);

        % determining partsize here for the entire processing is tricky:
        % makefeatures() may return less samples than expected from
        % resampling due to sliding window effects - hence we compute the
        % theoretical size from the raw data directly and adapt it to the
        % standard sampling rate
        %newsps = cla_getmarkersps(Repository, Partindex, 'singlesps', true); % correct value here
        newsps = markersps;
        
        partsize = [ partsize ceil(size(thisData,1)*newsps/oldsps) ];
        FeatureSet{sysno} = thisFeatures;
        SysFeatureString{sysno} = thisFeatureString;
    end; % for sysno
    
    % shall happen only, if load failed
    if isempty(SysFeatureString{sysno})
        fprintf('\n%s:    Skip features file for part %u', mfilename, Partindex);
        continue;
    end;
    
    fprintf('\n%s:    Partsize    : %s at %uHz', mfilename, mat2str(partsize), newsps);
	tmp = whos('FeatureSet');
    fprintf('\n%s:    Featuresize : %s (%uKB)', mfilename, ...
		mat2str(cellfun('size', FeatureSet,1)), round(tmp.bytes/1024) );
    
    fprintf('\n%s:    Save features to %s...', mfilename, markerdata_filename);
    SaveTime = clock;
    save(markerdata_filename, 'FeatureSet', ...
        'newsps', 'partsize', 'allsystems', 'SysFeatureString', 'StartTime', 'SaveTime');
end; % for Partindex

fprintf(' Done.\n');
fprintf('\n%s: Finished. (CPU: %.0fs).\n', mfilename, etime(clock, StartTime));
fprintf('\n%s() run, end: %s\n\n', mfilename, datestr(now));
