function filename = WriteARFFHeader(FeatureString, ClassString, filename);
% WriteARFFHeader(FeatureString, ClassString, filename)
%       Create Header for .arff files in WEKA

% Mathias Staeger, Wearable Computing Lab, ETH Zurich, Mar 2005
% Oliver Amft, Wearable Computing Lab, ETH Zurich, Jun 2006

% use filename provided or create a temp file
if (exist('filename')~=1) | isempty(filename)
    [tfdir tfname] = fileparts(tempname);
    filename = [tfdir filesep 'wekadata_' tfname '.arff'];
    if exist(filename) delete(filename); end;
end;

fid=fopen(filename,'w');

fprintf(fid, '%% ARFF file created by WriteARFFHeader.m script\n');
fprintf(fid, '%% Date:   %s\n\n', datestr(now,0));

fprintf(fid, '@RELATION eval-classes \n\n');

for i=1:max(size(FeatureString))
    fprintf(fid, '@ATTRIBUTE %s real\n',FeatureString{i});
end
fprintf(fid, '@ATTRIBUTE class {');

for i=1:max(size(ClassString))
    fprintf(fid, '%s',ClassString{i});
    if i<max(size(ClassString))
        fprintf(fid,', ');
    else
        fprintf(fid, '}\n');
    end
end
fprintf(fid, '\n');
fprintf(fid, '@DATA\n');
%%END of ARFF Header
fclose(fid);
