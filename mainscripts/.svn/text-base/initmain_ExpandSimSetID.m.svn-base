% initmain_ExpandSimSetID
%
% Configures SimSetID_List, DoDeleteSimSetID_List

if ~exist('SimSetID_List','var')
	% SimSetID_List can be self-expanding, e.g.:  Expand_SimSetID_List = '{[Subject ''TEST1''], [Subject ''TEST2'']}';
	% OR set from SimSetID (merging spotters from multiple classes)
	if exist('Expand_SimSetID_List', 'var'),
		SimSetID_List = eval(Expand_SimSetID_List);
	else
		SimSetID_List = {SimSetID};
	end;
	DoDeleteSimSetID_List = true;
else
	DoDeleteSimSetID_List = false;
end;
