function oseglist = segment_window(iseglist, WindowSize, StepSize, proc, varargin)
% function oseglist = segment_window(iseglist, WindowSize, StepSize, proc, varargin)
% 
% Apply function on sliding window of segments referenced by 'yt'.
% 
% Default setting: proc = 'majority(yt(:,4))'
% 
% Copyright 2008 Oliver Amft

if ~exist('WindowSize', 'var') || isempty(WindowSize), WindowSize = round(mean(segment_size(iseglist))); end;
if ~exist('StepSize', 'var') || isempty(StepSize), StepSize = WindowSize; end;
if ~exist('proc', 'var') || isempty(proc), proc = 'majorityconf(yt(:,4), yt(:,6))'; end;  % majority vote is default behaviour

[verbose] = process_options(varargin, ...
    'verbose', 0);

% probing proc
if strcmpi(proc, 'none')
    proberesult = [];
else
    proberesult = segment_window_caller( proc, iseglist(1:WindowSize-1,:) );
end;

% apply sliding window
switch length(proberesult)
    case 0
        oseglist = sswindow( iseglist, WindowSize, StepSize,  'segment_createlist([yt(1,1) yt(end,2)]);' );
    case 1
        oseglist = sswindow( iseglist, WindowSize, StepSize, ...
            ['segment_createlist([yt(1,1) yt(end,2)], ''classlist'', ' proc ');'] );
    case 2
        oseglist = sswindow( iseglist, WindowSize, StepSize, ...
            ['segment_createlist([yt(1,1) yt(end,2)], ''classconflist'', ' proc ');'] );
    otherwise
        error('There is something wrong with this proc function: %s', proc);
end;


% for startpoint = 1 : StepSize : size(iseglist,1)
%     if (startpoint+WindowSize-1) <= size(iseglist,1)  % not the last window
%         endpoint = startpoint+WindowSize-1;
%         yt = iseglist(startpoint:endpoint,:);
%         
%         thisresult = segment_window_caller(proc, yt);
%         if length(thisresult)<2, thisresult(2) = 1; end;
%         oseglist((startpoint-1)/StepSize+1,:) = segment_createlist( [iseglist(startpoint,1), iseglist(endpoint,2)], ...
%             'classlist', thisresult(1), 'conflist', thisresult(2) );
%         
%     else  % last window
%         endpoint = size(iseglist,1);
%         yt = iseglist(startpoint:endpoint,:);
%         
%     end;
% 
% 
% end;

function r = segment_window_caller(proc, yt)
% proc is a string. This is done to allow Matlab parsing the call
r = eval(proc);
if size(r,2) == 1, r = r'; end;
