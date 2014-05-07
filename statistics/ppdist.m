function Y = ppdist(X, distfun, varargin)
%PPDIST Pairwise distance between observations.
%   Returns a vector Y containing distances between each pair of
%   observations in the N-by-P data matrix X.  Rows of
%   X correspond to observations, columns correspond to variables.  Y is a
%   1-by-(N*(N-1)/2) row vector, corresponding to the N*(N-1)/2 pairs of
%   observations in X.
%       function      - A distance function specified using @, for
%                       example @DISTFUN
%
%   A distance function must be of the form
%
%         function D = DISTFUN(XI, XJ, P1, P2, ...),
%
%   taking as arguments a 1-by-P vector XI containing a single row of X, an
%   M-by-P matrix XJ containing multiple rows of X, and zero or more
%   additional problem-dependent arguments P1, P2, ..., and returning an
%   M-by-1 vector of distances D, whose Kth element is the distance between
%   the observations XI and XJ(K,:).
%
%   The output Y is arranged in the order of ((1,2),(1,3),..., (1,N),
%   (2,3),...(2,N),.....(N-1,N)), i.e. the lower left triangle of the full
%   N-by-N distance matrix in column order.  To get the distance between
%   the Ith and Jth observations (I < J), either use the formula
%   Y((I-1)*(N-I/2)+J-I), or use the helper function Z = SQUAREFORM(Y),
%   which returns an N-by-N square symmetric matrix, with the (I,J) entry
%   equal to distance between observation I and observation J.
%
%   See also PDIST, SQUAREFORM, LINKAGE, SILHOUETTE.

% Modified version, Oliver Amft, ETH Zurich, 2007
%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.15.4.10.24.1 $ $Date: 2006/07/27 21:51:23 $

% Assume an unrecognized string is a user-supplied distance
% function name, change it to a handle.

n = size(X,1);

[funcargs, range, verbose] = process_options(varargin, ...
	'funcargs', {}, 'range', [1 n-1], 'verbose', 1);


% Degenerate case, just return an empty of the proper size.
if n < 2
	Y = zeros(1,0);
	return;
end;

if (verbose), fprintf('\n%s: Probing distfun ''%s''...', mfilename, func2str(distfun)); end;
try
	Y = feval(distfun, X(1,:), X(2,:), funcargs{:})';
catch
	[errMsg,errID] = lasterr;
	if strcmp('MATLAB:UndefinedFunction', errID) ...
			&& ~isempty(strfind(errMsg, func2str(distfun)))
		error('stats:pdist:DistanceFunctionNotFound',...
			'The distance function ''%s'' was not found.', func2str(distfun));
	end
	% Otherwise, let the catch block below generate the error message
	Y = [];
end;

% Make the return have whichever numeric type the distance function
% returns, or logical.
if islogical(Y)
	Y = false(1,n*(n-1)./2);
else % isnumeric
	Y = zeros(1,n*(n-1)./2, class(Y));
end;


if (verbose), fprintf('\n%s: Compute links, range %s...', mfilename, mat2str(range)); end;
progress = 0.1;
k = 1;
for i = 1:n-1
	if ( (i >= range(1)) && (i <= range(2)) )
		progress = print_progress(progress, (i-range(1)+1)/(range(2)-range(1)+1));
		try
			Y(k:(k+n-i-1)) = feval(distfun, X(i,:), X((i+1):n,:), funcargs{:})';
		catch
			%[errMsg,errID] = lasterr;
			if isa(distfun, 'inline')
				error('stats:pdist:DistanceFunctionError',...
					['The inline distance function generated the following ', ...
					'error:\n%s'], lasterr);
			else
				error('stats:pdist:DistanceFunctionError',...
					['The distance function ''%s'' generated the following ', ...
					'error:\n%s'], func2str(distfun),lasterr);
			end;
		end; % try, catch
	end; % range check
	k = k + (n-i);
end;

