function [out categories] = cat2counted(in)
% function [out categories] = categories(in)
% 
% Convert category labels to counted values.

categories = unique(in);

out = zeros(length(in),1);
for n = 1:length(in)
    out(n) = find( categories == in(n) );
end;
