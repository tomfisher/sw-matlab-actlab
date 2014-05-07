function thisfeature = feature_CWT(rdata, scales, varargin)
%[EXPERIMENTAL] function thisfeature = feature_CWT(rdata, scales, varargin)
%
% 
%

% Process variable input arguments
[wname fname] = process_options(varargin, 'wname', 'gaus4', 'fname', 'energy');

C = cwt(rdata, scales, wname);
%C = cwt(rdata, scales, wname, 'scal');
%C = cwt(rdata, scales, wname, 'scalCNT');
%C = cwt(rdata, scales, wname, '3Dplot');
%C = cwt(rdata, scales, wname, '3Dlvl');


switch (lower(fname))

    % rms = norm(x) / sqrt(length(x))
    case { 'rms' }
        thisfeature = sqrt( sum(C.^2,2) / size(C,2));
        
    case { 'energy' }
        thisfeature = sum(C.^2,2);
        
    case { 'maxscale' }
         [notused thisfeature] = max(C,[],1);         
        
    otherwise;        
end;