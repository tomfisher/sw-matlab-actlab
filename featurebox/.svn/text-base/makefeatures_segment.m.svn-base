function [fmatrix seglistnew] = makefeatures_segment(seglist, obswindow, getFeatureProc, DataStruct, verbose)
% function [fmatrix seglistnew] = makefeatures_segment(seglist, obswindow, getFeatureProc, DataStruct, verbose)
% 
% Feature processing using (variable) search depth
% 
% requires:
% obswindow         Upper and lower bound of segments to search 
% getFeatureProc    Feature computation method, return: [obs x feat]
% seglist           Segment list
% DataStruct        Data, whatever is needed to compute features
% 
% FeatureVector for multi-value features:
%   [feature1t0, feature2t0, ...
%    feature1t1, feature2t1, ...
%    ...]
% 
% See also: makefeatures, makefeatures_fusion
% 
% Copyright 2006-2008 Oliver Amft

if ~exist('verbose','var'), verbose = 1; end;

progress = 0.1;
obs_min = obswindow(1); % e.g.  obswindow = [2 4]
obs_max = obswindow(2);

% min winow size, obs windows below this size will ignored and features set to Inf
minwinsize = 3;  % <= used below for checking!
if isfield(DataStruct, 'swsize') && (length(DataStruct)==1) % this is a hack, move it to makefeatures_fusion
    % DSSet sizes are for DataStruct.SampleRate, need to adapt for DataStruct.BaseRate
	% max 4 feature slices assumed
    minwinsize = 4* ceil(DataStruct.swsize * DataStruct.BaseRate/DataStruct.SampleRate); 
end;
if isfield(DataStruct, 'minwinsize') && (length(DataStruct)==1)
	minwinsize = ceil(DataStruct.minwinsize * DataStruct.BaseRate/DataStruct.SampleRate);
end;

% probe featureproc and obtain feature size
probefeatures = getFeatureProc([ seglist(1,1) seglist(obs_min,2) ], DataStruct);


% sweep through dataset using obs_min, obs_max as feature search bounds 
fmatrix = []; seglistnew = [];  swinmsg = 0;
for end_pos = obs_min:size(seglist,1)  %obs_max:size(seglist,1)
    if (verbose>0), progress = print_progress(progress, end_pos/size(seglist,1), 0.1); end;
    
    fmatrix_sect = []; seglist_sect = [];
    for beg_pos = (end_pos - obs_min +1) : -1 : (end_pos - obs_max +1)
		if (beg_pos <= 0)
			% not a valid range - it is filled to support search code that does not check data boundaries  
			fmatrix_sect = [fmatrix_sect; probefeatures];
			seglist_sect = [seglist_sect; 1 0];
			continue;
		end;
		
        window = [seglist(beg_pos,1) seglist(end_pos,2)];

        if (segment_size(window) >= minwinsize) 
            fmatrix_sect = [fmatrix_sect; getFeatureProc(window, DataStruct)];

        else
            if (~swinmsg) 
                fprintf('\n%s: Search window too small at pos: %u, win=%u, minwin=%u.', ...
                    mfilename, end_pos, segment_size(window), minwinsize); 
                fprintf('\n%s: Processing result was set to Inf.', mfilename);
                fprintf('\n%s: Further report of this issue is reduced.', mfilename); 
                swinmsg = 500;
			else
				swinmsg = swinmsg -1;
            end;

            % create dummy matrix
            fmatrix_sect = [fmatrix_sect; repmat(Inf, size(probefeatures))];
        end;
        
        seglist_sect = [seglist_sect; window];
    end; % for beg_pos

    seglistnew = [seglistnew; seglist_sect];
    fmatrix = [fmatrix; fmatrix_sect];
end; % for end_pos
