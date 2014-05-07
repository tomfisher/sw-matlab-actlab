% FUNCTION RET = QUAT2EULER(QUAT)
%
% This function takes a four entry vector representing the quaternion
% format of a sensor's orientation and computes the corresponding euler
% angles which are returned.
% The computation formula is taken from MTi and MTx User Manual and Tech.
% Doc., 2006, Xsens Technologies B.V., p. 10
%
% Input:   quat ... for entry quaternion vector
%
% Output:  ret ... euler angles (1st col: roll, 2nd col: pitch, 3rd col:
%                                yaw)
%
%
% T. Stiefmeier
% ETH Zurich
% 13-Dec-2006
function ret = quat2euler(quat)


q0 = quat(:,1);
q1 = quat(:,2);
q2 = quat(:,3);
q3 = quat(:,4);

ret(:,1) = atan2(2*q2.*q3+2*q0.*q1,2*q0.*q0+2*q3.*q3-1) / pi * 180;
tmp = 2*q1.*q3-2*q0.*q2;
for i=1:length(tmp)
    if (tmp(i)>1)
        tmp(i) = 1;
    elseif (tmp(i)<-1)
        tmp(i) = -1;
    end
end
ret(:,2) = -asin(tmp) / pi * 180;
ret(:,3) = atan2(2*q1.*q2+2*q0.*q3,2*q0.*q0+2*q1.*q1-1) / pi * 180;
