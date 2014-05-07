function [P,N] = intersect_two_spheres(M1,M2,R1,R2)

%function INTERSECT_SPHERES(M1,M2,R1,R2) takes as input arguments 
% two spheres defined by their centers M1, M2 and their radii R1, R2. The 
% output is a planar space defined by a Point P and a vector N which is 
% orthogonal to the planar space. The (circular) intersection of the 
% two spheres is element of this planar space.

% georg:::csn:::umit, summer 2004

if nargin ~= 4, error('Wrong number of inputs.'); end
if prod(size(M1)) ~= 3, error('Wrong input type.'); end
if prod(size(M2)) ~= 3, error('Wrong input type.'); end
if ~isscalar(R1) , error('Wrong input type.'); end
if ~isscalar(R2) , error('Wrong input type.'); end

[R,I]=sort([R1,R2]);

if ~isequal(size(M1),size(M2)), M2=M2'; end
N = M2-M1;

nN = norm(N);
I = R(2)+R(1);
K = R(2)-R(1);

if nN > I | nN <= K, error('Spheres do not intersect.'); end

if R(1) == R1
    P = M2 - 0.5 * (1 + (I*K)/(nN*nN)) * N;
else
    P = M1 + 0.5 * (1 + (I*K)/(nN*nN)) * N;
end

if nN ~= I
    N = N/nN;
else
    N = [0 0 0];
end