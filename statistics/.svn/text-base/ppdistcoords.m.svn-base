function X = ppdistcoords(Y, I, J)
% function X = ppdistcoords(Y, I, J)
%
% Get elements from ppdist vector
% 
% Example:
% 
% ppdistcoords(zeros(1,3), 1)

if (~exist('J', 'var')), J = []; end;

%   The output Y is arranged in the order of ((1,2),(1,3),..., (1,N),
%   (2,3),...(2,N),.....(N-1,N)), i.e. the lower left triangle of the full
%   N-by-N distance matrix in column order.  To get the distance between
%   the Ith and Jth observations (I < J), either use the formula
%   Y((I-1)*(N-I/2)+J-I), or use the helper function Z = SQUAREFORM(Y),
%   which returns an N-by-N square symmetric matrix, with the (I,J) entry
%   equal to distance between observation I and observation J.

%size(Y,1) = N*(N-1)/2
N = sqrt(2*length(Y)+0.25)+0.5;
if hasfrac(N), error('N is floating point. Not a valid size of Y?'); end;

if isempty(J),  
	J = 1:N;   
	J(J==I) = []; 
end;

if (I > N), error('Parameter I is too large for Y.'); end;
if any(J > N), error('Parameter J is too large for Y.'); end;

X = zeros(length(J),1);
J(J==I) = [];
for k = 1:length(J)
    %if (I == J(k)), continue; end;
		
    if (I > J(k)), 
        % flip coordinates
		tmp = I; I = J(k); J(k) = tmp; % [J(k) I] = wire(I, J(k)); 
        X(k) = ((I-1)*(N-I/2)+J(k)-I);
        tmp = I; I = J(k); J(k) = tmp; % [I J(k)] = wire(J(k), I);
    else
        X(k) = ((I-1)*(N-I/2)+J(k)-I);
    end;
end;