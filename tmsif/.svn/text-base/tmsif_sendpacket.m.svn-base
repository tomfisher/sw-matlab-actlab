function [sendtime bytesent] = tmsif_sendpacket(ph, command, data)

% command: uint8 device command
% data: uint16 array
sendtime = [];

data =col(data);

TMSIF_PACKETSYNC = hex2dec('aaaa');

packetbuffer(size(data,1)+3) = uint16(0);

% transmission order: first low byte, second high byte
packetbuffer(1:2) = [ TMSIF_PACKETSYNC; ...
	bitor(bitshift(uint16(command),8), bitand(uint16(size(data,1)), hex2dec('FF')))];
packetbuffer_count = 2;
packetbuffer(packetbuffer_count+1:packetbuffer_count+size(data,1)) = data;
packetbuffer_count = packetbuffer_count+size(data,1);

% compute and add checksum
checksum = bitcmp(uint16(sum(packetbuffer)))+1; %1-int16(sum(packetbuffer));
packetbuffer(packetbuffer_count+1) = checksum;
packetbuffer_count = packetbuffer_count + 1;

% send out packet
try
	bytesent = fwrite(ph, packetbuffer(1:packetbuffer_count), 'uint16');

	fprintf('\n%s: send: ', mfilename);
	tmsif_dumppacket(packetbuffer(1:packetbuffer_count));
catch
	error('Problems when writing to port.');
end;

sendtime = clock;