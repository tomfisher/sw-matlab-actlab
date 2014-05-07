function TF = matchrow(M,S)
% MATCHROW - match elements in the rows of a matrix
%
%   TF = MATCHROW(M,S) returns a column vector containing a logical 1 (true)
%   where the rows of M contain (in any order) all the elements of S and 0
%   (false) otherwise. M and S can be a cell array of strings.
%   If a element occurs N times in S, than it has to be present at least N
%   times in these rows of M as well. 
%
%   Examples:
%     M = [ 1 2 3 4 5 ; 1 2 2 4 3; 1 3 4 4 3 ; 3 2 4 2 5 ; 1 4 3 2 4 ] ;
%     Q = matchrow(M,[1 2 4])  %   -> [1 ; 1 ; 0 ; 0 ; 1] ;
%     M(Q,:) % ->      1   2   3   4   5
%            %         1   2   2   4   3
%            %         1   4   3   2   4
%
%     Q = matchrow(M,[1 2 4 4]) 
%     M(Q,:)  % ->     1   4   3   2   4
%
%     Q = matchrow({'a','X','c','Y'; 'a','X','Y','d' ;
%        'b','X','d','e'},{'X','Y'})  % -> [1 ; 1 ; 0] ;
%
%     A = rand(999,999) ;
%     x = 27 ;
%     tic
%     find(matchrow(A,A(x,:))) == x % -> true!
%     toc  
%
%   MATCHROW is vectorized and pretty quick ...
%
%   See also FIND, ISMEMBER

% for Matlab R13
% version 1.1 (apr 2007)
% (c) Jos van der Geest
% email: jos@jasen.nl

% History
%   Created: apr 2007, inspired by a post on CSSM
%   1.1 (apr 2007) - fixed some minor spelling errors

% argument checking: are there enough of them
error(nargchk(2,2,nargin)) ;

% is M a proper 2D array
if ndims(M) ~= 2,
    error ('Matrix argument M should be a 2D array.') ;
end

if iscell(M),
    % for a cell array of strings, convert its contents to a numeric value
    try
        % cell arrays of mixed tpes (e.g., numbers and strings) will error here
        uM = unique(M) ;
        [M,M] = ismember(M,uM) ;
        [S,S] = ismember(S,uM) ;
    catch
        error('Cell input must be a cell array of strings.') ;
    end
end
    
nS = numel(S) ; % the total number of elements of S

if nS == 1,
    % first trivial case
    % look for the presence of the number in each row
    TF = any(M==S,2) ;
elseif nS > size(M,2),
    % second trivial case
    % there are more elements in S, than there are columns in M
    warning('matchrow:SizeToLarge','Row exceeds matrix size') ;
    TF = false(sz(1),1) ;
else
    % now we have to do some work
    uS = unique(S(:)) ;      % what are the unique elements in S
    nuS = numel(uS) ;        % and how many are there
    nS = histc(S(:),uS) ;    % and how many times does each element occur in S
    
    % use ismember to look if these unique elements are present in M, 
    % the second output will tell us which unique elements these are
    % overwrite M to save memory 
    [M,M] = ismember(M,uS) ;
    
    % count the number of occurences of each unique element in M
    % note that histc operates on columns, so use its transpose
    N = histc(M.',1:nuS) ;    
    
    % subtract the number each numbers should at least occur
    N = N - repmat(nS,1,size(N,2)) ;
    
    % if all N are >= 0, than each unique value of S is present enough times in M
    TF = ~any(N<0,1).' ;
end

