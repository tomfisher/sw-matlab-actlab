function [spartlist spartindices] = repos_getpartsforsubject(Repository, Partlist, SubjectList)
% function [spartlist spartindices] = repos_getpartsforsubject(Repository, Partlist, SubjectList)
%
% Extract PIs for a subject from a list
%
% spartlist - parts that correspond to Subject
% spartindices - indices of Partlist that correspond to Subject
% 
% Copyright 2008 Oliver Amft

spartlist = [];
spartindices = [];

if ~iscell(SubjectList), SubjectList = {SubjectList}; end;
if isempty(Partlist), Partlist = Repository.UseParts; end;

for snr = 1:length(SubjectList)
	for partnr = 1:length(Partlist)
		if ( strcmp(SubjectList{snr}, repos_getsubjects(Repository, Partlist(partnr))) )
			spartlist = [spartlist Partlist(partnr)];
			spartindices = [spartindices partnr];
		end;
	end;
end;

% sorting is actually a bad idea when partlist is used later for
% reference, e.g. for reffering to partoffsets
%spartlist = sort(spartlist);