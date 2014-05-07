function threslist = estimatethresholddensity(Samples, varargin)
% function threslist = estimatethresholddensity(Samples, varargin)
%
% Estimate evaluation thresholds from Samples values. 
% 
% WARNING: Most methods work for distances only.
% 
% Copyright 2008-2009 Oliver Amft

nobs = length(Samples);
sdata = sort(Samples);
sdrange = sdata(end)-sdata(1);  % range of Samples values
if (sdrange==0), warning('Sample range is zero.'); end;

[Model Res Order StartPt EndPt XObs BagSize SetThresholds OptPrecision verbose] = process_options(varargin, ...
	'Model', 'polyxobs', 'Res', round(nobs*0.1), 'Order', 2.0, 'StartPt', 0, 'EndPt', max(sdata), 'XObs', nobs, ...
	'BagSize', 1, 'SetThresholds', [], 'OptPrecision', 0.1, 'verbose', 1);

if isempty(Res), Res = round(nobs*0.1); end;  % set default if called through hierarchies

if length(StartPt)>1, StartPt = mean(StartPt); end;
if length(EndPt)>1, EndPt = mean(EndPt); end;

p = Order;

threslist = [];
switch lower(Model)
	case 'trainobjfit1'  % fit poly onto training objects
		% this method uses the best-matching objects as basis and fits a
		% poly onto it.
		Order = 1;
		Xoffset = 0;  % margin regulariser (shifts curve on x-axis to left)
		X = Xoffset:length(SetThresholds)+Xoffset-1;
		
		% OAM REVISIT: polyfit may need "centering and scaling", unclear how to do that
		pc = polyfit(X, row(sort(SetThresholds, 'ascend')), Order);

		X = 1:Res;
		threslist = pc(1).*X + pc(2);  % Order = 1
	case 'trainobjfit2'  % fit poly onto training objects
		% this method uses the best-matching objects as basis and fits a
		% poly onto it.
		Order = 2;
		Xoffset = 0;  % margin regulariser (shifts curve on x-axis to left)
		X = Xoffset:length(SetThresholds)+Xoffset-1;
		
		% OAM REVISIT: polyfit may need "centering and scaling", unclear how to do that
		pc = polyfit(X, row(sort(SetThresholds, 'ascend')), Order);

		X = 1:Res;
		threslist = pc(1).*(X.^2) + pc(2).*X + pc(3);  % Order = 2

	case 'trainobjfit3'  % fit poly onto training objects
		% this method uses the best-matching objects as basis and fits a
		% poly onto it.
		Order = 3;		
		Xoffset = 10;  % margin regulariser (shifts curve on x-axis to left)
		X = Xoffset:length(SetThresholds)+Xoffset-1;
		
		% OAM REVISIT: polyfit may need "centering and scaling", unclear how to do that
		pc = polyfit(X, row(sort(SetThresholds, 'ascend')), Order);

		X = 1:length(SetThresholds)+Xoffset;   X = [ X  X(end):Res-length(X) ];
		threslist = pc(1).*(X.^3) + pc(2).*(X.^2) + pc(3).*X + pc(4);  % Order = 3		
		
		
	case 'trainobjext'   % use training objects as distances, extended 
		% this method uses the best-matching objects as basis and extends
		% this list by further thresholds, according to 'polyxobs'
		% issue: If train examples are too sporadically, this will incure a
		% large error wrt the targeted performance ('jumps' btw objs too large)
		threslist = row(sort(SetThresholds, 'ascend'));  % initial values are given
		Res = Res - length(threslist);  % fill up till Res
		
		if XObs>nobs, 
			if verbose, fprintf('\n%s: WARNING: XObs too large (%u), setting it to %u.', mfilename, XObs, nobs); end;
			XObs = nobs;
		end;
		if (XObs/Res > 10)  || (XObs/Res < 2)
			fprintf('\n%s: WARNING: Res too small/high: %u yields %.1f pts.', mfilename, Res, XObs/Res);
		end;
		if (XObs >= threslist(end))
			fprintf('\n%s: WARNING: XObs is too small, will not extend list: Thres(end)=%.2f, XObs=%.2f.', mfilename, threslist(end), sdata(XObs));
		end;
		StartPt = threslist(end); EndPt = sdata(XObs);
		sdrange = EndPt - StartPt;
		threslist2 = 1/((EndPt-StartPt)^(p-1)) * (0:sdrange/(Res-1):EndPt-StartPt) .^ p;

		threslist = [ threslist row(threslist2)+StartPt ];
		
		% restore Res value for self-check
		Res = length(threslist);
		
	case 'polyman'  % polynomial with bounds set manually
		% less sensitive to local outliers that modify solution
		% since starting point is fixed to zero
		% see:
		%   p1o2 = load('SPOTOliver_CLettuce3_AA_Test-thres_p1o2')
		%   figure; plot(cell2mat(p1o2.mythresholds')')
		
		%threslist = polyfit([1:length(sdata)]', sdata, Order);
		threslist = 1/(EndPt^(p-1)) * (StartPt:EndPt/(Res-1):EndPt) .^ p;
				
	case 'polyauto' 	% find starting point automatically
		StartPt = sdata(1); EndPt = sdata(end);
		threslist = 1/((EndPt-StartPt)^(p-1)) * (0:sdrange/(Res-1):EndPt-StartPt) .^ p;
		threslist = threslist + StartPt;
		% plot(threslist);
		
	case 'polyxobs'
		% idea: 
		% * use polynom to model thresholds on subset (10-fold embedding size) given in XObs 
		% * set Res to get threhold for every 5 samples: XObs/Res = 5
		if XObs>nobs, 
			if verbose, fprintf('\n%s: WARNING: XObs too large (%u), setting it to %u.', mfilename, XObs, nobs); end;
			XObs = nobs;
		end;
		if (XObs/Res > 5)  || (XObs/Res < 2)
			fprintf('\n%s: WARNING: Res too small/high: %u yields %.1f pts.', mfilename, Res, XObs/Res);
		end;
		StartPt = sdata(1); 
        if EndPt >= sdata(end), EndPt = sdata(XObs); end;
		sdrange = EndPt - StartPt;
		threslist = 1/((EndPt-StartPt)^(p-1)) * (0:sdrange/(Res-1):EndPt-StartPt) .^ p;
		threslist = threslist + StartPt;
		
        
    case 'conf_sqrt'  % 0...1 confidences
        threslist = row( sqrt(1:Res) / sqrt(Res) ); threslist(end) = 1;
        
    case 'conf_lin'
        threslist = row( (1:Res) / Res ); threslist(end) = 1;

    case 'all'
        % idea: threshold for every sample
		threslist = row( sdata(:) );
        Res = length(threslist); % avoid error at final checks
        
	case 'unique1'
		% idea: threshold for every unique value in samples
		% WARNING: This implementation creates variable sized threhold lists! 
		[tmp vidx] = unique(sdata,'first');  % this will sort the thresholds
		threslist = row( sdata(vidx) );
        Res = length(threslist); % avoid error at final checks
    case 'unique2'
		% idea: threshold for every BegSize-th unique value in samples above XObs
		% WARNING: This implementation creates variable sized threhold lists! 
        if isempty(XObs), XObs = nobs; end;
		[tmp vidx] = unique(sdata,'first');  % this will sort the thresholds

        threslist = row( sdata(vidx(1:XObs) ));
        if XObs < length(vidx),  threslist = [ threslist  row( sdata(vidx(XObs+1:BagSize:end) )) ];  end;
        Res = length(threslist); % avoid error at final checks

        
    case 'optprec'
        % idea: determine threshold for precision threshold, last pt: inf
        % XObs - relevant observations
        % OptPrecision - lowest relevant precision
        threslist = [];        
        if isempty(XObs), XObs = nobs; end;
		[tmp vidx] = unique(sdata,'first');  % this will sort the thresholds

        UniEndPt = floor(XObs / OptPrecision);  % make sure that we really catch the optprec sample size
        if UniEndPt > nobs, 
            UniEndPt = nobs;
            threslist = sdata(vidx( end ));
        end;

        if  UniEndPt < length(vidx)
            VEnd = length(vidx)-UniEndPt;
            VPt = unique( [UniEndPt, UniEndPt + round( exp(0:log((length(vidx)+1)/VEnd):log(VEnd)) ) ] );
            %   plot(  exp(0:log((length(vidx)+1)/VEnd):log(VEnd)) );   ylim([0 10]);
            %   plot( VPt )
            threslist = [ threslist  row( sdata(vidx( unique([VPt, length(vidx)] ) ) )) ];
            %   plot( sdata(vidx( unique([VPt, length(vidx)] ) ) ) )
        end;
        Res = length(threslist); % avoid error at final checks

        if sum(sdata(vidx)>threslist(end-1))/length(vidx) > 0.4
            warning('spotting:estimatethreshold', 'exp model did not fit distances well');
        end;
        if max(threslist) > max(sdata), 
            fprintf('\n%s: XObs=%u, EndPt=%u, UniEndPt=/u, max thres=%f, max sdata=%f', mfilename, ...
                XObs, EndPt, UniEndPt, max(threslist), max(sdata) );
            error('Something wrong here'); 
        end;

        
        
    case 'uniexp'
        % idea: threshold for each sample until precision threshold should be reached, last pt: inf
        % XObs - relevant observations
        % OptPrecision - lowest relevant precision
        if isempty(XObs), XObs = nobs; end;
		[tmp vidx] = unique(sdata,'first');  % this will sort the thresholds
        
        UniEndPt = round(XObs / OptPrecision);
        if UniEndPt > nobs, UniEndPt = nobs; end;
		threslist = row( sdata(vidx(1:UniEndPt) ));
        threslist(end+1) = inf;
        
        Res = length(threslist); % avoid error at final checks

        if length(threslist) <= 2
            fprintf('\n%s: XObs=%u, EndPt=%u, UniEndPt=/u, max thres=%f, max sdata=%f', mfilename, ...
                XObs, EndPt, UniEndPt, max(threslist), max(sdata) );
            error('Something wrong here'); 
        end;

    case 'uniexp1'
        % idea: threshold for each sample until precision threshold should be reached, exp afterwards
        % XObs - relevant observations
        % OptPrecision - lowest relevant precision
        if isempty(XObs), XObs = nobs; end;
		[tmp vidx] = unique(sdata,'first');  % this will sort the thresholds
        
        UniEndPt = round(XObs / OptPrecision);
        if UniEndPt > nobs, UniEndPt = nobs; end;
		threslist = row( sdata(vidx(1:UniEndPt) ));

        if  UniEndPt < length(vidx)
            VEnd = length(vidx)-UniEndPt;
            VPt = round( UniEndPt + exp(0:log((length(vidx)+1)/VEnd):log(VEnd)) );
            threslist = [ threslist  row( sdata(vidx( unique([VPt, length(vidx)] ) ) )) ];
        end;
        Res = length(threslist); % avoid error at final checks

        if max(threslist) > max(sdata), 
            fprintf('\n%s: XObs=%u, EndPt=%u, UniEndPt=/u, max thres=%f, max sdata=%f', mfilename, ...
                XObs, EndPt, UniEndPt, max(threslist), max(sdata) );
            error('Something wrong here'); 
        end;
                
	case 'equidist1'
		% bag size = 1: make threshold for every sample
		% WARNING: This implementation creates variable sized threhold lists! 
		BagSize = 1;
		threslist = row( sdata(BagSize:BagSize:nobs) );
	
	case 'equidistx'
		% idea: subsample sample list - threshold for every bagsize samples
		% WARNING: This implementation creates variable sized threhold lists! 
		if (Res>nobs), Res = nobs; end;
		
		BagSize = nobs/Res;
		threslist = row( sdata(BagSize:BagSize:nobs) );

	case {'equixobs', 'equidist'}
		% idea: take a constant bag of sorted samples, find thresholds
		% accordingly. Limit on maximum threshold: XObs.
		% (This corresponds to a linear object map function.)
		% problem:how to choose bag size? small steps needed - too
		% computational intensive for whole test set!
		if (0)
			% attempt 1: brute force using fixed bagsize
			XObs = Res * 1;  % use fixed bagsize, manually control coverage with Res
		else
			% attempt 2: restrict search space since nr of relevant objects is known
		end;

		if XObs>nobs, XObs = nobs; end;
		BagSize = round(XObs/Res);
		threslist = [row(sdata(BagSize:BagSize:XObs-BagSize)) sdata(XObs)];
		
		
		
	case 'polydist'   % use polynom to determine nr of objects, map to real data
		% abandonned
		
	case 'polyfit'
		% did not work:
		% 		Warning: Polynomial is badly conditioned. Add points with distinct X
		% 		values, reduce the degree of the polynomial, or try centering
		% 		and scaling as described in HELP POLYFIT.
		%threslist = polyfit([1:length(sdata)]', sdata, Order);
		
	otherwise
		error('Model %s not supported.', Model);
end;

if (verbose), 
    fprintf('\n%s: Using model: %s, Res=%u, XObs=%u, MaxT=%.2f', mfilename, Model, ...
        Res, XObs, threslist(end));
end;

% selfcheck
pc = 1e10;
if min(threslist)>min(Samples)+eps(pc) && ~(strcmpi(Model, 'equidist'))  && ...
		~(isempty(strmatch('trainobj', Model)))  && ~(strcmpi(Model, 'optprec'))  
	fprintf('\n%s: WARNING: Threshold underrun!', mfilename);
	fprintf('\n%s: Min: Thres:%f  -> Data:%f, Obs:%u', mfilename, ...
		min(threslist), min(Samples)+eps(pc), sum(Samples<min(threslist)));
end;
if max(threslist)<max(Samples)-eps(pc) && ~strcmpi(Model, 'equixobs') && ...
		~strcmpi(Model, 'polyxobs') && ~strncmpi(Model, 'trainobj', length('trainobj')) && ~strcmpi(Model, 'optprec')
	fprintf('\n%s: WARNING: Threshold overrun!', mfilename);
	fprintf('\n%s: Max: Thres:%f  -> Data:%f, Obs:%u', mfilename, ...
		max(threslist), max(Samples)-eps(pc), sum(Samples>max(threslist)));
	%fprintf('\n');
end;
if length(threslist)>Res && ~(strcmpi(Model, 'equidist1')),
	fprintf('\n%s: WARNING: threslist has wrong size (%u).', mfilename, length(threslist));
	error('here');
end;

return;

%'UniDist', [10 1], 'TieBounds', repmat(0.1*cr,1,2)
% UniDist;  % dynamic range of distances

h = histecb(Samples, Res);
nh = h/sum(h);  % normalize histogram
% plot(nh);

% % find appropriate bounds
% for t = 1:-TSteps:0
% 	if sum(nh(nh>t)) > CoverRatio, break; end;
% end;
% (nh>t)


% switch lower(Model)
% 	case 'linear'
% 		% d =  unidist(1) + ( unidist(2)-unidist(1) ) * nh
% 		distvals = UniDist(1) + ( UniDist(2)-UniDist(1) ) .* nh;
% 		distvals = distvals / sum(distvals) * sdrange;
% 		threslist = cr(1) + [ 0 cumsum( distvals ) ];
% 		
% end; % switch



% OLD VERSION

%df = max(nh)-nh;
df = (max(nh)-nh)/max(nh);

% threslist = cumsum(sdrange * (df/sum(df) ));
threslist = cr(1) + [ 0 cumsum(sdrange * (df/sum(df) )) ];

threslist = [ threslist(1)-TieBounds(1) threslist ];
if (threslist(1) < 0), threslist(1) = 0; end;

threslist = [ threslist threslist(end)+TieBounds(2) ];

