function seglist = segment_evalthreshold(Evaldata, Thresholdlist, verbose)
% function seglist = segment_evalthreshold(Evaldata, Thresholdlist, verbose)
%
% Apply a threshold to Evaldata, return the segments above the treshold in
% a cell list according to Thresholdlist. Return seglist vector if 
% Thresholdlist has one element only.

if (exist('verbose')~=1) verbose = 0; end;

progress = 0.2;
for thresidx = 1:length(Thresholdlist)
    if (verbose)  progress = print_progress(progress, thresidx/length(Thresholdlist), 0.2); end;
    
    activation_threshold = Thresholdlist(thresidx);
    
    % process signal segmentation
    labels_EVAL = zeros(size(Evaldata,1), 1);
    labels_EVAL(find(Evaldata > activation_threshold)) = 1;
    
    seglist{thresidx} = labeling2segments(labels_EVAL);
end; % for i

% de-cell if not needed
if (length(Thresholdlist) == 1)
    seglist = seglist{1};
end;