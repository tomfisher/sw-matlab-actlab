% main_reposdynmarker
%
% Run Marker in on-demand mode with repos_prepdata2markerdata() to fetch the
% data. Proof of concept implementation.
% See also main_wavmarker.m
% 
% requires:
Partindex;

initdata;


loadparams = {...
    'Repository', Repository, 'Partindex', Partindex, ...
    'DataType', 'WAV', ...
    'WAVTrack', repos_findassoc(Repository, Partindex, 'IEAR', 'WAV'), ...
    };

[pathstr, name, ext] = fileparts(repos_getfilename(Repository, Partindex, 'WAV'));
if isempty(ext) ext = ['-' num2str(repos_findassoc(Repository, Partindex, 'IEAR', 'WAV')) '.wav']; end;
WAVFile = fullfile(pathstr, [name, ext]);
[WAVData, WAVSize, WAVRate] = WAVReader(WAVFile);

initlabels = cla_getseglist(Repository, Partindex, 'SampleRate', WAVRate);


% setup marker obj
clear obj;
for sysno = 1:length(1)
    thissys  = 'WAV';
    
    obj.disp(sysno).type = thissys;
    obj.disp(sysno).data = [];
    obj.disp(sysno).func = @plot;
    obj.disp(sysno).loadfunc = @repos_prepdata4marker;
    obj.disp(sysno).filename = '';
    obj.disp(sysno).loadfuncparams = loadparams;
    
    obj.disp(sysno).ylabel = [thissys ' [amp.]'];
    %obj.disp(sysno).alignshift = alignshift;
    %obj.disp(sysno).alignsps = alignsps;
    obj.disp(sysno).datasize = WAVSize;
    obj.disp(sysno).sfreq = WAVRate;
    obj.disp(sysno).xvisible = obj.disp(sysno).sfreq*40;
    
    obj.disp(sysno).playerdata.sourcefile = WAVFile;
    obj.disp(sysno).playerdata.sndgain = 1.5;
    obj.disp(sysno).playerdata.playchannel = 1;
end; % for sysno

obj.maxLabelNum = size(Repository.Classlist,2);
obj.labelstrings = Repository.Classlist;
obj.title = sprintf('WAV Part: %3u, Subject: %s', Partindex, repos_getfield(Repository, Partindex, 'Subject'));

[fdir fname fext] = fileparts(dbfilename(Repository, 'indices', Partindex, 'prefix', 'CLA', 'subdir', 'labels'));
fprintf('\n%s: Launching Marker...', mfilename);
marker(obj, initlabels, [fname fext], fdir);

