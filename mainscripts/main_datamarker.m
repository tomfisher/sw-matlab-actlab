% main_datamarker
%
% Run Marker with data from workspace.
% See also main_reposmarker.m
%
% requires:
features;
initlabels;
% sfreq;



initdata;
if (~iscell(features)) features = {features}; end;
if (exist('sfreq', 'var')~=1) sfreq = 100; end;

% setup marker obj
clear obj;
for sysno = 1:length(features)
    thissys  = '???';
    
    obj.disp(sysno).type = thissys;
    obj.disp(sysno).data = features{sysno};
    obj.disp(sysno).func = @plot;
    
    obj.disp(sysno).ylabel = [thissys ' [amp.]'];
    obj.disp(sysno).datasize = size(obj.disp(sysno).data,1);
    obj.disp(sysno).sfreq = sfreq;
    obj.disp(sysno).xvisible = obj.disp(sysno).sfreq*40;
end; % for sysno

obj.title = sprintf('Feature data at %uHz, size: %usa', sfreq, size(obj.disp(1).data,1));

fprintf('\n%s: Launching Marker...', mfilename);
marker(obj, initlabels);

