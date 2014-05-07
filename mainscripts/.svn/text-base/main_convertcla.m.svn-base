% main_convertcla
%
% requires
% Partlist


initdata;
StartTime = clock;
if ~exist('Partlist','var'), Partlist = Repository.UseParts; end;


if ~exist('YesDoWrite','var'), YesDoWrite = false; end;
disp(YesDoWrite);

for Partindex = Partlist
    allsystems = repos_getsystems(Repository, Partindex);
    if isemptycell(allsystems), continue; end;
    
    fprintf('\n%s: Process MARKER file for part %u...', mfilename, Partindex);

    filename = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'MARKER', 'subdir', 'labels');
    if exist(filename, 'file')==0
        fprintf('\n%s: File not found: %s, skipping', mfilename, filename);
        continue;
    end;
%     if (~exist(filename, 'file')) 
%         fprintf('\n%s: File does not exist, skip.', mfilename);
%         continue; 
%     end;
%     if isempty(strmatch('cla', lsmatfile(filename), 'exact'))
%         fprintf('\n%s: File does not contain ''cla'', skip.', mfilename);
%         error; 
%     end;
%     fprintf('\n%s: Loading: %s...', mfilename, filename);
    clear('seg', 'cla', 'labelstrings', 'markersps', 'partsize', 'alignshift', 'alignsps', 'datatypes', ...
        'SaveTime', 'MARKER_VERSION');
%     warning off;
%     load(filename, ...
%         'partsize', 'markersps', 'alignshift', 'alignsps', 'datatypes');
%     load(filename, ...
%         'seg', 'labelstrings', 'partsize', 'markersps', 'alignshift', 'alignsps', 'datatypes', ...
%         'SaveTime', 'MARKER_VERSION');
%     warning on;


% warning('off', 'matlab:cla');
% ps = cla_getpartsize(Repository, Partindex, 'RawMode', true);
% warning('on', 'matlab:cla');
% 
% fprintf('\n%s: Loading raw data => repos_prepdata()...', mfilename);
% usesystems = repos_getsystems(Repository, Partindex);
% 
% clear partsize;
% for sys = 1:length(usesystems)
%     [FeatureSet{sys}, dummyDTable datasps(sys)] = repos_prepdata(Repository, Partindex, usesystems{sys}, ...
%         'SampleRate', repos_getfield(Repository, Partindex, 'SFrq', usesystems{sys}), 'alignment', false);
%     partsize(sys) = length(FeatureSet{sys});
% end;
% 
% if (min(partsize) == min(ps)), fprintf('\n%s: min partsize is OK ', mfilename); end;
% if all(partsize == ps), fprintf('  all partsize OK.'); continue; end;
% 
% fprintf('\n%s:  ==> need to restore partsize:  MARKER:%u, shoud be:%u,  diff:%u', mfilename, min(ps), min(partsize), abs(min(ps)-min(partsize)));
% fprintf('\n%s:                        MARKER:%s', mfilename, mat2str(ps));
% fprintf('\n%s:                        actual:%s', mfilename, mat2str(partsize));

[alignshift alignsps alignrate plottypes found] = repos_getalignment(Repository, Partindex);
indices = strmatch('BODYANT', plottypes);
for i = row(indices)
    if strcmp(plottypes{i}, 'BODYANT'), continue; end;
    plottypes{i} = [ 'BODYANT_' plottypes{i}(length('BODYANT')+1:end) ];
end;
strvcat(plottypes)	
    
    % ---------------------------------------------------------------------
    % create/convert information
    % ---------------------------------------------------------------------
    
% 	if any(hasfrac(seg(:,1))) || any(hasfrac(seg(:,2)))
% 		fprintf(' ===========> Has frac!  <=================');
% 		seg(:,1:2) = [ round(seg(:,1)) round(seg(:,2)) ];
% 		seg(:,3) = segment_size(seg);
% 	end;
	
	
	
% 	delpos = (partsize == 1);
% 	
% 	if any(delpos)
% 		partsize(delpos) = [];
% 		markersps(delpos) = [];
% 		alignshift(delpos) = [];
% 		alignsps(delpos) = [];
% 		datatypes(delpos) = [];
% 		fprintf('\n%s:   Removed pos %u', mfilename, find(delpos==1));
% 	end;

% ---------------------------------------------------------------------
%     seg = classlabels2segments(cla);
    %     tmpseg = round(RepEntry(Partindex).Seg*markersps);
    %     seg = [tmpseg  segment_size(tmpseg) ...
    %         repmat(strmatch(RepEntry(Partindex).ClassAsStr, Repository.Classlist),size(tmpseg,1),1), ...
    %         (1:size(tmpseg,1))' zeros(size(tmpseg,1),1) ];
    %seg = segment_resample(seg, markersps(1), 128);

    
    % ---------------------------------------------------------------------
%     features_filename = dbfilename(Repository, 'indices', Partindex, 'prefix', 'Features_Part', ...
%         'subdir', 'MARKERDATA', 'globalpath', Repository.Path);
%     try
%         load(features_filename, 'partsize');
%         partsize;
%     catch
%         fprintf('\n%s: Feature file not found: %s, skipping', mfilename, features_filename);
%         continue;
%     end;

%     tmpdata = repos_prepdata(Repository, Partindex, 'XSENS', 'alignment', false);
%     partsize = size(tmpdata,1);
% %partsize = 0;


    % ---------------------------------------------------------------------
%     markersps = 256;
    
%     markersps =  cla_getmarkersps(Repository, Partindex, 'singlesps', true);
%     markersps = repmat(repos_getfield(Repository, Partindex, 'SFrq'), 1, length(Repository.RepEntries(Partindex).Systems));
    
    % ---------------------------------------------------------------------
    %alignshift = ceil( alignshift * 128/markersps(1) );
    %alignsps =  alignsps .* 128/markersps(1) ;
    %alignshift = 0;
    %alignsps = 0;


    % ---------------------------------------------------------------------
    %     labelstrings = Repository.Classlist;

    % ---------------------------------------------------------------------
    %datatypes = repos_getsystems(Repository, Partindex);
    
    
    % ---------------------------------------------------------------------
%     [pathstr, name, ext] = fileparts(filename);
%     filename = fullfile('DATA', 'tmp', [name, ext]);
    
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    
    SaveTime = clock;

    MARKER_VERSION='1.2.0 convertcla';
    %fprintf('\n%s: partsize=%s, markersps=%s', mfilename, mat2str(partsize), mat2str(markersps));
    
    % store it in CLA file
    if (YesDoWrite == true)
        fprintf('\n%s: Saving: %s...', mfilename, filename);
%         save(filename, ...
%             'seg', 'labelstrings', 'partsize', 'markersps', 'alignshift', 'alignsps', 'datatypes', ...
%             'SaveTime', 'MARKER_VERSION');
%         save(filename, '-append', ...
%             'alignshift', 'alignsps', 'markersps', 'partsize', 'datatypes', ...
%             'SaveTime', 'MARKER_VERSION');
        save(filename, '-append', ...
            'plottypes', ... % 'seg', ...
            'SaveTime', 'MARKER_VERSION');
    else
        fprintf('\n%s: Simulate saving: %s...', mfilename, filename);
    end;
    %seg; labelstrings; partsize; markersps; alignshift; alignsps; SaveTime; MARKER_VERSION;
end;

fprintf('\n%s: Partlist: %s', mfilename, mat2str(Partlist));
if (YesDoWrite)
    fprintf('\n%s: Setting YesDoWrite to false.', mfilename);
    YesDoWrite = false;
else
    fprintf('\n%s: Simulated only, use YesDoWrite = true to write.', mfilename);
end;
fprintf('\n%s: Done.\n', mfilename);
