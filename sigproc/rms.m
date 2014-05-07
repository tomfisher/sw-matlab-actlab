function rmsval = rms(yt)

rmsval = sqrt(sum(yt.^2) ./ length(yt));
