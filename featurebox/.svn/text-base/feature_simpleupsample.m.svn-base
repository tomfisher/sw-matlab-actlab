function result = feature_simpleupsample(sdata, oldrate, newrate)
% function result = feature_simpleupsample(sdata, oldrate, newrate)
% 
% Very simple upsample function, repeating values at new positions

% oldrate newrate 
%   1        128
%  64        128

[upsampleratio q] = rat(newrate/oldrate);
if (q > 1), error('Sample ratio is not supported.'); end;


result = [];
for i = 1:size(sdata,1)
    result = [result; repmat(sdata(i,:), upsampleratio,1)];
end;