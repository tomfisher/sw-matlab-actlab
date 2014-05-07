function [nmatrix limitvals] = mclipping(matrix, varargin)
% function [nmatrix limitvals] = mclipping(matrix, varargin)
%
% Clip each column
%
% examples
%
% Find 5*std limits and apply it:
%   [nmatrix limitvals] = mclipping(matrix, 'sdlimit', 5)
%
% Apply previously found limits to new data:
%   nmatrix = mclipping(matrix, 'applysd', 'limitvals', limitvals)

[nrows ncols] = size(matrix);

[sdf limitvals] = process_options(varargin, ...
    'sdlimit', 3, 'limitvals', '');
    
if isempty(limitvals), 
	limitvals = [ ...
		mean(matrix,1)+(std(matrix,0,1).*sdf); ...
		mean(matrix,1)-(std(matrix,0,1).*sdf) ];
end;

if (size(limitvals,2) ~= ncols) || isempty(matrix)
    error('\n%s: Sizes do not match: matrix and limitvals', mfilename);
end;


% nmatrix = zeros(size(matrix));
nmatrix = matrix;
for col = 1:ncols
    % find elements NOT exceeding limitvals
	% 	maxclipidx = abs(nmatrix(:,col)) > abs(mean(nmatrix(:,col)) + limitvals(col));
	% 	minclipidx = abs(nmatrix(:,col)) < abs(mean(nmatrix(:,col)) - limitvals(col));
	%clipidx = abs(nmatrix(:,col)) > limitvals(col);
	maxclipidx = nmatrix(:,col) > limitvals(1,col);
	minclipidx = nmatrix(:,col) < limitvals(2,col);
	

%     if any(maxclipidx),   nmatrix(maxclipidx,col) =  sign(nmatrix(maxclipidx,col)) .* ( mean(matrix(:,col)) + limitvals(col) );  end;
% 	if any(minclipidx),   nmatrix(minclipidx,col) =  sign(nmatrix(minclipidx,col)) .* ( mean(matrix(:,col)) - limitvals(col) );  end;
	%nmatrix(clipidx,col) =  sign(nmatrix(clipidx,col)) .* limitvals(col);
    if any(maxclipidx),   nmatrix(maxclipidx,col) =  limitvals(1,col);  end;
	if any(minclipidx),   nmatrix(minclipidx,col) =  limitvals(2,col);  end;
end;



    % retain not exceeding elements, set rest to limitvals and retain sign
%     nmatrix(:,col) = (matrix(:,col) .* idxok) + ...
%         ( (sign(matrix(:,col)) .* (idxok==0) .* limitvals(col)) + (mean(matrix(:,col)) .* (idxok==0)) ) ;
