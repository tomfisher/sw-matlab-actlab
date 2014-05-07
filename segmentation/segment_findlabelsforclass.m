function classlabels = segment_findlabelsforclass(seglist, classlist)
% function classlabels = segment_findlabelsforclass(seglist, classlist)
%
% Return labels for a specific classes. Return 0x6 vector if no labels where found.
%
%
% WARNING: Result should be resorted iff length(classlist)>1 
%
%    - not done  here. Don't remember why.
% 
% Copyright 2005-2008 Oliver Amft

% OAM REVISIT: change to cla_findlabelsforclass !

if iscell(seglist)
	classlabels =cell(1, length(seglist));
	for i = 1:length(seglist)
		if isempty(seglist{i})
			classlabels{i} = [];
		else
			for classnr = 1:length(classlist)
				thisclass = classlist(classnr);
				classlabels{i} = [classlabels{i}; seglist{i}(seglist{i}(:,4) == thisclass,:)];
			end;
		end;

		if length(classlist)>1, classlabels{i} = segment_sort(classlabels{i}); end;
	end; % for i
	return;
end;

classlabels = [];
if isempty(seglist), return; end;

% plain seglist, no cell arrays
for classnr = 1:length(classlist)
	thisclass = classlist(classnr);
	classlabels = [classlabels; seglist(seglist(:,4) == thisclass,:)];
end;

if length(classlist)>1, classlabels = segment_sort(classlabels); end;

