function prmetric = prmetrics_estimatethresholds(conf)
% function prmetric = prmetrics_estimatethresholds(segments_EVAL)
%
% Estimate evaluation thresholds from actual distance/confudence values
% 
% WARNING: Works for confidences only
PDFRes = 100;
PRPoints = PDFRes;

cr = [min(conf) max(conf)];
[h ph] = hist(conf, PDFRes);
nh = h/sum(t);

%df = max(nh)-nh;
df = (max(nh)-nh)/max(nh);


cf = df/sum(df);


