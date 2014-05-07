function z_stat = feature_detrending(z, varargin)
%function z_stat = feature_detrending(z, varargin)
%
%
% Implementation according based on the paper by Mika P. Tarvainen et al.
% "An advanced detrending method with applications to HRV analysis", 2002

[model lambda] = process_options(varargin, ...
    'model', 'eye', ...
    'lambda', 7300); 
% cut-off 0.04Hz at 8Hz: lambda = 1600
% cut-off 0.039Hz at 16Hz: lambda = 7300

T = length(z);

switch(lower(model))
    case { 'eye' }
        
        I = speye(T);
        D2 = spdiags(ones(T-2,1)*[1 -2 1], 0:2, T-2,T);
        z_stat = (I-inv(I+lambda^2*D2'*D2))*z(:);
        
    case { 'gaussian' }        
        ...
        
    case { 'sigmoid' }
        ...
            
    case { 'linear', 'constant' }
        % Use the build-in MATLAB detrend method
        z_stat = detrend(z, lower(model));
                
    otherwise
        error('Unknown detrending model');
end;

% % Polynomial detrending??
% times = ??;
% z_stat = z - polyval(polyfit(times, z, polyorder), times);


% End of file