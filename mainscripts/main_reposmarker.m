% main_reposmarker
%
% Run Marker on features processed from repository data.
% See also main_wavmarker.m, main_datamarker.m
% 
% requires:
Partindex;
FeatureString;
DSSet;

initdata;

fprintf('\n%s: load data...', mfilename);
DataStruct = makedatastruct(Repository, Partindex, FeatureString, DSSet);
datasize = fb_getdatasize(DataStruct);

fprintf('\n%s: process features...', mfilename);
features = makefeatures([1 datasize], DataStruct, 'swmode', 'cont');

initlabels = cla_getseglist(Repository, Partindex, 'SampleRate', DataStruct.SampleRate);


% setup marker obj
clear obj;
for sysno = 1:size(features,2)
    thissys  = 'WAV';
    
    obj.disp(sysno).type = thissys;
    obj.disp(sysno).data = features(:,sysno);
    obj.disp(sysno).func = @plot;
    
    obj.disp(sysno).ylabel = [thissys ' [amp.]'];
    obj.disp(sysno).datasize = datasize;
    obj.disp(sysno).sfreq = DataStruct.SampleRate;
    obj.disp(sysno).xvisible = obj.disp(sysno).sfreq*40;
end; % for sysno

obj.maxLabelNum = size(Repository.Classlist,2);
obj.labelstrings = Repository.Classlist;
obj.title = sprintf('WAV Part: %3u, Subject: %s', Partindex, repos_getfield(Repository, Partindex, 'Subject'));

fprintf('\n%s: Launching Marker...', mfilename);
marker(obj, initlabels);

