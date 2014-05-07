% initmain_segconfig
% 
% Configure/guess segmentation mode configuration per class
% 
% SegmentationMode syntax: 
% 1. <mode>_<parameters>
% 2. <mode>
% 
% See also: initmain_segconfig_setup
% 
% requires
Repository;
thisTargetClasses;


if exist('SegConfig','var'), 
    error('Old code! Adjust your configuration to use SegmentationMode instead of SegConfig.');
end;

if ~exist('SegmentationMode', 'var'), SegmentationMode = {'unknown'}; end;
if ~iscell(SegmentationMode), SegmentationMode = {SegmentationMode}; end;

for classnr = 2:length(thisTargetClasses)
    if length(SegmentationMode) < classnr, SegmentationMode{classnr} = SegmentationMode{classnr-1}; end;
    
end;
    


% if ~isfield(SegConfig, 'Name'), SegConfig.Name = 'FIX'; end;
% if ~isfield(SegConfig, 'Mode'), SegConfig.Mode = ''; end;
% 
% fnstrs = fieldnames(SegConfig);
% for classnr = 2:length(thisTargetClasses)
%     % check whether structs exist for other classes, create, copy Name field
%     if (length(SegConfig)<classnr), SegConfig(classnr).Name = SegConfig(1).Name; end;
% 
%     % copy all fields
%     for fn = 1:length(fnstrs)
%         if isempty(SegConfig(classnr).(fnstrs{fn})), SegConfig(classnr).(fnstrs{fn}) = SegConfig(1).(fnstrs{fn}); end;
%     end;
% 
%     % special handling of FIX group
% % 	if strcmpi(SegConfig(classnr).Name(1:3), 'FIX') && (~isfield(SegConfig, 'Mode')), SegConfig(classnr).Mode = '';
% 	if (isempty(SegConfig(classnr).Mode')) && (strcmpi(SegConfig(classnr).Name(1:4), 'SWAB'))
% 		fprintf('\n%s: WARNING: Configuring SegConfig Mode from Repository struct!', mfilename);
% 		SegConfig(classnr).Mode = Repository.SegModeList{thisTargetClasses(classnr)};
% 	end;
% end;
% % for classnr = 1:length(thisTargetClasses)    
% % 	fprintf('\n%s: Class %u: Segmentation: %s, Mode: ''%s''', mfilename, ...
% % 		thisTargetClasses(classnr), SegConfig(classnr).Name, SegConfig(classnr).Mode);
% % end;
