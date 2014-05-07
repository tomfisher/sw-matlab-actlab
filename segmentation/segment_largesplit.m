function newseglist = segment_largesplit(allseglist, varargin)
% function newseglist = segment_largesplit(allseglist, varargin)
%
% Filter segment list, split segments above threshold given by 1st segment
%
% Parameters:
% ThresFactor       Length threshold (value * first segment)
% SplitClasses      Classes to split, rest is returned unmodified


newseglist = [];

isfullseglist = (size(allseglist,2)>=6);

[ThresFactor FirstIsRef SplitClasses SetTentative verbose] = process_options(varargin, ...
    'ThresFactor', 2, 'FirstIsRef', true, 'SplitClasses', [], 'SetTentative', true, 'verbose', 1);

if isempty(allseglist) return; end;
if (verbose) fprintf('\n%s: SetTentative: %s', mfilename, mat2str(SetTentative)); end;

if (isfullseglist)
    % allseglist contains labels
    classes = row(unique(allseglist(:,4)));
else
    classes = 1;
end;

for class = classes
    classseglist = segment_findlabelsforclass(allseglist, class);
    if isempty(classseglist) continue; end;

    if isempty(find(SplitClasses == class))
        % apply filter to specfied classes only!
        newseglist = [newseglist; classseglist];
        continue;
    end;

    % class requires splitting
    if (verbose) fprintf('\n%s: Filtering large segments: class %u', mfilename, class); end;

    % find initial length threshold
    thissegsize = segment_size(classseglist);
    if (FirstIsRef)
        seglen = thissegsize(1); % use 1st
    else
        seglen = 1;
    end;
    
    % thisseg_ok: ok, no splitting; thisseg_nok: Not ok, requires splitting
    thisseg_ok = find(thissegsize <= seglen*ThresFactor);
    thisseg_nok = row(find(thissegsize > seglen*ThresFactor));

    seglen = mean(segment_size(classseglist(thisseg_ok,:)));
    if (verbose>1)
        fprintf('\n%s: Segment sizes: 1st: %u, mean: %.1f', mfilename, thissegsize(1), seglen);
        fprintf('\n%s: Filter segments: min: %u, max: %u', mfilename, ...
            min(thissegsize(thisseg_nok)), max(thissegsize(thisseg_nok)));
    end;
    if (seglen == 0)
        seglen = ThresFactor;
        fprintf('\n%s: WARNING: Not found appropriate segment size, assuming: %u', mfilename, seglen);
    end;

    newseglist = [newseglist; classseglist(thisseg_ok,:)]; % copy good ones

    % scan through rest (thisseg_nok)
    sumnewsegs = 0;
    for seg = thisseg_nok
        thissegsize = segment_size(classseglist(seg,:));
        thisnewseg = segment_createsplit(thissegsize, round(thissegsize/seglen), []);
        thiscount = size(thisnewseg,1);

        if (isfullseglist)
            segclass = classseglist(seg,4); segconf = classseglist(seg,6);
            if (SetTentative) segconf = 0; end;
            
            newseglist = [newseglist; ...
                segment_createlist([thisnewseg+classseglist(seg,1)-1], 'classlist', segclass, 'conflist', segconf) ];
            
%                 [thisnewseg+classseglist(seg,1)-1 segment_size(thisnewseg) ...
%                 repmat(classseglist(seg,4:end),thiscount,1) ] ];
        else
            newseglist = [newseglist; thisnewseg+classseglist(seg,1)-1];
        end;

        sumnewsegs = sumnewsegs + thiscount;
    end; % for seg

    if (verbose>1)
        fprintf('\n%s: Class %u: Converted %u segments to %u.', mfilename, class, length(thisseg_nok), sumnewsegs);
        fprintf('\n%s: Class %u: Max segment size after conv.: %u', ...
            mfilename, class, max(segment_size(segment_findlabelsforclass(newseglist,class))));
        if (isfullseglist)&&(SetTentative) 
            fprintf('\n%s: Class %u: Total tentatives: %u', mfilename, class, length(find(newseglist(:,6)<1)));
        end;
        fprintf('\n%s: Class %u: Total segments: %u', ...
            mfilename, class, length(segment_findlabelsforclass(newseglist,class)));
        
    end;
end; % for class

% sort according to segment end
newseglist = segment_sort(newseglist,2);


