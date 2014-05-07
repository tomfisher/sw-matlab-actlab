function [targets conf model] = naivebayes(train_patterns, train_targets, test_patterns, ClassifierModel, varargin)
% function [targets conf model] = naivebayes(train_patterns, train_targets, test_patterns, varargin)
%
% Naiive Bayes classifier
% 
% Copyright 2006, 2008, 2009 Oliver Amft
% 
% changelog:
% Voo1: ¬ created file, oam, 2oo6)
% Voo2: ¬ added changelog
%       ¬ removed 'find(..)' statements
%       ¬ bugfix: added explicit dimension command which 'mean' and 'std'
%       should work on to prevent dimension mismatch if only one
%       observation per class exists (line 24,25)
%       (mk, 2oo7o314)
% V003: removed loop for each observation
% V004: added warning handlers, variable pre-initialisations
% 20080227, removed explicit exp-log step, added eps margin for confidence computation, oam 
% 20080227, made independent of class number, removed repmats for speedup, oam 

[PDF verbose] = process_options(varargin, 'pdf', 'normal', 'verbose', 1);
% disp('V005');

classids = unique(train_targets);
nclasses = length(classids);

% testing
[nobs nfeatures] = size(test_patterns);

% training/testing
if (isempty(train_patterns))
    if ~exist('ClassifierModel'), error('Model of the classifier is not provided.'); 
    else
        mu = ClassifierModel.mu;
        sd = ClassifierModel.sd;
        PDF = ClassifierModel.pdf;
    end;
else
    mu = zeros(nclasses, nfeatures); sd = zeros(nclasses, nfeatures);
    for c = 1:nclasses
        mu(c,:) = mean(train_patterns(train_targets == classids(c),:), 1);
        sd(c,:) = std(train_patterns(train_targets == classids(c),:),0,1);
        sd(c,:) = sd(c,:) + eps*(sd(c,:)==0);
    end;
end


lastwarn('');
obslik = zeros(nobs,nclasses);
for c = 1:nclasses
    
    switch lower(PDF)
        case {'gaussian', 'normal'}
            %     for obs = 1:samples
            %         thisobs = test_patterns(obs,:);
            %         obslik(obs, class) = sum(log( exp(-0.5 * ((thisobs - mu(class,:))./ sd(class,:)) .^2) ./ (sqrt(2*pi) .* sd(class,:)) ));
            %     end; % for obs

            %thismu = repmat(mu(c,:), nobs,1);
            %thissd = repmat(sd(c,:), nobs,1);

            %tmpobs = exp(-0.5 * ((test_patterns - thismu)./ thissd) .^2) ./ (sqrt(2*pi) .* thissd);
            %tmpobs = (-0.5 * ((test_patterns - thismu)./ thissd) .^2) - log(sqrt(2*pi) .* thissd);			
			tmpobs = (-0.5 * ((test_patterns - mu(ones(nobs,1)*c,:))./ sd(ones(nobs,1)*c,:)) .^2) ;
			tmpobs = tmpobs - log(sqrt(2*pi) .* sd(ones(nobs,1)*c,:));
            
            % Raise pdf result to machine resolution level to avoid log of zero.
            % This will also help to work with new observation data that is at pdf fringes 
           % tmpobs = tmpobs + eps*(tmpobs==0);
            
        otherwise
            error('PDF not supported.');
    end; % switch lower(pdf)


    % find out about warning identifier: [s id ]= lastwarn; disp(id);
	%warning('off', 'MATLAB:log:logOfZero');
	%obslik(:,class) = sum(log( tmpobs ), 2);
	%warning('on', 'MATLAB:log:logOfZero');

	obslik(:,c) = sum( tmpobs, 2);	
end; % for class
% [s id]= lastwarn; if (~isempty(id)), disp([' Line 47: ' id]); end;

[dummy targets] = max(obslik,[],2);
targets = classids(targets);

% % obslik > 0 handling: shift observation loglik to negative numbers
% ppos = dummy>0;
% if (verbose) && sum(ppos), fprintf('\n%s: Found positive loglik for %u observations.', mfilename, sum(ppos)); end;
% obslik(ppos,:) = obslik(ppos,:) - dummy(ppos)*ones(1,size(obslik,2));
% Not needed when conf is normalised my its max value, see below.

eobslik = exp(obslik);
eobslik = eobslik + eps*(eobslik==0);

% convert obslik to confidence:
% use exp to make all positive (eobsliks), normalise by sum of eobsliks
% find out abount warning identifier: [s id ]= lastwarn; disp(id);
lastwarn('');
wstate = warning;   warning('off', 'MATLAB:divideByZero');
conf = eobslik ./ (sum(eobslik,2)*ones(1,nclasses));
warning(wstate);

[s id]= lastwarn; if (~isempty(id)), disp([' Line 67: ' id]); end;
% conf = shiftnorm(dist); % based on these observations
%conf = (repmat(s,1,2)-abs(obslik))./repmat(s,1,2);

% store model information
model.mu = mu; model.sd = sd;  model.pdf = PDF;