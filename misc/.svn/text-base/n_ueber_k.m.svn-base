function p = n_ueber_k(n,k)
% N_UEBER_K(n,k) returns the result of N choose K.

% georg:::csn:::umit, summer 2005

if n<k, error('n must be bigger than k');
elseif (k == 0 | k == n) p = 1;
elseif (k == 1 | k == n-1) p = n;
else p = gamma(n+1)/(gamma(k+1)*gamma((n-k)+1));
end