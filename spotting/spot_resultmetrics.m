function [classmetrics SimSetID_List] = spot_resultmetrics(SpotType, Subject, fidxel, spotclass, varargin)
% function [classmetrics SimSetID_List] = spot_resultmetrics(SpotType, Subject, fidxel, spotclass, varargin)
% 
% Compile spot result from spotting runs in one cell array.

% Copyright 2008 Oliver Amft

if length(spotclass)>1, spotclass = spotclass(1); fprintf('\n%s: WARNING: Only one class support.', mfilename); end;

[SavePNG LabelConfThres section_jitter] = process_options(varargin, ...
	'SavePNG', false, 'LabelConfThres', 1, 'section_jitter', 0.5);

classmetrics = [];
SimSetID_List = cell(1, length(fidxel));

for i = 1:length(fidxel)
	SimSetID = [Subject fidxel{i}];
	fn = spot_isfile(SpotType, SimSetID, spotclass);
	if isempty(fn) || iscell(fn)
		fprintf('\n%s: Spot file not found for SimSetID: %s.', mfilename, SimSetID);
		continue; 
	end;
	
	try
		fprintf('\n%s: Loading %s...', mfilename, fn);
		classmetrics = [ classmetrics sandbox('main_spotsweep', ...
			'in', {'SimSetID', SimSetID, 'SpotType', SpotType, 'thisTargetClasses', spotclass, ...
			'LabelConfThres', LabelConfThres, 'section_jitter', section_jitter}, 'out', {'classmetrics'}) ];
	catch
		continue;
	end;

	SimSetID_List{i} = SimSetID;
end;

% classmetrics(isemptycell(classmetrics)) = [];
SimSetID_List(isemptycell(SimSetID_List)) = [];

% save picture
if (SavePNG) && ~isempty(fidxel{1}) && ~any(isemptycell(SimSetID_List))
	fh = prmetrics_plotpr('view2', [], classmetrics{:});
	
	% filename guessing is a hack
	filename = [ Subject fidxel{1}(1:end-1) '-' num2str(spotclass) ];
	fprintf('\n%s: Saving PR diagram to %s', mfilename, filename);
	plotfmt(fh, 'ti', cell2str(SimSetID_List, ', '), 'prpng', filename );
	delete(fh);
end;
