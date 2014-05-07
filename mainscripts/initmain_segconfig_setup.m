% initmain_segconfig_setup
%
% Prepare segconfig struct
% 
% Used by: main_seg, main_labelsizehist
% See also: initmain_segconfig

if ~isfield(SegConfig, 'Name'), SegConfig.Name = 'FIX'; end;
if ~isfield(SegConfig, 'Mode'), SegConfig.Mode = ''; end;
fprintf('\n%s: Segmentation type: %s, mode: %s', mfilename, SegConfig.Name, SegConfig.Mode);

switch upper(SegConfig.Name)
    case 'FIX1', SegConfig.Window = 1; % sec
    case 'FIX2', SegConfig.Window = 1/2; % sec
    case 'FIX4', SegConfig.Window = 1/4; % sec
    case 'FIX8', SegConfig.Window = 1/8; % sec

    case 'FIX'
        % FIX segmentation
        if (~isfield(SegConfig, 'Window')),
            SegConfig.Window = 1/8;
            warning('MATLAB:main_seg', 'Field SegConfig.Window not configured!');
            fprintf('\n%s: SegConfig.Window = %.2f', mfilename, SegConfig.Window);
        end; % seconds

    case 'SWAB'
        % SWAB segmentation
        if (~isfield(SegConfig, 'Maxbuffer')), SegConfig.Maxbuffer = 500; end;
        if (~isfield(SegConfig, 'SWABConfig'))
            fprintf('\n%s: SWAB not configured.', mfilename);
            SegConfig = rmfield(SegConfig, 'SWABConfig');
            SegConfig.SWABConfig(1).method = 'LR_SS';    SegConfig.SWABConfig(1).maxcost = 50;     % 1st level
            SegConfig.SWABConfig(2).method = 'SIM_RSLP'; SegConfig.SWABConfig(2).maxcost = 0.1;   % 2nd level
        end;
        for m = 1:length(SegConfig.SWABConfig)
            fprintf('\n%s:   SWAB: method: %s, maxcost: %2.4f, buffer: %u', ...
                mfilename, SegConfig.SWABConfig(m).method, SegConfig.SWABConfig(m).maxcost, SegConfig.Maxbuffer);
        end;

    case 'PAA'
        error('To be implemented.');
    case 'SAX'
        error('To be implemented.');
    otherwise
        error('SegConfig.Name %s not understood.', SegConfig.Name);
end;
