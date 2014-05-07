function [OrderedEigs, y] = fselWeightLDA(x, g)
% function [OrderedEigs, y] = fselWeightLDA(x, g)
%
% Performs a multiple linear discriminant analysis on data x that belong
% to groups g.  x is a matrix whose rows correspond to cases
% and whose columns correspond to variables.  g is an array with
% one entry per case containing a positive integer marking the group
% for the corresponding case.
%
% Returns the transformation matrix T and the transformated data y. 
%
% 
% Copyright 2006 Oliver Amft
% based on various ideas and authors, please see references below
%
% changed 25.7.02 from Discrim.m by M. Staeger
%
% Written by Kenneth D. Harris 
% This software is released under the GNU GPL
% www.gnu.org/copyleft/gpl.html
% any comments, or if you make any extensions
% let me know at harris@axon.rutgers.edu
%
% changelog: 
% 20061114 mk, modified LDA to be independent of absolute label values, i.e. e.g. labels 18
% and 4 behave as they were labeled 1 and 2 and so forth.


% mk
% nGroups = max(g);
grouplabels = unique(g);
nGroups = length(grouplabels);
for n = 1:length(g)
    g(n) = find( grouplabels == g(n) );
end;

% mk, unchanged
[nCases nDim] = size(x);

Means = zeros(nGroups, nDim);

for i=1:nGroups
	Means(i,:) = mean(x(g==i,:),1);
end

Between = cov(Means);

Within = cov(x - Means(g,:));

invWithin = pinv(Within);

[v d] = eig(invWithin * Between);

[Sorted Order] = sort(diag(d));

Sorted2 = flipud(Sorted);
Order2  = flipud(Order);

%Order2NonZero = Order2(abs(Sorted2)>eps);
Order2NonZero = Order2(abs(Sorted2)>0.0001);
OrderedEigs = v(:,Order2NonZero);

y = x * OrderedEigs;

if (size(OrderedEigs,2)>=nGroups), warning('fsel:LDA', 'Bad data scaling resulted in additional features.'); end;