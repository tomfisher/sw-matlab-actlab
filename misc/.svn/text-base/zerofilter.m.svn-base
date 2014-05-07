function dout = zerofilter(dmatrix)
% function dout = zerofilter(dmatrix)
%
% Replace zeros in each column by previous value from the column

[nrows ncols] = size(dmatrix);

dout = dmatrix;

for col = 1:ncols
    zlist = find(dmatrix(:,col) == 0);
    if isempty(zlist) continue; end;

    if (zlist(1)==1) zlist = zlist(2:end); end;
    zlistr = zlist -1;
    
    %if (verbose) fprintf('\n%s: Correct data at %u positions.', mfilename, max(size(zlist))); end;
    
    dout(zlist, col) = dmatrix(zlistr, col);
end;
