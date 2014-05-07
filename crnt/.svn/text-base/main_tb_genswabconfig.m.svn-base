% main_tb_genswabconfig
%
% generate a SWAB algorithm configuration file

% requires
Partlist;
% (FeatureString)
% (DSSet)
% (SWABConfig)
% (SWABConfigMaxbuffer)

dataoffset_margin = 1.2;


if (exist('SWABConfigMaxbuffer','var') ~=1) SWABConfigMaxbuffer = 500; end;

if (exist('SWABConfig','var')~=1)
    fprintf('\n%s: No SWAB configured.', mfilename);
    clear SWABConfig;
    SWABConfig(1).method = 'LR_SS';    SWABConfig(1).maxcost = 50;     % 1st level
    SWABConfig(2).method = 'SIM_RSLP'; SWABConfig(2).maxcost = 0.1;   % 2nd level
end;

if (exist('FeatureString') ~=1)
    FeatureString = { 'RLAgyrx_value'  };
end;

if (exist('DSSet', 'var') ~=1)
    DSSet.EMG.SampleRate = 128;
    DSSet.WAV.SampleRate = 4096;
    DSSet.XSENS.SampleRate = 100;
end;


NoConfig = true;
initmain;

fprintf('\n%s: Process config for subject %s...', mfilename, Subject);
Partlist = repos_getpartsforsubject(Repository, Repository.UseParts, Subject);
fprintf('\n%s: Indices: %s', mfilename, mat2str(Partlist));

usesources = unique(fb_getsources(FeatureString));
usesystems = unique(repos_getsysfromsensor(Repository, Partlist(1), usesources));
if (isempty(usesystems)) error('Nothing to do!'); end;

% SampleRate = cla_getmarkersps(Repository, Partlist(1), 'singlesps', true);
SampleRate = DSSet.(usesystems{:}).SampleRate;

datasize = sum(cla_getpartsize(Repository, Partlist, 'SampleRate', SampleRate, 'OffsetMode', false));

% fetch SWAB information
SegMode = cell2str(FeatureString, '-');
% SWABseglist = cla_getsegmentation(Repository, Partlist, 'SampleRate', SampleRate, 'SegMode', SegMode);

% create file
filename = dbfilename(Repository, 'prefix', 'swabparams',  'suffix', SegMode, ...
    'subdir', 'CRNTOOLBOX', 'globalpath', Repository.Path, 'extension', 'config');
fprintf('\n%s: Write config file: %s...', mfilename, filename);

try
    filewrite('c s', filename, ...
        '# Configuration file for the SWAB algorithm', ...
        ['# File generated with ' mfilename ', at ' datestr(now)], ...
        '# (c) 2005, 2006 Oliver Amft, oam@ife.ee.ethz.ch', '');
catch
    fprintf('\n%s: Could not write file, terminating.', mfilename);
    return;
end;

filewrite('a pv', filename, ...
    '# Partlist', mat2str(Partlist), 'string', ...
    '# FeatureString', cell2str(FeatureString, ', '), 'string', ...
    '# Datasize', datasize, 'int', ...
    '# SampleRate', SampleRate, 'int');

filewrite('a s', filename, ...
    '# Maximum size of (bottum up) buffer in samples.', ...
    '# Must be an even number (also defines maximum latency).');
filewrite('a pv', filename, 'SWAB_MAX_BUFFER', SWABConfigMaxbuffer, 'int');

filewrite('a s', filename, ...
    '# Number of segments in the buffer.', ...
    '# Segments above this threshold are removed from the buffer.');
filewrite('a pv', filename, 'SWAB_MAX_SEGMENTS', 5, 'int');

filewrite('a s', filename, ...
    '# Samplesize of initial segment guess.', ...
    '# Segments of this size are added to the BU buffer.');
filewrite('a pv', filename, 'SWAB_SLIDING_WINDOW_STEP', 10, 'int');

filewrite('a s', filename, ...
    '# Number of segments that are removed from BU buffer per cycle.', ...
    '# This should be set to one.');
filewrite('a pv', filename, 'SWAB_SEGMENTS_PER_CYCLE', 1, 'int');

filewrite('a s', filename, ...
    '# Set channel number of the inport to use for segmentation.', ...
    '# Channels are counted from zero, excluding two timestamp channels.');
filewrite('a pv', filename, 'SWAB_CHANNEL_TO_SEGMENT', 0, 'int');

filewrite('a s', filename, ...
    '# Maximum cost for linear regression step (first algorithm method).', ...
    '# This value is automatically adapted using DATA_IN_SCALEFACTOR, see below.');
filewrite('a pv', filename, 'SWAB_MAXCOST', SWABConfig(1).maxcost, 'float');

if test('SWABConfig(2)')
    filewrite('a s', filename, ...
        '# Maximum cost for segment slope deviation step (second algorithm method).', ...
        '# To disable this algorithm method, remove/comment the parameter line below.');
    filewrite('a pv', filename, 'SLOPE_MAXCOST', SWABConfig(2).maxcost, 'float');
end;


% load data and analyse it
DataStruct = makedatastruct(Repository, Partlist, FeatureString, DSSet);
thisfeatures = makefeatures([1 datasize], DataStruct, 'swmode', 'cont');
dataoffset = ceil(-min(thisfeatures) * dataoffset_margin);
thisfeatures = thisfeatures + dataoffset;
datascale = roundf((2^16-1) / max(thisfeatures * dataoffset_margin),1);

filewrite('a s', filename, ...
    '# Input data offset to obtain non-negative numbers.');
filewrite('a pv', filename, 'DATA_IN_OFFSET', dataoffset, 'float');

filewrite('a s', filename, ...
    '# Input data scale factor to obtain value range 16Bit (0..65535).');
filewrite('a pv', filename, 'DATA_IN_SCALEFACTOR', datascale, 'float');

fprintf('\n%s: Attention: SWAB_CHANNEL_TO_SEGMENT must be adapted manually.\n', mfilename);
fprintf('\n%s: Done.\n', mfilename);
