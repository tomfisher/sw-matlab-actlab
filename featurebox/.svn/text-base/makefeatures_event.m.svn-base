function featurematrix = makefeatures_event(Range, DataStruct)
% function featurematrix = makefeatures_event(Range, DataStruct)
% 
% 
% See also: makefeatures_fusion.m

featurematrix = [];
eventsflag = true;
    
for obs = 1:size(Range,1)
    thisrange = Range(obs,:);
    
    obsmatrix = [];
    for stream = 1:length(DataStruct)
        range_r = segment_resample(thisrange, DataStruct(stream).BaseRate, DataStruct(stream).SampleRate);
        
        % convert from labelings (time domain) to indices in segment lists (symbol domain)
        % segments may not be aligned to range_r if spotters have used different labeling
%         range_oh = segments2labeling(range_r, DataStruct(stream).totalsize);
%         tmp = range_oh & DataStruct(stream).sections_oh;

        % convert to symbol domain
        % OAM REVISIT: should include overlapping ones as well 
        %                             (when spotters with independent segmentation are considered)
        tmp = segment_markincluded(range_r, DataStruct(stream).Data);
        if sum(tmp)
            % determine bound indices in symbol domain
            tmpsec(1) = find(tmp,1,'first');            tmpsec(2) = find(tmp,1,'last');  % somewhat faster than labeling2segments.m
%             tmpsec(1) = find(DataStruct(stream).Data(:,1)==tmpsec(1),1, 'first');
%             tmpsec(2) = find(DataStruct(stream).Data(:,2)==tmpsec(2),1, 'last');
%             thisfeatures = { DataStruct(stream).Data(tmp,4) };
            thisfeatures = makefeatures(tmpsec, DataStruct(stream));
        else
            if eventsflag
                fprintf('\n%s: WARNING: No events at range %s, stream %u (%s).', mfilename, ...
                    mat2str(Range), stream, DataStruct(stream).Name);
            end;
%             eventsflag = false;
            thisfeatures = {[]};
        end;
%         range_rs = round(range_r * DataStruct(stream).basesecsize/DataStruct(stream).secsize);
%         thisfeatures = makefeatures(range_rs, DataStruct(stream));

        obsmatrix = [ obsmatrix thisfeatures ];
    end;

    featurematrix = [featurematrix; obsmatrix];
end;