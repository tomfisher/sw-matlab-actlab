function fh = fsmetrics_plotscree(variances, varargin)

percent_explained = (variances/sum(variances) * 100);

fh = figure;
pareto(percent_explained);
xlabel('Principal Component');
ylabel('Variance Explained [%]');
