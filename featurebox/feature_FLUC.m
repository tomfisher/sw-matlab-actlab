function thisfeature = feature_FLUC(rdata)
% function thisfeature = feature_FLUC(rdata)
%
% Signal amplitude fluctuation
% 'data' should be rms-normalised.
% 
% Copyright 2006 Oliver Amft

% [proc_fft proc_norm] = process_options(varargin, ...
%     'fft', [], 'norm', 'feature_rms');
% 
% if isempty(proc_norm)
%     rdata = sdata;
% else
%     rdata = eval([proc_norm '(sdata)']);
% end;
% 
% if ~isempty(proc_fft)
%     rdata = eval([proc_fft '(rdata)']);
% end;

if (round(std(rdata)) == 0)
    thisfeature = 0;
else
    thisfeature = mean(rdata,1)/std(rdata,[],1);
end;