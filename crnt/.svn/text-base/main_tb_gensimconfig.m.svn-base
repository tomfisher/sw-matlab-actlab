% main_tb_gensimconfig
%
% generate spotting algorithm configuration
%
% FeatureString is assumed as toolbox input signal list (including order).
% Since classes may use different signals/features an individual
% configuration file is generated for each class.

%requires
Partlist;
SimSetID;
% (TargetClasses)
% (FeatureString)



if (exist('FeatureString', 'var') ~=1)
    FeatureString = {
        'RLAaccx_value', 'RLAaccy_value', 'RLAaccz_value', ...
        'RLAgyrx_value', 'RLAgyry_value', 'RLAgyrz_value', ...
        'RLAmagx_value', 'RLAmagy_value', 'RLAmagz_value', ...
        };
end;



initmain;

fprintf('\n%s: Process data, SimSetID: %s...', mfilename, SimSetID);
fprintf('\n%s: Indices: %s', mfilename, mat2str(Partlist));

usesources = unique(fb_getsources(FeatureString));
usesystems = unique(repos_getsysfromsensor(Repository, Partlist(1), usesources));
if (length(usesystems) > 1) fprintf('\n%s: WARNING: More than one stream found.', mfilename); end;


for class = thisTargetClasses
    fprintf('\n%s: Process class %u...', mfilename, class);
    
    
    % Determine features and signal order
    filename = dbfilename(Repository, 'prefix', 'SF',  'indices', class, 'suffix', SimSetID, 'subdir', 'FEATURES', 'globalpath', Repository.Path);
    if (exist(filename)==0)
        fprintf('\n%s: File %s not found, skipping.', mfilename, filename);
        fprintf('\n'); return;
    end;
    processing = load(filename, 'FeatureString', 'DSSet');


    % load feature values
    filename = dbfilename(Repository, 'prefix', 'SIMS', 'indices', class, 'suffix', SimSetID, 'subdir', 'SPOT');
    if (exist(filename)==0)
        fprintf('\n%s: File %s not found, skipping.', mfilename, filename);
        fprintf('\n'); return;
    end;
    load(filename, 'obswindow', 'mu', 'sd', 'mythresholds', 'bestthres');

    % OAM REVISIT: Check feature sizes
    
    % create configuration file (this is generated again later!)
    filename = dbfilename(Repository, 'prefix', 'simparams',  'suffix', [SimSetID '_class' num2str(class)], ...
        'subdir', 'CRNTOOLBOX', 'globalpath', Repository.Path, 'extension', 'config');
    fprintf('\n%s: Write configuration file: %s', mfilename, filename);

    filewrite('c s', filename, ...
        '# Configuration file for the CRN Toolbox similarity algorithm', ...
        ['# File generated with ' mfilename ', at ' datestr(now)], ...
        '# (c) 2005, 2006 Oliver Amft, oam@ife.ee.ethz.ch', '');
    filewrite('a pv', filename, ...
        '# SimSetID', SimSetID, 'string', ...
        '# SampleRate', processing.DSSet.(usesystems{1}).SampleRate, 'int');

    filewrite('a s', filename, '', '# Number of classes in this instance.');
    filewrite('a pv', filename, 'CLASSES', max(size(class)), 'int');

    filewrite('a s', filename, '# Number of streaming channels.', ...
        '# Determines the number of channels extracted from data packets. Does NOT change data packets.');
    filewrite('a pv', filename, 'CHANNELS', length(FeatureString)+1, 'int');

    % class1 #xxx {
    filewrite('a s', filename, [num2str(1, 'CLASS%u') ' #' Repository.Classlist{class}], '{');

    filewrite('a s', filename, '# Name of this class.');
    filewrite('a pv', filename, 'CLASSNAME', Repository.Classlist{class}, 'string');
    filewrite('a s', filename, '# Maximum search depth (segments, MINLOOKBACK..x).');
    filewrite('a pv', filename, 'MAXLOOKBACK', obswindow(2), 'int');
    filewrite('a s', filename, '# Minimum search depth (segments, 1..MAXLOOKBACK).');
    filewrite('a pv', filename, 'MINLOOKBACK', obswindow(1), 'int');

    filewrite('a s', filename, '# Squared section distance threshold.');
    filewrite('a pv', filename, 'THRESHOLD', mean(mythresholds(bestthres))^2, 'float');


    filewrite('a s', filename, '', '', ...
        '# Feature syntax: NAME_CHANNEL=<mean>,<std>', ...
        '# CHANNEL starts at zero. NAME must match a supported feature processing method.', ...
        '');

    % determine features and convert to toolbox style
    for f = 1:length(processing.FeatureString)
        ftokens = fb_getelements(processing.FeatureString{f});
        channelno = strmatch(ftokens{1}, FeatureString);
        if (channelno) channelno = channelno - 1; end; % counted from zero!
        
        channelfeature = cell2str(ftokens(2:end), '_');
        channelvalue = [mu(f) sd(f)];

        % special cases
        switch channelfeature
            case {'LEN', 'LENGTH'}
                channelno = 0;
                channelfeature = 'LENGTH';
                %channelvalue = channelvalue ./ DSSet.(usesystems{:}).SampleRate; % this is a hack
            case 'SEGPOINTS'
                channelno = 0;
                %channelfeature = 'SEG_SEGS';
        end;

        
        filewrite('a s', filename, ['# Feature ' processing.FeatureString{f}]);
        filewrite('a pv', filename, ...
            [channelfeature '_' num2str(channelno)], channelvalue, 'float');
    end; % for f

    filewrite('a s', filename, ['}  # end of class ' num2str(1)], '', '');
end; % for class

fprintf('\n%s: Done.\n', mfilename);
