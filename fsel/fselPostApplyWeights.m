function [varargout] = fselPostApplyWeights(fstruct, varargin)
% function [varargout] = fselPostApplyWeights(fstruct, varargin)
% 
% Apply weights to matrices given in varargin.
% 
% See also: fselEvalFeatures
% 
% Copyright 2007-2011 Oliver Amft
if ~isstruct(fstruct)
    fprintf('\n%s: Warning: Calling procedure depricated and will be removed in the future. Use fstruct instead.', mfilename);
    FSelCommand = fstruct;
    fweighting = varargin{2}; 
    varargin(1) = [];
    fstruct.FSelCommand = FSelCommand; clear FSelCommand;
    fstruct.fweighting = fweighting; clear fweighting;
    fstruct.verbose = 1;
end;
verbose = fstruct.verbose;

for matrixnr = 1:length(varargin)
	thismatrix = varargin{matrixnr};
	
	switch(upper(fstruct.FSelCommand))
		% nothing to do here.
		case 'NONE'
			rankmatrix = thismatrix;

			% extraction methods
		case { 'LDA', 'PCA' }
			if iscell(thismatrix) && ischar(thismatrix{1})
				% assume feature string
				clear rankmatrix;
				[rankmatrix(1:size(fstruct.fweighting,2))] = deal({upper(fstruct.FSelCommand)});
			else
				rankmatrix = thismatrix * fstruct.fweighting;
			end;

        case 'STLEARN' % self-taught learner
            % feature construction: 'sc_noisevar', 1, 'sc_tol', 0.005, 'sc_gamma', 0.4
            gamma = fstruct.sc_gamma; epsilon = fstruct.sc_epsilon; tol = fstruct.sc_tol;  noise_var = fstruct.sc_noise_var;  batch_size = fstruct.sc_batch_size;
            if isempty(batch_size), batch_size = 1e3; end;
            B = fstruct.B; S = fstruct.S;
            %B = veWeight(:,1:size(thismatrix,2))';   S = veWeight(:,size(thismatrix,2)+1:end);

            if iscell(thismatrix) && ischar(thismatrix{1})
				% assume feature string
				clear rankmatrix;
				[rankmatrix(1:size(B,2))] = deal({upper(fstruct.FSelCommand)});
            else                
                %rankmatrix = l1ls_featuresign(B, thismatrix', gamma, S);
                
                if (verbose) && (size(thismatrix,1)>5*batch_size), fprintf('\n%s: Apply STLearner to featureset (size %u)...', mfilename, size(thismatrix,1)); end;
                rankmatrix = nan(size(thismatrix,1), size(B, 2));  % [ instances X num of bases ]
                idx = 1; progress = 0.1;
                for idx = batch_size : batch_size : size(thismatrix,1)
                    if (verbose) && (size(thismatrix,1)>5*batch_size), progress = print_progress(progress, idx/size(thismatrix,1)); end;
                    
                    rankmatrix(idx-batch_size+1:idx,:) = cgf_fitS_sc2(B, thismatrix(idx-batch_size+1:idx,:)', 'epsL1', noise_var, gamma, epsilon, 1, tol, false, false, false, S)';
                end;
                
                if isempty(idx), idx = 1; end;
                if idx < size(thismatrix,1)
                    rankmatrix(idx:end,:) = cgf_fitS_sc2(B, thismatrix(idx:end,:)', 'epsL1', noise_var, gamma, epsilon, 1, tol, false, false, false, S)';
                end;
            end;
            
            
		otherwise
			% this is risky, but default makes life easier
			rankmatrix = thismatrix(:,fstruct.fweighting>0);

% 			fprintf('\n%s: FSel method ''%s'' not supported.', mfilename, upper(FSelCommand));
% 			error('');
	end;  % switch
	
	varargout{matrixnr} = rankmatrix;
end; % for matrixnr