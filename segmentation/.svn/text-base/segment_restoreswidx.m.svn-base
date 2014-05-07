function listout = segment_restoreswidx(listin, WindowSize, WindowStep)
% function listout = segment_restoreswidx(listin, WindowSize, WindowStep)
%
% Restore segment labels for original data after a sliding window filter
% Test case: WindowStep = 1; will return input
% 
% Copyright 2006 Oliver Amft

listout = [];
if isempty(listin), return; end;

% listout = [(listin(:,1)-1)*WindowStep (listin(:,2)-1)*WindowStep + WindowSize-1];
listout = [(listin(:,1)-1)*WindowStep+1 ((listin(:,2)-1)*WindowStep)+WindowStep];

% OAM REVISIT: Is this really correct?
% listout(end,2) = listout(end,2) + WindowSize; % last segment is larger

% add remaining information from listin
if size(listin,2) > 2
	listout = [ listout listin(:,3:end) ];
	listout(:,3) = segment_size(listout);
end;



% for idx = 1:size(listin,1)
%     listout(idx,:) = [ ...
%         (listin(idx,1)-1)*WindowStep  (listin(idx,2)-1)*WindowStep + WindowSize-1 ];
% end;
