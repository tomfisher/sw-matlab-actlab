function [Dist,D,k,w]=dtw(t,r)
%Dynamic Time Warping Algorithm
%Dist is unnormalized distance between t and r
%D is the accumulated distance matrix
%k is the normalizing factor
%w is the optimal path
%t is the vector you are testing against
%r is the vector you are testing

% comments (http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=6516&objectType=FILE):
% 
% Another 10-fold Speed-up can be achived if you use a double-MIN construction for the Distance matrix
%
% D(n,m)=d(n,m)+min(D(n-1,m),min(D(n-1,m-1),D(n,m-1)));
%
% I think it should be better to replace the sentence: w=cat(1,w,[n,m]); by: w=[n m; w];
% In this way we get the w indexes in ascending order and it is easier to get t_warped and r_warped as:
% t_warped=t(w(:,1)); and r_warped=t(w(:,2));. In this way we can directly compare the warped sequences with 
% the original ones without any index inversion.
%
%
% The loop for m=2:m D(1,m)=d(1,m)+D(1,m-1); end contains an error ( for statement ), should be: 
% for m=2:M D(1,m)=d(1,m)+D(1,m-1); end If you want to compare vectors, where the vectors themselves are unknown, 
% but their distance matrix is known, you can use your distance matrix instead of "d"
%
% The routine can be made 10 times faster by doing the d(n,m) calculation by 
% d=(repmat(t(:),1,M)-repmat(r(:)',N,1)).^2; instead of the loop.
%



[rows,N]=size(t);
[rows,M]=size(r);
%for n=1:N
%    for m=1:M
%        d(n,m)=(t(n)-r(m))^2;
%    end
%end
d=(repmat(t(:),1,M)-repmat(r(:)',N,1)).^2; %this replaces the nested for loops from above Thanks Georg Schmitz 

D=zeros(size(d));
D(1,1)=d(1,1);

for n=2:N
    D(n,1)=d(n,1)+D(n-1,1);
end
for m=2:M
    D(1,m)=d(1,m)+D(1,m-1);
end
for n=2:N
    for m=2:M
        D(n,m)=d(n,m)+min([D(n-1,m),D(n-1,m-1),D(n,m-1)]);
    end
end

Dist=D(N,M);
n=N;
m=M;
k=1;
w=[];
w(1,:)=[N,M];
while ((n+m)~=2)
    if (n-1)==0
        m=m-1;
    elseif (m-1)==0
        n=n-1;
    else 
      [values,number]=min([D(n-1,m),D(n,m-1),D(n-1,m-1)]);
      switch number
      case 1
        n=n-1;
      case 2
        m=m-1;
      case 3
        n=n-1;
        m=m-1;
      end
  end
    k=k+1;
    w=cat(1,w,[n,m]);
end
