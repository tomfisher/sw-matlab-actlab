% function ok = spot_convertfiles(SpotType, filenames)
% 
% Convert SPOT files from old cell array struct to individual variables
% 
% New format:
%   trainSegBest/testSegBest - Cell list (CV) with section result of best threshold eval, including distance in col 6 
%   trainSegMax/testSegMax - Cell list (CV) with section result of max threshold eval, including distance in col 6 
% 
% See also: spot_isfile, spot_resultmetrics, spot_converthresarrays

ok = false;
VERSION = '002';
fprintf('\n%s: VERSION: %s', mfilename, VERSION);

if ~exist('SpotType', 'var') || isempty(SpotType), SpotType = 'SIMS'; end;
if ~exist('DoSave', 'var') , DoSave = false; end;
fprintf('\n%s: DoSave=%s', mfilename, mat2str(DoSave));

if ~exist('filenames', 'var') || isempty(filenames)
	filenames = dbfilename([], 'prefix', SpotType, 'indices', '*', 'subdir', 'SPOT');
end;
if ~iscell(filenames)
	searchfilenames = filenames;
	filenames = findfiles(filenames, 'notfoundmode', 'empty', 'returnmode', 'all');
end;
if isempty(filenames) || ~iscell(filenames)
	fprintf('\n%s: WARNING: Could not find any files matching %s', mfilename, searchfilenames); 
	return; 
end;

for fn = 1:length(filenames)
	fprintf('\n%s: Processing %s...', mfilename, filenames{fn});
	spotfile = load(filenames{fn});
	if ~isfield(spotfile, 'trainSeg'), fprintf(' Not an old file, skipping.'); continue; end;
	
	[spotfile.trainSegBest spotfile.trainSegMax spotfile.testSegBest spotfile.testSegMax] = spot_converthresarrays(...
		spotfile.trainSeg, spotfile.trainDist, spotfile.testSeg, spotfile.testDist, spotfile.bestthres, spotfile.CVFolds);
	
	spotfile = rmfield(spotfile, { 'trainSeg', 'trainDist', 'testSeg', 'testDist' });
	spotfile = rmfield(spotfile, { 'metrics_train' });	
	
	if (DoSave)
		spotfile.SaveTime = clock;  	
		spotfile.Creator = mfilename;  spotfile.VERSION = VERSION;
		fprintf(' saving...');
		save(filenames{fn}, '-struct', 'spotfile');
		fprintf(' Done.')
	end;

end; % for fn
if ~DoSave, fprintf('\n%s: Simulation only. Set DoSave=true to write files.', mfilename); end;
fprintf('\n');
ok = true;
