function emetrics = emetrics_errormatrix(gtlist, prlist)
% function emetrics = emetrics_errormatrix(gtclass, prclass)
% 
% error matrix (historgram) of class associations between GT class and PR class
% rows (down) - GT class
% col (side) - PR class

emetrics = [];
if isempty(gtlist) || isempty(prlist), error('At least one list is empty.'); end;
if ( length(gtlist) ~= length(prlist) ), error('Lists must be equal size.'); end;

gtclasses = unique(gtlist);
prclasses = unique(prlist);

emetrics.ematrix = zeros( length(gtclasses), length(prclasses) );

for gtc = 1:length(gtclasses)
    thisclassids = (gtlist == gtclasses(gtc));
    
    for prc = 1:length(prclasses)
		emetrics.ematrix(gtc, prc) = sum(prlist(thisclassids) == prclasses(prc));
    end;
end;
