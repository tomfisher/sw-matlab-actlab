function featurematrix = cla_makesectionfeatures(SeqList, FeatureString, varargin)
% function featurematrix = cla_makesectionfeatures(SeqList, FeatureString, varargin)
%
% Computes features from events or labels in cell array (featurematrix is
% m-by-n sized, where m=length(SeqList) and n=length(FeatureString).
%
% SeqList - cell array of label lists
% FeatureString - features...
% 
% Copyright 2008 Oliver Amft

featurematrix = [];
featurecounts = zeros(1,length(FeatureString));

if isemptycell(SeqList), error('Empty sequence detected: %s', mat2str(find(isemptycell(SeqList)>0))); end;

[Repository, Partindex, DSSet, SigFeatureString, verbose] = process_options(varargin, ...
	'Repository', [], 'Partindex', [], 'DSSet', [], 'SigFeatureString', {}, 'verbose', 0);

for featureNr = 1:length(FeatureString)

    % data selection: Token 1 identifies channel and sensor feature;
    % tokens 2 and beyond specify computation feature
    tokens = fb_getelements(FeatureString{featureNr});
    if isempty(tokens)
        error('\n%s: FeatureString not understood at pos. %u', mfilename, feature);
    end;
    featurestr = tokens(1:end);

    thisfeature = SeqList;

    for inst = 1:max(size(featurestr))
        sdata = thisfeature;  % if more that one iteration is needed

        switch featurestr{inst}  % tokens 2 and greater only
			
			case 'Lidvote'  % majority vote on label id
                thisfeature = nan(length(sdata),1);
                for seq = 1:length(sdata)
                    if size(sdata{seq},1)<1,  continue; end;
					if size(sdata{seq},2)<4, error('Could not find ID information.'); end;

					% determine highest occurance
					[ids h] = countele(sdata{seq}(:,4));
					[dummy hidx] = max(h);
					thisfeature(seq) = ids(hidx);
                end;
				
			case {'Lconfvote', 'Ldistvote'}  % weight confidences/distances using nr of occurances, select highest/lowest
                thisfeature = nan(length(sdata),1);
                for seq = 1:length(sdata)
                    if size(sdata{seq},1)<1,  continue; end;
					if size(sdata{seq},2)<6, error('Could not find confidence/distance information.'); end;

					% determine highest confidence
					ids = unique(sdata{seq}(:,4));
					conf = zeros(1, length(ids));
					for idnr = 1:length(ids)
						conf(idnr) = mean(sdata{seq}(sdata{seq}(:,4)==ids(idnr), 6));
					end;
					if strcmpi(featurestr{inst}, 'Ldistvote')
						[dummy hidx] = min(conf);
					else
						[dummy hidx] = max(conf);
					end;
					thisfeature(seq) = ids(hidx);
                end;

				
				
			
            case 'Lcount' % nr of labels
                thisfeature = col(cellfun('size', sdata,1));

            case 'Ltlength' % total length
                thisfeature = zeros(length(sdata),1);
                for seq = 1:length(sdata)
                    if size(sdata{seq},1)<1,  continue; end;
                    thisfeature(seq) = sdata{seq}(end,2)-sdata{seq}(1,1)+1;
                end;

            case 'Lmlength' % mean event length
                thisfeature = zeros(length(sdata),1);
                for seq = 1:length(sdata)
                    thisfeature(seq) = mean(segment_size(sdata{seq}));
                end;
            case 'Lslength' % std of event length
                thisfeature = zeros(length(sdata),1);
                for seq = 1:length(sdata)
                    thisfeature(seq) = std(segment_size(sdata{seq}));
                end;
            case 'Lvlength' % var of event length
                thisfeature = zeros(length(sdata),1);
                for seq = 1:length(sdata)
                    thisfeature(seq) = var(segment_size(sdata{seq}));
                end;
            case 'Llenslope' % trend in event length
                thisfeature = zeros(length(sdata),1);
                for seq = 1:length(sdata)
					if size(sdata{seq},1)<2, continue; end;
					x = segment_size(sdata{seq});
					coef = polyfit(col(1:length(x)), x, 1);  % fit lin model, eqv. to [ones(length(x),1) col(1:length(x))] \ x
                    thisfeature(seq) = coef(1); % slope
                end;

            case 'Ltgap'  % total distance btw labels
                thisfeature = zeros(length(sdata),1);
                for seq = 1:length(sdata)
                    if size(sdata{seq},1)<2, continue; end;
					gaplist = segment_findgaps(sdata{seq}, 'maxsize', sdata{seq}(end,2));
					thisfeature(seq) = sum( segment_size( gaplist(2:end,:) ) );
                end;
            case 'Lmgap'  % mean distance btw labels
                thisfeature = zeros(length(sdata),1);
                for seq = 1:length(sdata)
					if size(sdata{seq},1)<2, continue; end;
					gaplist = segment_findgaps(sdata{seq}, 'maxsize', sdata{seq}(end,2));
					thisfeature(seq) = mean( segment_size( gaplist(2:end,:) ) );
                end;
            case 'Lsgap'  % std of distance btw labels
                thisfeature = zeros(length(sdata),1);
                for seq = 1:length(sdata)
					if size(sdata{seq},1)<2, continue; end;
					gaplist = segment_findgaps(sdata{seq}, 'maxsize', sdata{seq}(end,2));
					thisfeature(seq) = std( segment_size( gaplist(2:end,:) ) );
                end;
            case 'Lvgap'  % var of distance btw labels
                thisfeature = zeros(length(sdata),1);
                for seq = 1:length(sdata)
					if size(sdata{seq},1)<2, continue; end;
					gaplist = segment_findgaps(sdata{seq}, 'maxsize', sdata{seq}(end,2));
					thisfeature(seq) = var( segment_size( gaplist(2:end,:) ) );
                end;


            case 'Lspeed'  % nr of labels, normalised by sequence length
                thisfeature =  zeros(length(sdata),1);
                for seq = 1:length(sdata)
					if isempty(sdata{seq}), continue; end;
					counts = size(sdata{seq},1);
					lengths = sdata{seq}(end,2)-sdata{seq}(1,1)+1;
					thisfeature(seq) = counts / lengths;
                end;
            case 'Lvspeed'  % var of time per event
                thisfeature =  zeros(length(sdata),1);
                for seq = 1:length(sdata)
					if isempty(sdata{seq}), continue; end;
					thisfeature(seq) = var( 1 / segment_size(sdata{seq}) );
                end;
            case 'Lspeedslope'  % trend in time per event
                thisfeature =  zeros(length(sdata),1);
                for seq = 1:length(sdata)
					if size(sdata{seq},1)<2, continue; end;
					x = 1 ./ segment_size(sdata{seq});
					coef = polyfit(col(1:length(x)), x, 1);  % fit lin model, eqv. to [ones(length(x),1) col(1:length(x))] \ x
                    thisfeature(seq) = coef(1); % slope					
                end;

				
			case 'Lsigenergy' % signal energy (uses makefeatures)
				thisfeature = zeros(length(sdata),1);
				if ~exist('DataStruct', 'var')
					% create once, when PIs are processed individually
					DataStruct = makedatastruct(Repository, Partindex, SigFeatureString, DSSet);
				end;
                for seq = 1:length(sdata)
					if isempty(sdata{seq}), continue; end;
					% average features for labels in each sequence
					% max of feature columns (hack for bilateral M masseter eval)
					thisfeature(seq) = max( mean(makefeatures_fusion(sdata{seq}, DataStruct), 1) );
                end;
				
				
				
                % ---------------------------------------------------------
                % ---------------------------------------------------------

			case 'LfirstL'  % keep first label
                thisfeature = cell(length(sdata),1);
                for seq = 1:length(sdata)
					if size(sdata{seq},1) < 1, continue; end;
                    thisfeature{seq} = sdata{seq}(1,:);
                end;
			
			case 'Lfst13L'  % keep first 3 labels
                i = 1;  ss = 3;
                thisfeature = cell(length(sdata),1);
                for seq = 1:length(sdata)
					if size(sdata{seq},1) < ss*(i-1)+1,  continue; end;
					if size(sdata{seq},1) < ss*i,  thisfeature{seq} = sdata{seq}(ss*(i-1)+1:end,:); continue; end;
                    thisfeature{seq} = sdata{seq}(ss*(i-1)+1:ss*i,:);
                end;

			case 'Lfst15L'  % keep first 5 labels
                i = 1;  ss = 5;
                thisfeature = cell(length(sdata),1);
                for seq = 1:length(sdata)
					if size(sdata{seq},1) < ss*(i-1)+1,  continue; end;
					if size(sdata{seq},1) < ss*i,  thisfeature{seq} = sdata{seq}(ss*(i-1)+1:end,:); continue; end;
                    thisfeature{seq} = sdata{seq}(ss*(i-1)+1:ss*i,:);
                end;
			case 'Lfst25L'  % keep second 5 labels
                i = 2;  ss = 5;
                thisfeature = cell(length(sdata),1);
                for seq = 1:length(sdata)
					if size(sdata{seq},1) < ss*(i-1)+1,  continue; end;
					if size(sdata{seq},1) < ss*i,  thisfeature{seq} = sdata{seq}(ss*(i-1)+1:end,:); continue; end;
                    thisfeature{seq} = sdata{seq}(ss*(i-1)+1:ss*i,:);
                end;
			case 'Lfst35L'  % keep third 5 labels
                i = 3;  ss = 5;
                thisfeature = cell(length(sdata),1);
                for seq = 1:length(sdata)
					if size(sdata{seq},1) < ss*(i-1)+1,  continue; end;
					if size(sdata{seq},1) < ss*i,  thisfeature{seq} = sdata{seq}(ss*(i-1)+1:end,:); continue; end;
                    thisfeature{seq} = sdata{seq}(ss*(i-1)+1:ss*i,:);
                end;

			case 'Lsec13L'  % keep first 1/3 of labels
                i = 1;
                thisfeature = cell(length(sdata),1);
                for seq = 1:length(sdata)
                    ss = floor(size(sdata{seq},1) /3);
					if (ss < 1), continue; end;
                    thisfeature{seq} = sdata{seq}(ss*(i-1)+1:ss*i,:);
                end;
            case 'Lsec23L'  % keep mid 1/3 of labels
                i = 2;
                thisfeature = cell(length(sdata),1);
                for seq = 1:length(sdata)
                    ss = floor(size(sdata{seq},1) /3);
					if (ss < 1), continue; end;					
                    thisfeature{seq} = sdata{seq}(ss*(i-1)+1:ss*i,:);
                end;
            case 'Lsec33L'  % keep last 1/3 of labels
                i = 3;
                thisfeature = cell(length(sdata),1);
                for seq = 1:length(sdata)
                    ss = floor(size(sdata{seq},1) /3);
					if (ss < 1), continue; end;					
                    thisfeature{seq} = sdata{seq}(ss*(i-1)+1:ss*i,:);
                end;

            case 'Ltsec13L'  % keep labels in first 1/3 of sequence length
                i = 1;
                thisfeature = cell(length(sdata),1);
                for seq = 1:length(sdata)
                    ss = ceil( (sdata{seq}(end,2)-sdata{seq}(1,1)+1) /3);
                    idx = segment_findincluded( [ss*(i-1)+sdata{seq}(1,1)  ss*i+sdata{seq}(1,1)] , sdata{seq} );
                    thisfeature{seq} = sdata{seq}(idx,:);
                end;
            case 'Ltsec23L'  % keep labels in mid 1/3 of sequence length
                i = 2;
                thisfeature = cell(length(sdata),1);
                for seq = 1:length(sdata)
                    ss = ceil( (sdata{seq}(end,2)-sdata{seq}(1,1)+1) /3);
                    idx = segment_findincluded( [ss*(i-1)+sdata{seq}(1,1)  ss*i+sdata{seq}(1,1)] , sdata{seq} );
                    thisfeature{seq} = sdata{seq}(idx,:);
                end;
            case 'Ltsec33L'  % keep labels in last 1/3 of sequence length
                i = 3;
                thisfeature = cell(length(sdata),1);
                for seq = 1:length(sdata)
                    ss = ceil( (sdata{seq}(end,2)-sdata{seq}(1,1)+1) /3);
                    idx = segment_findincluded( [ss*(i-1)+sdata{seq}(1,1)  ss*i+sdata{seq}(1,1)] , sdata{seq} );
                    thisfeature{seq} = sdata{seq}(idx,:);
                end;


                % ---------------------------------------------------------
                % ---------------------------------------------------------

            case 'diff'  % derivative of feature (does not operate on events
                if iscell(sdata), error('Wrong configuration - does not operate on labels.'); end;
                thisfeature = col([0 row(diff(sdata, [], 1))]);
				
			otherwise
				error('Feature ''%s'' not supported.', featurestr{inst});
        end; % switch
    end; % for inst


    try
        featurematrix = [featurematrix thisfeature];
    catch
        fprintf('\n%s: Feature dimensions do not match.', mfilename);
        fprintf('\n%s:   Current feature: %s', mfilename, FeatureString{featureNr});
        fprintf('\n%s:   featurematrix: %s, thisfeature: %s', mfilename, mat2str(size(featurematrix)), mat2str(size(thisfeature)));
        fprintf('\n%s:   Size of sdata: %s', mfilename, mat2str(size(sdata)));
        error('Stop.');
    end;
    featurecounts(featureNr) = size(thisfeature,2); % remember actual number of features
end; % for featureNr
