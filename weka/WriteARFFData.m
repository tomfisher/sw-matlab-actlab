function WriteARFFData(FeatureMatrix, IndicesToConsider, ClassLabelStr, filename);
% WriteARFFData(FeatureMatrix, IndicesToConsider, ClassLabelStr, filename)
%       Append Data to .arff files in WEKA
%       FeatureMatrix is NxM with N feature vectors of class ClassLabelStr
%       and each feature vector contains M features, of which only IndicesToConsider are considered.
%       IndicesToConsider can also be 'all', in which case all M features are considered.

% Mathias Staeger, Wearable Computing Lab, ETH Zürich, Mar 2005

% test if IndicesToConsider = 'all'
if (ischar(IndicesToConsider))
    if (strcmp(IndicesToConsider,'all') | strcmp(IndicesToConsider,'All'))
        IndicesToConsider = [1:size(FeatureMatrix,2)];
    else
        error('unrecognized type for IndicesToConsider');
    end
end

% some other tests
if (~exist(filename,'file'))
    error('ARFF file %s not found\n',filename);
end

if ( max(IndicesToConsider) > size(FeatureMatrix,2) )
    error('IndicesToConsider exceeds size of FeatureMatrix');
end


fid=fopen(filename,'a');

for n=1:size(FeatureMatrix,1)
    for m=IndicesToConsider
        fprintf(fid,'%f, ', FeatureMatrix(n,m));    
    end
    fprintf(fid, '%s\n',ClassLabelStr);
end

fclose(fid);