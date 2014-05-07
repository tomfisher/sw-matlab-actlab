function yout = smooth(yin,N)

% SMOOTH.M: Smooths vector data.
%			YOUT=SMOOTH(YIN,N) smooths the data in YIN using a running mean
%			over 2*N+1 successive point, N points on each side of the
%			current point. At the ends of the series skewed or one-sided
%			means are used.

%			Olof Liungman, 1997
%			Dept. of Oceanography, Earth Sciences Centre
%			Göteborg University, Sweden
%			E-mail: olof.liungman@oce.gu.se

if nargin<2, error('Not enough input arguments!'), end

[rows,cols] = size(yin);
if min(rows,cols)~=1, error('Y data must be a vector!'), end
if length(N)~=1, error('N must be a scalar!'), end

yin = (yin(:))';
l = length(yin);
yout = zeros(1,l);
temp = zeros(2*N+1,l-2*N);
temp(N+1,:) = yin(N+1:l-N);

for i = 1:N
  yout(i) = mean(yin(1:i+N));
  yout(l-i+1) = mean(yin(l-i-N:l));
  temp(i,:) = yin(i:l-2*N+i-1);
  temp(N+i+1,:) = yin(N+i+1:l-N+i);
end

yout(N+1:l-N) = mean(temp);

if size(yout)~=[rows,cols], yout = yout'; end
