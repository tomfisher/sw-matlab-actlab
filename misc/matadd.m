function newmat = matadd(oldmat, addmat)

[rows cols] = size(oldmat);
[arows acols] = size(addmat);
newmat = zeros(rows, cols);

if (arows > rows) | (acols > cols)
   fprintf('\n%s: Matrix to add (%s) is larger than basis (%s)', mfilename, ...
       mat2str([arows acols]), mat2str([rows cols]));
   warning('');
end;

for i = 1:rows
    for j = 1:cols
        if (i <= arows) & (j <= acols)
            newmat(i,j) = oldmat(i,j) + addmat(i,j);
        else
            newmat(i,j) = oldmat(i,j);
        end;
    end;
end;