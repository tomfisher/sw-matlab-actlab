function [seglisteq segnumbers segmissed] = segment_compare(seglist1, seglist2)

if sum((size(seglist1) ~= size(seglist2)))
    error('Seglists have different sizes.');
end;

segnumbers = find(segment_countoverlap(seglist1, seglist2, 0) == 1);

seglisteq = seglist1(segnumbers,:); 

segmissed = [];
for seg = 1:size(seglist1,1)
    if isempty(find(segnumbers == seg))
        segmissed = [segmissed seg];
    end;
end;