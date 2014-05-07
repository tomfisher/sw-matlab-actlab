function [ranking rankwords rankingidx] = countwords(wordlist, varargin)
% function [ranking rankwords rankingidx] = countwords(wordlist)
% 
% Count all words in wordlist cell array and rank them

uniquewords = unique(wordlist);

[searchwords searchopt verbose] = process_options(varargin, ...
	'searchwords', uniquewords, 'searchopt', 'exact', 'verbose', 1);


progress = 0.1;
countlist = zeros(1, length(searchwords));
for i = 1:length(searchwords)
	if isempty(searchwords{i}), continue; end;
	if verbose,  progress = print_progress(progress,  i/length(searchwords)); end;
	
	if isempty(searchopt), 
		countlist(i) = length(strmatch(searchwords{i}, wordlist));
	else
		countlist(i) = length(strmatch(searchwords{i}, wordlist, searchopt));
	end;
end;

[ranking rankingidx] = sort(countlist, 'descend');
rankwords = searchwords(rankingidx);
