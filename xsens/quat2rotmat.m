% FUNCTION  RET = QUAT2ROTMAT(QUAT)
%
% This function takes a matrix containing orientation data in quaternion
% format (4 values per row) and transforms this data into the rotation
% matrix format (a 3by3 matrix for each quaternion row).
%
% T. Stiefmeier
% ETH Zurich
% 11-Dec-2006
function ret = quat2rotmat(quat)

q0 = quat(:,1);
q1 = quat(:,2);
q2 = quat(:,3);
q3 = quat(:,4);


% ret(:,1,1) = 2*q0.*q0 + 2*q1.*q1 - 1;
% ret(:,1,2) = 2*q1.*q2 - 2*q0.*q3;
% ret(:,1,3) = 2*q1.*q3 + 2*q0.*q2;
% 
% ret(:,2,1) = 2*q1.*q2 + 2*q0.*q3;
% ret(:,2,2) = 2*q0.*q0 + 2*q2.*q2 - 1;
% ret(:,2,3) = 2*q2.*q3 - 2*q0.*q1;
% 
% ret(:,3,1) = 2*q1.*q3 - 2*q0.*q2;
% ret(:,3,2) = 2*q2.*q3 + 2*q0.*q1;
% ret(:,3,3) = 2*q0.*q0 + 2*q3.*q3 - 1;



ret(:,1,1) = 2*q0.*q0 + 2*q1.*q1 - 1;
ret(:,2,1) = 2*q1.*q2 - 2*q0.*q3;
ret(:,3,1) = 2*q1.*q3 + 2*q0.*q2;

ret(:,1,2) = 2*q1.*q2 + 2*q0.*q3;
ret(:,2,2) = 2*q0.*q0 + 2*q2.*q2 - 1;
ret(:,3,2) = 2*q2.*q3 - 2*q0.*q1;

ret(:,1,3) = 2*q1.*q3 - 2*q0.*q2;
ret(:,2,3) = 2*q2.*q3 + 2*q0.*q1;
ret(:,3,3) = 2*q0.*q0 + 2*q3.*q3 - 1;
