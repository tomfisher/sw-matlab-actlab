function emetrics = emetrics_finderrors(trueclass, predictedclass)

classes = max(trueclass);

for gtclass = 1:classes
    thisclassidx = (trueclass == gtclass);
    
    for prclass = 1:classes
        emetrics.(['gtclass' num2str(gtclass)]).(['class' num2str(prclass)]) = ...
            find(predictedclass(thisclassidx) == prclass);
    end;
end;

% .(['class' num2str(prclass)])
% ~