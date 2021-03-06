function [FeatureMatrix RetFeatureString] = makefeatures(Range, DataStruct, varargin)
% function [FeatureMatrix RetFeatureString] = makefeatures(Range, DataStruct, varargin)
%
% DataStruct        see createdatastruct() for details
% Range             observation window
%
% DataStruct:
%   seglist         Segmentation points (needed for SEG_SWAB_SEGS only)
%   Data            Data itself - expected to be matrix one channels per row
%   DTable          channel association table, e.g.: {LLAPHI_MEAN, ...}
%   FeatureString   Feature string
%
% return:
% FeatureMatrix for single-value features:
%   [feature1 feature2 feature_3 ...]
%
% FeatureMatrix for multi-value features:
%   [feature1t0, feature2t0, ...
%    feature1t1, feature2t1, ...
%    ...]
%
% See also: makefeatures_fusion, makefeatures_segment
% 
% Copyright 2006-2011 Oliver Amft
% 
% Contributions by: 
% Marcel Scheurer, Ingo Jenni, Reto Pieren, Martin Kusserow
% 
% changelog:
% 2007/06/21: Corrected some major bugs in 'diff', 'SUM', 'POSSUM', 'NEGSUM'
% 2009/01/30: Contributions on HRV and wavelet features from Martin Kusserow
% 2009/02/06: Added fractal dimension feature (mk)
% 2009/02/13: Changed param config_dwtscales to config_dwtlevels, empty value by default (mk)
% 2009/02/13: Changed param config_dwtlevels default value to [1 2 3 4] (mk)
% 2011/06/28: Added nanmean, nanvar (oamft)
% 2011/09/26: Added nan2intp, nan2zero and NaN checking (oamft)


% Todo:
% * add nan's filter
% * LPCC
% * wavelet features => Kai, ...
% * histowidth => DA Soundbutton
% * formant frequency
% * fundamental frequency, Doval1994, Doval and Rodet 1993
% * spectral entropy
% * MPEG7
% * ERB filter
% * rasta
% * synlpc/proclpc
% gart ?? toolbox
% 
% A.A. Livshin and X. Rodet. “Musical Instrument Identification
% in Continuous Recordings, in Proc. of the 7th Int. Conference on
% Digital Audio Effects, Naples, Italy, October 5-8, 2004.
% 
%
% commands to analyse a pice of data:
% 
% DataStruct = makedatastruct(Repository, 32, {'BLIGHTaccx_value', 'BLIGHTaccy_value', 'BLIGHTaccz_value'}, DSSet)
% int2str(makefeatures([5100 5200], DataStruct))
% strvcat(DataStruct.FeatureString)
% plot(makefeatures([5600 5740], DataStruct), 'linewidth', 2)


FeatureString = DataStruct.FeatureString;
SampleRate = DataStruct.SampleRate;

if (~isfield(DataStruct, 'swsize')) || (isempty(DataStruct.swsize))
	DataStruct.swsize = 512; DataStruct.swstep = 512;
% 	fprintf('\n%s: WARNING: Set missing fields to defaults: DataStruct.swsize=%u, DataStruct.swstep=%u', ...
% 		mfilename, DataStruct.swsize, DataStruct.swstep);
end;
if (~isfield(DataStruct, 'RMSEnable')) || (isempty(DataStruct.RMSEnable)), DataStruct.RMSEnable = true; end;

% process varargin options
[ config_nrBands, config_RolloffFactor, config_nrCepCoeffs, ...
	config_nrPeaks, config_nrLags, config_nrMelFilters, config_nrLPCs, ...
	config_multisegment, config_swsize, config_swstep, config_swmode, ...
	config_newsps, config_oldsps, ...
	config_lowfrq, config_highfrq, ...
	config_speeddb, config_RMSEnable, config_detrend, ...
    config_cwtres, config_dwtlevels, config_wname, ...
    CheckForNaNs ] = process_options(varargin, ...
	'nrBands', 10, 'RolloffFactor', 0.95, 'nrCepCoeffs', 12, ...
	'nrPeaks', 2, 'nrLags', 12, 'nrMelFilters', floor(3*log(SampleRate)), 'nrLPCs', 12, ...
	'multisegment', 'NONE', ...
	'swsize', DataStruct.swsize, 'swstep', DataStruct.swstep, 'swmode', 'exit', ...
	'newsps', 256, 'oldsps', SampleRate, ...
	'lowfrq', 25, 'highfrq', floor(SampleRate/2), ...
	'speeddb', true, 'RMSEnable', DataStruct.RMSEnable, 'detrend', 'eye', ...
    'cwtres', 128, 'dwtlevels', [1 2 3 4], 'wname', 'db1', ...
    'CheckForNaNs', true );


% check/load data, adapt Range
if isempty(Range) || (min(size(Range))>1)
	error('\n%s: Range must be one section, [beg end].', mfilename);
	return;
end;
if (Range(2) >= inf), Range(2) = size(DataStruct.Data,1); end;
%[DataStruct Range] = fb_checknloaddata(DataStruct, Range);
%if (verbose), fprintf('\n%s: Range: %s', mfilename, mat2str(Range)); end;

% preprocessing to speed up code hotspots
dtab = cellstr2vcat(DataStruct.DTable);



% OAM REVISIT: How to estimate size of FeatureMatrix for initialisation?
% For single-value features it is zeros(1, length(RetFeatureString)), for
% multi-value features it is undetermined (before actually performing first
% computation)
FeatureMatrix = [];
FeatureCounts = zeros(1, length(FeatureString));
speeddb_featurenames = {};  speeddb_featureresults = {};  speeddb_featurematch = [];
StackStore = {};

for feature = 1:length(FeatureString)
	% data selection: token 1 identifies channel and sensor feature OR stack operation;
	% tokens 2 and beyond specify computation feature
	tokens = fb_getelements(FeatureString{feature});
	if isempty(tokens), error('\n%s: FeatureString not understood at pos: %u', mfilename, feature); end;

    % grab channel from data matrix
    channel = strmatch(tokens{1}, dtab);    
    thisfeature = col(DataStruct.Data(Range(1):Range(2), channel));
    featurestr = tokens(2:end);
    
    
	for inst = 1:length(featurestr)
		sdata = thisfeature;  % preserve data for further iterations

		WindowSize = size(sdata,1);
		if (WindowSize == 0)
			fprintf('\n%s: WindowSize is zero at: %s in %s', mfilename, featurestr{inst}, FeatureString{feature});
			thisfeature = 0;
			break;
		end;

		
		% Simple speedup db: stores all results and replaces new
		% computations with the previous results, if applicable.
		
		% guess what is beneficial to save: tradeoff btw strmatch time and computation  
		save2speeddb = config_speeddb && (~isupper(featurestr{inst}));  % store all lower case ones
		%save2speeddb = save2speeddb && isempty(strfind(featurestr{inst}, 'sec')==1); % no save 'secXX'
		
		% check if required result was computed before
		thisfeaturename = [ tokens{1}, featurestr{1:inst} ];
		if (save2speeddb)
			speeddb_featurematch = strmatch(thisfeaturename, speeddb_featurenames, 'exact');
		end;
		if save2speeddb && (~isempty(speeddb_featurematch))
			% yes, hit!
			thisfeature = speeddb_featureresults{speeddb_featurematch};
			continue;  % for inst
		end;


		% compute requested feature(s)
		switch (featurestr{inst}) % tokens 2 and greater only
			case 'EMPTY'
				thisfeature = [];
			case {'LENGTH', 'LEN'} % section length in samples
				thisfeature = WindowSize;
			case 'SEGPOINTS' % # segmentation points in this section
				thisfeature = length(segment_findoverlap(Range, DataStruct.seglist));
			case {'NOZCOUNT', 'NOZCNT'} % count non-zeros
				thisfeature = length(find(abs(sdata) > 0));
			case {'ZEROCOUNT', 'ZCNT'} % count zeros
				thisfeature = length(find(sdata == 0));

			case 'ZERO' % probe
				thisfeature = 0;
			case 'ONE' % probe
				thisfeature = 1;
			case 'RAND' % probe
				thisfeature = rand;

				% ------------------------------------------------------------
				% time domain
				% ------------------------------------------------------------

			case 'MIN' % minimum
				thisfeature = min(sdata,[],1);
			case 'MAX' % maximum
				thisfeature = max(sdata,[],1);
			case 'MEAN' % mean
				thisfeature = mean(sdata,1);
            case 'NANMEAN'
                thisfeature = nanmean(sdata,1);
			case'DMEAN'   % mean of differences (1st deviation)
				thisfeature = mean(diff(sdata,[],1),1);
			case'DDMEAN'   % mean of diff-differences (2nd deviation)
				thisfeature = mean(diff(diff(sdata,[],1),[],1),1);

			case 'MEDIAN'
				thisfeature = median(sdata,1);
			case 'SUM' % sum
				thisfeature = sum(sdata,1); % / WindowSize
			case 'BEG' % begin
				thisfeature = sdata(1);
			case 'END' % end
				thisfeature = sdata(end);
			case 'E-B' % end - begin
				thisfeature = (sdata(end) - sdata(1));
			case 'RANDVAL' % sample random value from sdata
				thisfeature = sdata(random('unid', WindowSize));				
			case 'MINMAX'
				% 1: max(+) - min(+): 5 - 3 = 2
				% 2: max(+) - min(-): 5 - -3 = 8
				% 3: max(-) - min(-): -3 - -5 = 2
				thisfeature = max(sdata,[],1) - min(sdata,[],1);
            case 'MINMAXPOSDIFF' % diff btw min and max positions
                [~, maxpos] = max(sdata,[],1);
                [~, minpos] = min(sdata,[],1);
                thisfeature = maxpos - minpos;
			case 'POSSUM' % summed positive samples
				thisfeature = sum(sdata(sdata > 0),1) / WindowSize;
			case 'NEGSUM' % summed negative samples
				thisfeature = sum(sdata(sdata < 0),1) / WindowSize;
			case 'VAR' % variance
				thisfeature = var(sdata,[],1);
            case 'NANVAR'
                thisfeature = nanvar(sdata,[],1);
			case 'FLUC' % fluctuation amplitudes
				thisfeature = feature_FLUC(feature_rms(sdata, config_RMSEnable));
			case 'ZCR' % number of zero crossings
				thisfeature = feature_ZCR(feature_rms(sdata, config_RMSEnable));
			case 'RMS'
				[~, thisfeature] = feature_rms(sdata, config_RMSEnable);
			case 'ENERGY'
				thisfeature = feature_ENERGY(sdata);
				% 			case 'TCENTROID'    % temporal centroid (1 valued feature)
				% 				thisfeature = feature_TCENTROID(sdata, DataStruct.SampleRate); %'cutoff', cutoff, 'subsample', rate );
                
           %===============================================================
           %cases added by A.M.Toth
            case  'SENERGY'
                   thisfeature=feature_SENERGY(sdata); 
                   
            case  'SSPREAD'
                   thisfeature=feature_SSPREAD(sdata);      
            case  'FFTMAX'
                   thisfeature=feature_FFTMAX(sdata);
            case   'SPWR14' 
                   thisfeature=feature_SPWR14(sdata);   
            case   'MCR'
                   thisfeature=feature_MCR(sdata); %Mean crossing rate
            case   'PEAKAMP'     
                    [~, peakvals]=feature_findpeaks(sdata, round(SampleRate/16));
                    thisfeature=mean(peakvals);
                   
            %==============================================================    
			case 'PEAKCOUNT'
				thisfeature = length( feature_findpeaks(sdata, round(SampleRate/16)) ) / WindowSize;
                
                
            case 'MAJORITY'
                [ids h] = countele(sdata);
                [~, hidx] = max(h);
                thisfeature = ids(hidx);

            case 'SEC12MEANDIFF' % difference between means of two signal sections
				i = 2; ss = floor(WindowSize/i);
                if ss==0, thisfeature = mean(sdata(1),1)-mean(sdata(end),1);                
                else thisfeature = mean(sdata(1:ss),1)-mean(sdata(ss*(i-1)+1:end),1); end;
            case 'SEC13MEANDIFF' % difference between means of two signal sections
				i = 3; ss = floor(WindowSize/i);
                if ss==0, thisfeature = mean(sdata(1),1)-mean(sdata(end),1);                
                else thisfeature = mean(sdata(1:ss),1)-mean(sdata(ss*(i-1)+1:end),1); end;
            case 'SEC14MEANDIFF' % difference between means of two signal sections
				i = 4; ss = floor(WindowSize/i);
                if ss==0, thisfeature = mean(sdata(1),1)-mean(sdata(end),1);
                else thisfeature = mean(sdata(1:ss),1)-mean(sdata(ss*(i-1)+1:end),1); end;
            case 'SEC15MEANDIFF' % difference between means of two signal sections
				i = 5; ss = floor(WindowSize/i);
                if ss==0, thisfeature = mean(sdata(1),1)-mean(sdata(end),1);                
                else thisfeature = mean(sdata(1:ss),1)-mean(sdata(ss*(i-1)+1:end),1); end;

                
                % OAM REVISIT: Needs cleanup
            case 'CWTMAXFRQ'   % [EXPERIMENTAL] extract scale/frq of max. energy by CWT,  Revision 1.0 (20090127) [mk]
                fs = SampleRate;
                % Wavelet center frequency
                fc = centfrq(config_wname);
                % Linear mode distribution (1Hz .. fs/2, fs>2Hz)
                N = config_cwtres; a = 2*fc; b = 4 * fs*fc; scal = a:(b-a)/(N-1):b;
                %frq = scal2frq(scal, config_wname, 1/fs);
                % CWT max scale per unit time
                maxscale = feature_CWT(sdata, scal, 'wname', config_wname, 'fname', 'maxscale', 'cwtres', N);
                % Convert scale to pseudo-frequency
                thisfeature = scal2frq(maxscale,config_wname,fs);

                
                % struct object returns
			case 'STRVAL'  % extract string value from string data
				% Although this looks as if multiple values are returned,
				% the object (thisfeature) is a singular item.
				% WARNING: Incompatible to non-string features!
				clear thisfeature;
				thisfeature.string = [sdata(:).string];
				thisfeature.seg = reshape([sdata(:).seg], size(sdata(1).seg,2), length(sdata))';

                % cell object returns
            case 'Cvalue'
                thisfeature = {sdata};
            case 'Chist'
                [ids h] = countele(sdata);
                thisfeature = {[ids h]};
                

				% ---------------------------------------------------------
				% continuous features types:
				%   1. lenght equal to sdata
				%   2. lenght equal to ceil(sdata/swstep)
				%   3. arbitrary length, directly coded in feature
				%
				% Feature matrices may contain one type only, e.g type 2.
				% Types 1,3 can be converted to type 2 by appending '_mean'
				% to the feature name.
				% ---------------------------------------------------------


				% ------------------------------------------------------------------------------------------------------------------
				% -- type 1 features (lenght equal to sdata) -----------------------------------------------------------------------
				% ------------------------------------------------------------------------------------------------------------------
			case 'inc' % probe
				thisfeature = col(1:length(sdata));
			case 'dec' % probe
				thisfeature = col(length(sdata):1);
			case 'zero' % probe
				thisfeature = zeros(length(sdata),1);
			case 'one' % probe
				thisfeature = ones(length(sdata),1);
			case 'rand' % probe
				thisfeature = rand(length(sdata),1);

			case {'value', 'nop'} % just the values (nop)
				thisfeature = sdata;
				
			case {'normrms', 'nrms'}  % rms normalised
				thisfeature = feature_rms(sdata, config_RMSEnable);
			case {'normmax', 'nmax'}  % max normalised
				thisfeature = sdata / max(sdata, [],1);
			case {'normsum', 'nsum'}  % sum normalised
				thisfeature = sdata / sum(sdata,1);
			case {'normwin', 'nwin'}  % sum normalised
				thisfeature = sdata / WindowSize;
			case {'normstd', 'nstd'}  % std normalised
				thisfeature = zscore(sdata);
			case 'normbe'  % be normalised
				thisfeature = sdata / mean([sdata(1) sdata(end)]);

            case 'levelmn' % remove average/mean level
                thisfeature = sdata - mean(sdata,1);
			case 'levelbe' % remove begin/end level
				thisfeature = sdata - mean([sdata(1) sdata(end)]);

			case 'abs' % absolute data
				thisfeature = col(abs(sdata));
			case 'diff' % differences of data samples
				thisfeature = col([0 row(diff(sdata,[],1))]);
			case 'ediff' % differences of data samples
				thisfeature = col(diff(sdata,[],1));
			case 'cumsum' % cumulative sum of data samples
				thisfeature = col(cumsum(sdata,1));
			case 'sign' % sign of data
				thisfeature = sign(sdata);
			case 'sortd' % sort decending
				thisfeature = sort(sdata, 1, 'descend');
			case 'sorta' % sort ascending
				thisfeature = sort(sdata, 1, 'ascend');
			case {'flipxaxis', 'flipx'}  % flip at x-axis
				thisfeature = -1 .* sdata;

			case {'gtzero', 'gtz'}  % filter values greater than zero (positive)
				thisfeature = sdata .* (sdata > 0);
			case {'stzero', 'stz'}  % filter values smaller than zero (negative)
				% alternative: xxx_flipxaxis_gtzero
				thisfeature = sdata .* (sdata < 0);
				
			case 'gtmean' % filter values greater than mean
				thisfeature = sdata .* (sdata >= mean(sdata,1));
			case 'gt1sd' % filter values greater than 1 sd from min
				thisfeature = sdata .* (sdata >= (min(sdata,[],1)+std(sdata,[],1)));
			case 'gt2sd' % filter values greater than 2 sd from min
				thisfeature = sdata .* (sdata >= (min(sdata,[],1)+(std(sdata,[],1)*2)));
			case 'gt3sd' % filter values greater than 3 sd from min
				thisfeature = sdata .* (sdata >= (min(sdata,[],1)+(std(sdata,[],1)*3)));

			case 'butterbp4' % digital Butterworth bandpass filter
				thisfeature = feature_filter(sdata, 'type', 'butter', 'order', 4, 'mode', 'bp', ...
					'sps', config_oldsps, 'lowfrq', config_lowfrq, 'highfrq', config_highfrq);
			case 'butterbp4L5H12k'  % Butterworth bandpass filter 5-12kHz
				thisfeature = feature_filter(sdata, 'type', 'butter', 'order', 4, 'mode', 'bp', ...
					'sps', config_oldsps, 'lowfrq', 5, 'highfrq', 12e3);
			case 'butterbp4L50H20k'  % Butterworth bandpass filter 50-20kHz
				thisfeature = feature_filter(sdata, 'type', 'butter', 'order', 4, 'mode', 'bp', ...
					'sps', config_oldsps, 'lowfrq', 50, 'highfrq', 20e3);
			case 'butterbp4L100H20k'  % Butterworth bandpass filter 100-20kHz
				thisfeature = feature_filter(sdata, 'type', 'butter', 'order', 4, 'mode', 'bp', ...
                    'sps', config_oldsps, 'lowfrq', 100, 'highfrq', 20e3);

            case 'nan2zero'  % Set NaN values to zero
                thisfeature = sdata;
                nanvec = isnan(thisfeature);
                thisfeature(nanvec) = 0;
                
            case 'nan2intp'  % [TESTING, OAM] Interpolate NaN values
                nanvec = isnan(sdata);
                if ~any(nanvec), continue; end;
                if all(nanvec), % no hope here;  OAM REVISIT: complain in this case?
                    % this is not optimal: could look for last known values and interpolate from there
%                     lastgood(1) = find( ~isnan(DataStruct.Data(1:Range(1)) ), 1 ,'last');
%                     lastgood(2) = find( ~isnan(DataStruct.Data(Range(2):end) ), 1 ,'first')+Range(2)-1;
                    
                    thisfeature = zeros(WindowSize,1); 
                    continue; 
                end; 
                
                t = sdata;  % save space in writing
                
                % interpolate any NaNs between measurements
                thisfeature = interp1q(col( find(~isnan(t)) ), col( t(~isnan(t)) ), col( 1:WindowSize ));

                nanvec = isnan(thisfeature);
                if nanvec(end)   % nan section is at the end
                    sp = find(nanvec, 1, 'first');  % start point of first nan section
                    thisfeature(sp : WindowSize) = thisfeature(sp-1);
                end;
                if nanvec(1) % nan section is at the start
                    ep = find(~nanvec, 1, 'first')-1; % end point of first nan section
                    thisfeature(1 : ep) = thisfeature(ep+1);
                end;
                
                % OAM REVISIT: temporaray check that size is OK
                if length(thisfeature) ~= WindowSize, 
                    disp(sdata);  disp(WindowSize);
                    error('intp size error detected.'); 
                end;
                
            case 'detrendwin'   % [TESTING] Data detrending,  Revision 1.0 (20090123) [mk]
                % Efficient modification on windows
                % OAM REVISIT: Problem with this code: current version of sswindow does not support continuous signals
                swstep = config_swstep + mod(config_swstep,2);    swsize = swstep * 2;
                dmat = sswindow(sdata, swsize, swstep, ...
                    ['feature_detrending(yt, ''model'', ''' config_detrend ''' )'], 'mode', config_swmode);
                % Convert signal matrix to vector
                dmatt = dmat(2:end-1, swstep/2+1:swstep/2*3)';
                thisfeature = [ dmat(1, 1:swstep/2*3)';  dmatt(:);  dmat(end, swstep/2+1:end)' ];
            case 'detrend'   % [TESTING] Data detrending,  Revision 1.0 (20090123) [mk]
                thisfeature = feature_detrending(sdata);

                
            case 'vnorm'    % vector norm (requires multiple columns in sdata)
                thisfeature = zeros(size(sdata,1), 1);
                for i = 1:size(sdata,1)
                    thisfeature(i) = norm(sdata(i,:), 2); % largest singular value
                end;
                
                
				% --------------------------------------------------------------------------------------------------------------------
				% -- type 2 features (lenght equal to ceil(sdata/swstep)) ------------------------------------------------------------
				% --------------------------------------------------------------------------------------------------------------------
                
			case 'mean' % sliding mean with configurable samples window
				thisfeature = col(sswindow(sdata, config_swsize, config_swstep, ...
					'mean(yt)', 'mode', config_swmode));
			case 'median' % sliding median with configurable samples window
				thisfeature = col(sswindow(sdata, config_swsize, config_swstep, ...
					'median(yt)', 'mode', config_swmode));
			case 'var'
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					'var(yt)', 'mode', config_swmode);
			case 'max'
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					'max(yt)', 'mode', config_swmode);
			case 'possum' % summed positive samples
				% not normalised by WindowSize since constant
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					'feature_SUM(yt, ''pos'')', 'mode', config_swmode);
			case 'fluc' % fluctuation amplitudes
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					'feature_FLUC(yt)', 'mode', config_swmode);
			case 'zcr' % number of zero crossings
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					'feature_ZCR(yt)', 'mode', config_swmode);
			case 'energy'
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					'feature_ENERGY(yt)', 'mode', config_swmode);
			case 'linfit' % two results: slope, axispoint
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					'feature_POLYFIT(yt)', 'mode', config_swmode);
			case 'peaks' % peak count
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['length(feature_findpeaks(yt,' num2str(round(SampleRate/16)) '))' ], 'mode', config_swmode);

				
			case 'acf'              % auto-correlation function (uses fft; config_nrLags valued feature)
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_ACF(feature_rms(yt, ' num2str(config_RMSEnable) '), ''fftsize'', ' num2str(config_swsize) ...
					', ''nrLags'', ' num2str(config_nrLags) ')'],   'mode', config_swmode);
			case 'bwidth'  % spectral signal bandwidth
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_BWIDTH(feature_rms(yt, ' num2str(config_RMSEnable) '), ''fftsize'', ', num2str(config_swsize) ')'], ...
					'mode', config_swmode);
			case 'cepstral'  % cepstral coefficients
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_CEPSTRAL(feature_rms(yt, ' num2str(config_RMSEnable) '), ''fftsize'', ', num2str(config_swsize), ...
					', ''nrCoeffs'', ' num2str(config_nrCepCoeffs) ')'],   'mode', config_swmode);
				
				
			case 'linbands'  % linear band energy
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_BANDS(feature_rms(yt, ' num2str(config_RMSEnable) '), ''fftsize'', ' num2str(config_swsize), ...
					', ''nrBands'', ' num2str(config_nrBands), ', ''BandType'', ''lin'')'], ...
					'mode', config_swmode);
				if isempty(thisfeature), thisfeature = zeros(1, config_nrBands); end;
			case 'logbands' % log band energy
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_BANDS(feature_rms(yt, ' num2str(config_RMSEnable) '), ''fftsize'', ' num2str(config_swsize), ...
					', ''nrBands'', ' num2str(config_nrBands), ', ''BandType'', ''log'')'], ...
					'mode', config_swmode);
				if isempty(thisfeature), thisfeature = zeros(1, config_nrBands); end;
				
			case 'lpc' % linear predictive coefficients (LPC)
				% requires Voicebox toolbox, similar to ACF, uses hamming windowing
				sdata = sdata(1:floor(length(sdata)/config_swstep)*config_swstep);
				thisfeature = lpcauto(sdata, config_nrLPCs, [config_swstep config_swsize 0]);
				if isempty(thisfeature), thisfeature = zeros(1, config_nrLPCs+1); end;
				thisfeature = thisfeature(:,2:end); % LPC(1) == 1
			case 'lpcnative'  % MATLAB Signal Processing Toolbox variant
				% returns identical results as Voicebox, lpcauto when using hamming windowing fcn
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['lpc(feature_windowise(yt), ' num2str(config_nrLPCs), ')'], ...
					'mode', config_swmode);
				thisfeature = thisfeature(:,2:end); % LPC(1) == 1
			case 'lpcc' %  linear predictive coefficients cepstrum
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_LPCC(yt, ''nrCoeffs'', ' num2str(config_nrLPCs), ', ''FScale'', ''cepstral'')'], 'mode', config_swmode);
			case 'lpcm' %  linear predictive coefficients cepstrum, mel-scaled
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_LPCC(yt, ''nrCoeffs'', ' num2str(config_nrLPCs), ', ''FScale'', ''mel'')'], 'mode', config_swmode);

			case 'mfcc' % mel-frequency cepstrum coefficients
				thisfeature = feature_mfcc(sdata, ...
					'SampleRate', SampleRate, 'fftsize', config_swsize, 'nrCepsCoeffs', config_nrCepCoeffs, ...
					'WindowSize', config_swsize, 'WindowStep', config_swstep, 'swmode', config_swmode, ...
                    'MelMethod', 'voicebox', 'nrTotalFilters', config_nrMelFilters );
				if isempty(thisfeature), thisfeature = zeros(1, config_nrCepCoeffs); end;
            % OAM REVISIT: testing            
            case 'mfccdd' % mel-frequency cepstrum coefficients, including deltas computed by viocebox
				thisfeature = feature_mfcc(sdata, ...
					'SampleRate', SampleRate, 'fftsize', config_swsize, 'nrCepsCoeffs', config_nrCepCoeffs, ...
					'WindowSize', config_swsize, 'WindowStep', config_swstep, 'swmode', config_swmode, ...
                    'MelMethod', 'voicebox', 'nrTotalFilters', config_nrMelFilters, 'VoiceboxFlags', 'dD' );
				if isempty(thisfeature), thisfeature = zeros(1, config_nrCepCoeffs*3); end;
                
                
                
			case 'rolloff'
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_ROLLOFF(feature_rms(yt, ' num2str(config_RMSEnable) '), ''fftsize'', ', num2str(config_swsize), ...
					', ''RolloffFactor'', ' num2str(config_RolloffFactor) ')'],   'mode', config_swmode);
			case 'rolloff10'
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_ROLLOFF(feature_rms(yt, ' num2str(config_RMSEnable) '), ''fftsize'', ', num2str(config_swsize), ...
					', ''RolloffFactor'', ' num2str(0.1) ')'],   'mode', config_swmode);
			case 'rolloff50'
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_ROLLOFF(feature_rms(yt, ' num2str(config_RMSEnable) '), ''fftsize'', ', num2str(config_swsize), ...
					', ''RolloffFactor'', ' num2str(0.5) ')'],   'mode', config_swmode);
			case 'rolloff95'
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_ROLLOFF(feature_rms(yt, ' num2str(config_RMSEnable) '), ''fftsize'', ', num2str(config_swsize), ...
					', ''RolloffFactor'', ' num2str(0.95) ')'],  'mode', config_swmode);
				
			case {'scentroid', 'cgrav'} % spectral centroid / spectral center of gravity
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_SCENTROID(feature_rms(yt, ' num2str(config_RMSEnable) '), ''fftsize'', ' num2str(config_swsize) ')'], ...
					'mode', config_swmode);
			case 'sdecrease' % spectral decrease
				% to be implemented
			case {'senergy', 'power'}
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_SENERGY(yt, ''fftsize'', ' num2str(config_swsize) ')'], ...
					'mode', config_swmode);
			case 'sfluc' % spectral fluctuation
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_FLUC(feature_fft(feature_rms(yt, ' num2str(config_RMSEnable) '), ' num2str(config_swsize) '))'], ...
					'mode', config_swmode);
			case 'slinfit' % two results: spectral slope, spectral axispoint
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
 					['feature_POLYFIT(feature_fft(feature_rms(yt, ' num2str(config_RMSEnable) '), ' num2str(config_swsize) '))'], ...
					'mode', config_swmode);
				%	['feature_FLUC(feature_fft(feature_rms(yt), ' num2str(config_swsize) '))'], ...
				
			case 'sspread'    % spectral spread (1 valued feature)
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_SSPREAD(feature_rms(yt, ' num2str(config_RMSEnable) '), ''fftsize'', ' num2str(config_swsize) ')'], ...
					'mode', config_swmode);
			case 'sskewness'    % spectral skewness (1 valued feature)
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_SSKEWNESS(feature_rms(yt, ' num2str(config_RMSEnable) '), ''fftsize'', ' num2str(config_swsize) ')'], ...
					'mode', config_swmode);
			case 'skurtosis'    % spectral kurtosis (1 valued feature)
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_SKURTOSIS(feature_rms(yt, ' num2str(config_RMSEnable) '), ''fftsize'', ' num2str(config_swsize) ')'], ...
					'mode', config_swmode);
			case 'soeratio'         % spectral odd to even harmonic energy ratio (1 valued feature)
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_SOERATIO(feature_rms(yt, ' num2str(config_RMSEnable) '), ''fftsize'', ' num2str(config_swsize) ')'], ...
					'mode', config_swmode);
			case 'tristimulus'      % spectral tristimulus (3 valued feature)
				thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
					['feature_TRISTIMULUS(feature_rms(yt, ' num2str(config_RMSEnable) '), ''fftsize'', ' num2str(config_swsize) ')'], ...
					'mode', config_swmode);



			case 'emgbandpass' % preconfigured EMG bandpass
				thisfeature = feature_emgfilter(sdata, 'sps', SampleRate, 'mode', 'bandpass');
			case 'emgfilter' % preconfigured EMG filtering
				thisfeature = feature_emgfilter(sdata, 'sps', SampleRate, 'mode', 'bandpass'); %'filter'
			case 'emgrect' % default EMG processing data
				thisfeature = feature_emgfilter(sdata, 'sps', SampleRate, 'mode', 'rectify');

    
            
            case 'fracdim' % [EXPERIMENTAL] fractal dimension by windowed detrended fluctuation analysis (DFA), Revision 1.0 (20090128) [mk]
                thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
                    'feature_FRACDIM(yt)', 'mode', config_swmode);
            case 'frsa'  % Estimation of breathing rate (RSA) from RR interval data,  Revision 1.0 (20090123) [mk]
                thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
                    ['feature_fRSA(yt, ' num2str(SampleRate) ')'],  'mode', config_swmode);
            case 'ffthrv'  % HRV features by windowed FFT,  Revision 1.0 (20090127) [mk]
                thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
                    ['feature_FFTHRV(yt, ' num2str(SampleRate) ', ''fftsize'', ' num2str(config_swsize) ')'], ...
                    'mode', config_swmode);
            case 'dwthrv'   % [EXPERIMENTAL] HRV features by windowed DWT, Revision 1.0 (20090127) [mk]
                thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
                    ['feature_DWTHRV(yt, ' num2str(SampleRate) ', ''wname'', ''' config_wname ''')'], ...
                    'mode', config_swmode);
            case 'dwtenergy'   % [EXPERIMENTAL] Spectral energy by windowed DWT,  Revision 1.0 (20090127) [mk]
                thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
                    ['feature_DWT(yt, [' num2str(config_dwtlevels) '] , ''wname'', ''' config_wname ''', ''fname'', ''energy'' )'], ...
                    'mode', config_swmode);
            case 'dwtrms'   % [EXPERIMENTAL] Spectral RMS by windowed DWT,   Revision 1.0 (20090123) [mk]
                thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
                    ['feature_DWT(yt, [' num2str(config_dwtlevels) '], ''wname'', ''' config_wname ''', ''fname'', ''rms'' )'], ...
                    'mode', config_swmode);
            case 'cwthrv'    % [EXPERIMENTAL] HRV features by windowed CWT, Revision 1.0 (20090127) [mk]
                thisfeature = sswindow(sdata, config_swsize, config_swstep, ...
                    ['feature_CWTHRV(yt, ' num2str(SampleRate) ', ''wname'', ''' config_wname ''', ''cwtres'', ' num2str(config_cwtres) ')'], ...
                    'mode', config_swmode);
                
                
                
                
                
                
				% ------------------------------------------------------------------------------------------------------------------
				% -- type 3 features (arbitrary length) ----------------------------------------------------------------------------
				% ------------------------------------------------------------------------------------------------------------------
                
                
			case {'mean-w256s1', 'mean256'} % sliding mean with 64 samples window
				thisfeature = swindow(sdata, 256, 1, @mean, ...
					'mode', config_swmode);
			case {'mean-w128s1', 'mean128'} % sliding mean with 64 samples window
				thisfeature = swindow(sdata, 128, 1, @mean, ...
					'mode', config_swmode);
			case {'mean-w64s1', 'mean64'} % sliding mean with 64 samples window
				thisfeature = swindow(sdata, 64, 1, @mean, ...
					'mode', config_swmode);
			case {'mean-w32s1', 'mean32'} % sliding mean with 32 samples window
				thisfeature = swindow(sdata, 32, 1, @mean, ...
					'mode', config_swmode);
			case {'mean-w16s1', 'mean16'} % sliding mean with 16 samples window
				thisfeature = swindow(sdata, 16, 1, @mean, ...
					'mode', config_swmode);

			case 'resample-o44100n16000' % resample date with configurable rates
				[p q] = rat(16e3/44.1e3); % newsps = 16k; oldsps = 44.1k
				thisfeature = resample(sdata, p, q);
			case 'resample-o16384n256' % resample date with configurable rates
				[p q] = rat(256/16384); % newsps = 256; oldsps = 16384
				thisfeature = resample(sdata, p, q);
			case 'resample-o2048n256' % resample date with configurable rates
				[p q] = rat(256/2048); % newsps = 256; oldsps = 2048
				thisfeature = resample(sdata, p, q);
			case 'resample-o1024n256' % resample date with configurable rates
				[p q] = rat(256/1024); % newsps = 256; oldsps = 1024
				thisfeature = resample(sdata, p, q);
			case 'resample' % resample date with configurable rates
				[p q] = rat(config_newsps/config_oldsps);
				thisfeature = resample(sdata, p, q);

            case 'downsample-2to1' % resample date with configurable rates
				thisfeature = sdata(1 : 2 : size(sdata,1), :);
            case 'downsample-3to1' % resample date with configurable rates
				thisfeature = sdata(1 : 3 : size(sdata,1), :);
            case 'downsample-4to1' % resample date with configurable rates
				thisfeature = sdata(1 : 4 : size(sdata,1), :);
            case 'downsample' % resample date with configurable rates
				n = ceil(config_oldsps/config_newsps);
				thisfeature = sdata(1 : n : size(sdata,1), :);
			case 'simpleupsample' % upsample date with configurable rates
				thisfeature = feature_simpleupsample(sdata, config_oldsps, config_newsps);

			case {'nozval'} % filter to retain non-zero elements
				thisfeature = sdata(abs(sdata) > 0);
			case {'nozpos'} % filter to retain non-zero elements
				thisfeature = find(abs(sdata) > 0);

			case 'peakpos' % positions of peaks
				%thisfeature = zeros(length(sdata) ,1); thisfeature(feature_peaks(sdata, config_nrPeaks)) = 1;
				thisfeature = feature_findpeaks(sdata, round(SampleRate/16), config_nrPeaks);
				thisfeature = matadd(zeros(config_nrPeaks,1), thisfeature);
			case 'peakval' % values of peaks
				%thisfeature = zeros(length(sdata) ,1); thisfeature(feature_peaks(sdata, config_nrPeaks)) = 1;
				%thisfeature = thisfeature .* sdata;
				[~, thisfeature] = feature_findpeaks(sdata, round(SampleRate/16), config_nrPeaks);
				thisfeature = matadd(zeros(config_nrPeaks,1), col(thisfeature));

			case 'sec12' % extract section from sdata
				i = 1;  ss = floor(WindowSize/2);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
			case 'sec22' % extract section from sdata
				i = 2;  ss = floor(WindowSize/2);
				thisfeature = sdata(ss*(i-1)+1:ss*i);

			case 'sec13' % extract section from sdata
				i = 1;  ss = floor(WindowSize/3);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
			case 'sec23' % extract section from sdata
				i = 2;  ss = floor(WindowSize/3);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
			case 'sec33' % extract section from sdata
				i = 3;  ss = floor(WindowSize/3);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
                
            case 'sec14' % extract section from sdata
				i = 1;  ss = floor(WindowSize/4);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
			case 'sec24' % extract section from sdata
				i = 2;  ss = floor(WindowSize/4);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
			case 'sec34' % extract section from sdata
				i = 3;  ss = floor(WindowSize/4);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
			case 'sec44' % extract section from sdata
				i = 4;  ss = floor(WindowSize/4);
				thisfeature = sdata(ss*(i-1)+1:ss*i);

            case 'sec15' % extract section from sdata
				i = 1;  ss = floor(WindowSize/5);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
			case 'sec25' % extract section from sdata
				i = 2;  ss = floor(WindowSize/5);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
			case 'sec35' % extract section from sdata
				i = 3;  ss = floor(WindowSize/5);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
			case 'sec45' % extract section from sdata
				i = 4;  ss = floor(WindowSize/5);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
			case 'sec55' % extract section from sdata
				i = 5;  ss = floor(WindowSize/5);
				thisfeature = sdata(ss*(i-1)+1:ss*i);                
                
            case 'sec16' % extract section from sdata
				i = 1;  ss = floor(WindowSize/6);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
			case 'sec26' % extract section from sdata
				i = 2;  ss = floor(WindowSize/6);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
			case 'sec36' % extract section from sdata
				i = 3;  ss = floor(WindowSize/6);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
			case 'sec46' % extract section from sdata
				i = 4;  ss = floor(WindowSize/6);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
			case 'sec56' % extract section from sdata
				i = 5;  ss = floor(WindowSize/6);
				thisfeature = sdata(ss*(i-1)+1:ss*i);
			case 'sec66' % extract section from sdata
				i = 6;  ss = floor(WindowSize/6);
				thisfeature = sdata(ss*(i-1)+1:ss*i);

                
                
			case {'transpose', 'tr', 'TRANSPOSE', 'TR'}
				thisfeature = sdata';
                
                % StackStore operations
            case { 'tostack', 'TOSTACK' }   % copy to stack
                thisfeature = sdata;
                StackStore{end+1} = thisfeature;
            case { 'push', 'PUSH' } % push to stack
                thisfeature = sdata;
                StackStore{end+1} = thisfeature;
                thisfeature = [];
                save2speeddb = false;
            case { 'fromstack', 'FROMSTACK' }   % copy last element from stack
                thisfeature = [ sdata, StackStore{end} ];
            case { 'pop', 'POP' }   % retrieve last element from stack
                thisfeature = [ sdata, StackStore{end} ];
                StackStore(end) = [];
                

			otherwise
				error(['Feature ' (featurestr{inst}) ' not found']);
		end; % switch


		% Save current result in speedup db, if it is not already in there.
		% Although growing, this db can speed up feature computation. 
		if (save2speeddb) && isempty(speeddb_featurematch)
			speeddb_featurenames{end+1} = thisfeaturename;
			speeddb_featureresults{end+1} = thisfeature;
		end;

	end; % for inst



% 	    if isempty(thisfeature)
% 	        fprintf('\n%s: WARNING: Feature %s was empty!', mfilename, FeatureString{feature});
% 	    end;
	try
		FeatureMatrix = [FeatureMatrix thisfeature];
	catch
		fprintf('\n%s: Feature dimensions do not match.', mfilename);
		fprintf('\n%s:   Current feature: %s', mfilename, FeatureString{feature});
		fprintf('\n%s:   FeatureMatrix: %s, thisfeature: %s', mfilename, mat2str(size(FeatureMatrix)), mat2str(size(thisfeature)));
		fprintf('\n%s:   Size of sdata: %s', mfilename, mat2str(size(sdata)));
		fprintf('\n%s:   Windowsize: %u  Windowstep:%u', mfilename, config_swsize, config_swstep);
		error('Stop.');
	end;
	
    if CheckForNaNs & any(isnan(thisfeature))
		fprintf('\n%s: Feature has NaNs and CheckForNaNs=true.', mfilename);
		fprintf('\n%s:   Current feature: %s', mfilename, FeatureString{feature});
		fprintf('\n%s:   FeatureMatrix: %s, thisfeature: %s', mfilename, mat2str(size(FeatureMatrix)), mat2str(size(thisfeature)));
		fprintf('\n%s:   Size of sdata: %s', mfilename, mat2str(size(sdata)));
		fprintf('\n%s:   Windowsize: %u  Windowstep:%u', mfilename, config_swsize, config_swstep);
		error('Stop.');        
    end;
    
	FeatureCounts(feature) = size(thisfeature,2); % remember actual number of features
end; % for feature


% determine exact feature string if requested
if (nargout > 1)
	RetFeatureString = fb_expandfeaturestring(FeatureString, FeatureCounts);
end;

% condense continuous features
switch (config_multisegment)
	case 'NONE'
	case 'MEAN'
		if isupper(featurestr{end})
			FeatureMatrix = mean(FeatureMatrix,1);
		end;
	case 'MEANVAR'
		FeatureMatrix = [mean(FeatureMatrix,1) var(FeatureMatrix,1)];
		%FeatureCounts = [featurecounts featurecounts];
		RetFeatureString = [RetFeatureString RetFeatureString];
end;
