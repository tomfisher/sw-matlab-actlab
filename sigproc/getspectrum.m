function spect = get_spectrum(data)

WindowSize = length(data);
if (rem(WindowSize, 2) ~= 0) warning([mfilename ': FFT is not 2-er complement!']); end;


% Normalize this sequence
rms = sqrt(sum(data.^2) / WindowSize);
yt = data ./ rms;

% Hanning Window
yth = yt .* hanning(WindowSize);



% Calculate spectrum
spect = abs(fft(yth, WindowSize));
spect = spect(1:floor(WindowSize/2)).';

