% function featurematrix = makefeatures_fusion(Range, DataStruct, varargin)
function featurematrix = makefeatures_fusion(Range, DataStruct, job, varargin)

% function featurematrix = makefeatures_fusion(Range, DataStruct, varargin)
%
% Create a feature level fusion using several DataStructs. Range is at
% BaseRate resolution, NOT at resolution of data (SampleRate). The
% adaptation is performed here. This permits streams with different
% resolutions (SampleRate) in one call to this function.
%
% WARNING: Uses resample(), requires time-continuous features
%
% See also: makefeatures, makefeatures_segment
%
% Copyright 2006-2008 Oliver Amft

featurematrix = [];
%BaseRate = DataStruct(1).BaseRate; %DataStruct(1).SampleRate;

for obs = 1:size(Range,1)
    thisrange = Range(obs,:);

    obsmatrix = [];
    for stream = 1:length(DataStruct)
        %range_r = ceil(thisrange .* DataStruct(stream).SampleRate/SampleRate);
        range_r = segment_resample(thisrange, DataStruct(stream).BaseRate, DataStruct(stream).SampleRate);
        
%         thisfeatures = makefeatures(range_r, DataStruct(stream), varargin{:});
        thisfeatures = makefeatures(range_r, DataStruct(stream), job, varargin{:});


        % SampleRate is in DataStruct and used in makefeatures() to adjust
        % "s-*" feature processing to achieve the same feature resolution.
        %     [p, q] = rat(SampleRate/DataStruct(stream).SampleRate);
        %     featurematrix = [featurematrix resample(thisfeatures, p, q)];

        % need to adapt for different sliding window configurations
        % When multiple streams are used and computed features have
        % different length ?? this will adapt to the shortest of all
        % streams read.
        if (stream > 1)
            if ~iscell(thisfeatures)
                smin = min([size(obsmatrix,1)  size(thisfeatures,1)]);
                sdiff = abs(size(obsmatrix,1)-size(thisfeatures,1));
                if (sdiff > max([DataStruct(stream).swsize DataStruct(stream).swstep]))
                    fprintf('\n%s: Warning: Large sample difference detected: stream %u (diff: %u)', mfilename, stream, sdiff);
                end;

                % OAM REVISIT: Trigger this situation again and analyse it!
                if (sdiff)
                    fprintf('\n%s: OAM REVISIT: Analyse this situation: stream %u (diff: %u)', mfilename, stream, sdiff);
                end;
                obsmatrix = [obsmatrix(1:smin,:) thisfeatures(1:smin,:)];
            else
                obsmatrix = [ obsmatrix thisfeatures ];
            end;
        else
            obsmatrix = thisfeatures;
        end;
    end;

    % Code can be used to extract time-continuous features OR n-value
    % for continuous features, vectors are appended
    featurematrix = [featurematrix; obsmatrix];
end;