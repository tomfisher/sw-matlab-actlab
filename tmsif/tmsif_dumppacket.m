function tmsif_dumppacket(packet)
% function tmsif_dumppacket(packet)
% 
% Dump a TMSIF packet to the console. Either packet buffer or packet
% structure can be supplied. When packet structure is used fields
% blocktype and data are used.

if isstruct(packet)
	% analyse packet struct
	fprintf('\n%s: Blocktype: %s, Length: %u', mfilename, dec2hex(packet.blocktype), length(packet.data));
	if isfield(packet, 'checksum') 	
		fprintf('\n%s: Checksum: %s', mfilename, dec2hex(typecast(packet.checksum, 'uint16'))); 
	end;
	packetbuffer = packet.data;
else
	% no struct = buffer only
	packetbuffer = packet;
end;

% dump buffer
fprintf('\n%s: Packet buffer:', mfilename);
for i = 1:length(packetbuffer)
	tmp = dec2hex(packetbuffer(i),4); % uint16

	% transmission order: first low byte, second high byte
	fprintf(' %s %s', tmp(3:4), tmp(1:2));
end;
fprintf('\n');
