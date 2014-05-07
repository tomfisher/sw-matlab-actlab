function [data sps] = xsens_getdata(Repository, Partindex, varargin)
% function [data sps] = xsens_getdata(Repository, Partindex, varargin)
%
% read in data from win XSens software
%
% SensorList:   Cell array of serial string of each sensor
%               e.g. {'00007224', '00007083', '0000721D'}
%
% Order of features: acc, gyr, mag, r1, r2, r3, eul   x3 each

% subsitute this section to isolate the code from Repos framework
dir = repos_getfield(Repository, Partindex, 'Dir', 'XSENS');
RepPath = fullfile(Repository.Path, dir, '');
SensorList = repos_getfield(Repository, Partindex, 'Sensors', 'XSENS');
FileID = repos_getfield(Repository, Partindex, 'File', 'XSENS');

% this is a hack to keep compatible with old MT9 recordings
OldRepFileCal = 'MT9_cal_'; OldRepFileMatrix = 'MT9_matrix_';

[RepFileCal RepFileMatrix RepFileExt Range CalFileColumns RotFileColumns verbose] = process_options(varargin, ...
    'RepFileCal', 'MT_cal_', 'RepFileMatrix', 'MT_matrix_', 'RepFileExt', '.log', ...
    'Range', [1 inf], 'CalFileColumns', 10, 'RotFileColumns', 10, 'verbose', 0);

% % determine end of data (rows) when not specified
% % dlmread() needs exact numbers
% for sensor = 1:length(SensorList)
%     filename = fullfile(RepPath, [RepFileCal SensorList{sensor} FileID RepFileExt]);
%     if (~exist(filename)) filename = fullfile(RepPath, [OldRepFileCal SensorList{sensor} FileID RepFileExt]); end;
%     fprintf('\nFile %s: %u', SensorList{sensor}, wcl(filename)-1);
%     
%     filename = fullfile(RepPath, [RepFileMatrix SensorList{sensor} FileID RepFileExt]);
%     if (~exist(filename)) filename = fullfile(RepPath, [OldRepFileMatrix SensorList{sensor} FileID RepFileExt]); end;
%     fprintf(' %u', wcl(filename));
% end;

% loop for all sensors per segment
data = [];
for sensor = 1:length(SensorList)
    if (verbose>1), fprintf('\n%s: Reading sensor %s from %s (%s)...', mfilename, SensorList{sensor}, RepPath); end;

    % calibrated
    filename = fullfile(RepPath, [RepFileCal SensorList{sensor} FileID RepFileExt]);
    if (~exist(filename,'file')) 
        % compatibility with old MT9 files
        filename = fullfile(RepPath, [OldRepFileCal SensorList{sensor} FileID RepFileExt]); 
        CalFileColumns = 11;
    end;
    %tmpdata_cal = xsens_readfile(filename, 9+1, Range(1), Range(2));
    %tmpdata_cal = dlmread(filename, '', [Range(1), 0, Range(2), 1+9-1]);
    tmpdata_cal = readtextfilecols(filename, [1 CalFileColumns], Range);

    % rotation
    filename = fullfile(RepPath, [RepFileMatrix SensorList{sensor} FileID RepFileExt]);
    if (~exist(filename,'file')), filename = fullfile(RepPath, [OldRepFileMatrix SensorList{sensor} FileID RepFileExt]); end;
    %tmpdata_rot = xsens_readfile(filename, 9+1, Range(1), Range(2));
    %tmpdata_rot = dlmread(filename, '', [Range(1), 0, Range(2), 1+9-1]); 
    tmpdata_rot = readtextfilecols(filename, [1 RotFileColumns], Range);    
    
    % compensate for less/more data
    if (sensor == 1)
        rows = [size(tmpdata_cal,1) size(tmpdata_rot,1)];
    else
        rows = [size(data,1) size(tmpdata_cal,1) size(tmpdata_rot,1)];
    end;
    if (max(rows) - min(rows)) > 50
        warning('MATLAB:xsens_getdata', 'Size differences are high! Possibly sensor out of sync.');
    end;
    
    adaptrows = min(rows);
    if (sensor == 1)
        data = [tmpdata_cal(1:adaptrows,2:1+9) tmpdata_rot(1:adaptrows,2:1+9)];
    else
        data = [data(1:adaptrows,:) tmpdata_cal(1:adaptrows,2:1+9) tmpdata_rot(1:adaptrows,2:1+9)];
    end;

    if (min(rows) ~= max(rows))
        fprintf('\n%s: Size difference %s corrected.', mfilename, mat2str(rows));
    end;

    % process euler angles
    data = [data rot2eul(tmpdata_rot(1:adaptrows,2:1+9))];
end; % sensor

% determine sampling rate (all sensors have same rate)
sps = 1/(tmpdata_rot(2,1)-tmpdata_rot(1,1));
