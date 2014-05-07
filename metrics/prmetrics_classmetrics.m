function classmetrics = prmetrics_classmetrics(prmetrics)
% function classmetrics = prmetrics_classmetrics(prmetrics)
%
% Combine PR performance metric structs to class results
% 
% Copyright 2007 Oliver Amft

if length(prmetrics(1).relevant) ~= 2
    error('Procedure works on 2-class problems only!');
end;

for idx = 1:length(prmetrics)
    classmetrics(idx).tp = prmetrics(idx).recognised(1); 
    classmetrics(idx).tn = prmetrics(idx).recognised(2);
    classmetrics(idx).fp = prmetrics(idx).insertions(1); 
    classmetrics(idx).fn = prmetrics(idx).deletions(1); 
    classmetrics(idx).p  = classmetrics(idx).tp + classmetrics(idx).fn;
    classmetrics(idx).n  = classmetrics(idx).tn + classmetrics(idx).fp;
    
    classmetrics(idx).relevant = prmetrics(idx).relevant;
    classmetrics(idx).retrieved = prmetrics(idx).retrieved;
    classmetrics(idx).recognised = prmetrics(idx).recognised;
    
    classmetrics(idx).accuracy = sum(classmetrics(idx).recognised) / sum(classmetrics(idx).retrieved);

    classmetrics(idx).normacc = 0.5*(...
        classmetrics(idx).tp/(classmetrics(idx).p) + ...
        classmetrics(idx).tn/(classmetrics(idx).n));
    
    classmetrics(idx).confusion = [ ...
        classmetrics(idx).tp, classmetrics(idx).fn; ...
        classmetrics(idx).fp, classmetrics(idx).tn];
end;
