function [eulermat gimbalcomp]=rot2eul(rotmat, mode)
% function [eulermat gimbalcomp]=rot2eul(rotmat, mode)
% 
% Compute Euler angles from rotation matrix: phi theta psi (roll, pitch, yaw)
% 
% See: http://en.wikipedia.org/wiki/Flight_dynamics
%
% rotmat:
%  1      2      3      4      5      6      7      8      9
%'r11', 'r12', 'r13', 'r21', 'r22', 'r23', 'r31', 'r32', 'r33'
% 
% Copyright 2005-2006 Oliver Amft

if (nargin < 2)
    mode = 'GIMBALCOMP';
end;

% OAM REVISIT: gimbal lock mechanism
mode = 'NOGIMBALGCOMP';

for col=[1 9] %{'r33', 'r11'}
    toosmall = abs(rotmat(:,col)) < 1e-8;
    rotmat(toosmall,col) = 1e-8;
end;

phi=atan(rotmat(:,6)./rotmat(:,9));
theta=asin(-rotmat(:,3));
psi=atan(rotmat(:,2)./rotmat(:,1));

phi=rad2deg(phi);     % roll (x): 180/pi*angle
theta=rad2deg(theta); % pitch (y)
psi=rad2deg(psi);     % yaw/heading (z)

% phi = repair_angle(phi, 85, 180);
% psi = repair_angle(psi, 85, 180);

% OAM REVISIT: Verify this code
if (strcmp(upper(mode), 'GIMBALCOMP'))
    index = sort(find(abs(theta) > 85));
    if (index(1) == 1)
        index = index(2:end);
        warning('xsens:rot2eul', 'Could not compensate gimbal lock');
    end;
    phi(:,index) = phi(:,index-1);
    psi(:,index) = psi(:,index-1);
    theta(:,index) = sign(theta(:,index))*85;
    gimbalcomp = length(index);
end;

eulermat = [phi theta psi];
