function [result startpoint] = swindow(signal, WindowSize, StepSize, fhandle, varargin)
% function [result startpoint] = swindow(signal, WindowSize, StepSize, fhandle, varargin)
%
% This function calls the function fhandle
% of a given vector using a sliding window of size WindowSize.
%
% warning('Obsolete: Consider using sswindow() instead.');
% 
% See also: sswindow
% 
% Copyright 2005 Oliver Amft

[config_mode, config_params] = process_options(varargin, 'mode', 'exit', 'params', []);

% if (exist('mode')~=1) mode = 'exit'; end;

result = [];

if (size(signal,1) < WindowSize)
    fprintf('\n%s: Signal vector is smaller than window.', mfilename);    
    result = [];
    return;
end;

% for startpoint = 1 : StepSize : size(signal,1)-WindowSize+1
for startpoint = 1 : StepSize : size(signal,1)
    if (startpoint+WindowSize-1) <= size(signal,1)
        endpoint = startpoint+WindowSize-1;
    else
        endpoint = size(signal,1);
    end;
    yt = signal(startpoint:endpoint,:);
    
    if (size(yt,1) == WindowSize)
        %         result = [result; feval(fhandle, yt)];
        result = [result; swindow_caller(fhandle, yt, config_params)];
    else
        switch(lower(config_mode))
            case {'pad', 'padzero'}
                % Padding non-aligned data
                result = [result; repmat(0, size(yt,2), 1)];
            case {'exit', 'floor'}
                % Terminiate processing here
                break;
            case {'cont', 'continue', 'ceil'}
                % Continue with smaller windows
                if (size(yt,1) >= 1)
                    %                     result = [result; feval(fhandle, yt)];
                    result = [result; swindow_caller(fhandle, yt, config_params)];
                    %                 else
                    %                     result = [result; yt];
                end;
            otherwise
                error([mfilename ': Mode ' lower(config_mode) ' not understood!']);
        end;
    end;

end; % for startpoint


function result = swindow_caller(fhandle, yt, params)
if isempty(params)
    result = eval('fhandle(yt)');
else
    result = eval(['fhandle(yt,' params ')']);
end;

