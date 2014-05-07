% main_wavmarker
%
% Run Marker with WAV file from initdata and alignment settings from CLA.
% The WAV is loaded in on-demand mode. 
% See also main_reposmarker.m
% 
% requires:
Partindex;
% UseChannels;

if (~exist('UseChannels','var')), UseChannels = []; end;

initdata;

is_multitrack = false;
[pathstr, name, ext] = fileparts(repos_getfilename(Repository, Partindex, 'WAV'));
if isempty(ext)
    is_multitrack = true;
    if isempty(UseChannels)
        ext = ['-' num2str(repos_findassoc(Repository, Partindex, 'IEAR', 'WAV')) '.wav'];
    else
        if length(UseChannels) == 1
            ext = ['-' num2str(UseChannels) '.wav'];
        else
            error('Multitrack not supported.');
        end;
    end;
end;
WAVFile = fullfile(pathstr, [name, ext]);
[WAVData, WAVSize, WAVRate] = WAVReader(WAVFile);



[alignshift alignsps] = cla_getalignment(Repository, Partindex, 'SampleRate', WAVRate);
% OAM REVISIT: This is a hack, get it from CLA file
wavsys = repos_getsysindex(Repository, Partindex, 'WAV');
alignshift = alignshift(wavsys); alignsps = alignsps(wavsys);



initlabels = cla_getseglist(Repository, Partindex, 'SampleRate', WAVRate);


% setup marker drawerobj
clear drawerobj;
for sysno = 1:length(wavsys)
    thissys  = 'WAV';
    
    drawerobj.disp(sysno).type = thissys;
    drawerobj.disp(sysno).data = [];
    drawerobj.disp(sysno).plotfunc = @plot;
    drawerobj.disp(sysno).loadfunc = @WAVReader;
    %drawerobj.disp(sysno).loadfunc_filename = repos_getfield(Repository, Partindex, 'File', thissys);
    drawerobj.disp(sysno).loadfunc_filename = WAVFile;
    if (is_multitrack)
        drawerobj.disp(sysno).loadfunc_params = {'precision', 'single'};
    else
        drawerobj.disp(sysno).loadfunc_params = {'channels', repos_findassoc(Repository, Partindex, 'IEAR', 'WAV'), 'precision', 'single'};
    end;

    drawerobj.disp(sysno).ylabel = [thissys ' [amp.]'];
    drawerobj.disp(sysno).alignshift = alignshift;
    drawerobj.disp(sysno).alignsps = alignsps;
    drawerobj.disp(sysno).datasize = WAVSize;
    drawerobj.disp(sysno).sfreq = WAVRate;
    drawerobj.disp(sysno).xvisible = drawerobj.disp(sysno).sfreq*40;

    
    drawerobj.disp(sysno).playerdata(1).sourcefile = WAVFile;
    %drawerobj.disp(sysno).playerdata(1).playchannel = UseChannel;
    drawerobj.disp(sysno).playerdata(1).gain = 1.5;
end; % for sysno


drawerobj.maxLabelNum = size(Repository.Classlist,2);
drawerobj.labelstrings = Repository.Classlist;
drawerobj.title = sprintf('WAV Part: %3u, Subject: %s', Partindex, repos_getfield(Repository, Partindex, 'Subject'));

[fdir fname fext] = fileparts(dbfilename(Repository, 'indices', Partindex, 'prefix', 'CLA', 'subdir', 'labels'));
drawerobj.iofilename = [fname fext];
drawerobj.defaultDir = fdir;

fprintf('\n%s: Launching Marker...', mfilename);
marker(drawerobj, initlabels);
