function [dist conf] = similarity(Method, Observations, varargin)
% function [dist conf] = similarity(Method, Observations, varargin)
%
% determine observation confidence and distance using method
%
% required: 
% method           'EUCLIDNORM': normalised euclidean distance (requires: mu, sd, [thres])
%                  'THRESHOLD' : distance to a threshold (requires: thres)
%                  'NAIVEBAYES': Naiive Bayes (requires: mu, sd)
%
% Observations     new feature vector to test, [obs x feat]
%
% optional parameters:
% thres            threshold to determine confidence (default: 100)
% mu, sd           class mean and standard deviation (default: mu=0, sd=1)
%
% determine mu and std:
%       mu = mean(Obs,1);
%       sd = std(Obs,0,1);
%
% Oliver Amft, Wearable Computing Lab., ETH Zürich, 2006

[nobs nfeat] = size(Observations);

[mu sd thres verbose] = process_options(varargin, ...
    'mu', repmat(0, 1, nfeat), 'sd', repmat(1, 1, nfeat), ...
    'thres', 100,  'verbose', 0);

% if std < 1e-10, reset it
sd = sd + ((sd == 0) * 1e-10);

% compute distances
progress = 0.1;
switch Method
    case {'EUCLIDNORM'}
        % requires: mu, sd      
%         for obs = 1:nobs
%             if (verbose) progress = print_progress(progress, obs/nobs); end;
%             
%             sqdist(obs,:) = ( (Observations(obs,:) - row(mu)) ./ row(sd) ) .^2;
%             dist(obs,:) = sqrt(sum( sqdist(obs,:) ));
%         end;
        dist = sqrt(sum( ( (Observations - repmat(row(mu),nobs,1)) ./ repmat(row(sd),nobs,1) ).^2, 2) );
        
        % determine confidence
        conf = dist ./ thres;
        conf(conf > 1) = 1;


        
    case {'THRESHOLD', 'THRES'}
        % requires: threshold (thres) per feature
        for obs = 1:nobs
            dist(obs,:) = sum( Observations(obs,:) - row(thres) ); %sum( row(thres) - Observations(obs,:) );
        end;

        % dist(find(dist < 0)) = 0;
        conf = (dist >= 0);
        % conf(find(dist >= 0),:) = 1; conf(find(dist < 0),:) = 0;
        % conf = shiftnorm(dist);

        
    case {'NAIVEBAYES', 'BAYES'}
        % requires: mu, sd
        for obs = 1:nobs
            obslik(obs,:) = sum(log( exp(-0.5 * ((Observations(obs,:) - row(mu))./ row(sd)) .^2) ./ (sqrt(2*pi) .* row(sd)) ));
            % exp(-0.5 * ((Observations(obs,f) - mu(f))./ sd(f)) .^2) ./ (sqrt(2*pi) .* sd(f));
        end;

        %dist = obslik * (-1);
        dist = obslik;
        conf = shiftnorm(obslik); % based on these observations

    otherwise
        error('Method %s not supported.', method);
end; % switch method

