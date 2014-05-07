function packet = tmsif_receivepacket(ph, varargin)

packet = [];
Nonblocking = process_options(varargin, 'nonblocking', false);

TMSIF_PACKETSYNC = uint16(hex2dec('aaaa'));

% check for available characters
if (Nonblocking)
	if (~get(ph, 'BytesAvailable'))
		pause(0.1); return;
	end;
else
	% 	readcount = get(ph, 'BytesAvailable');
end;

% wait for sync
while (fread(ph, 1, 'uint16') ~= TMSIF_PACKETSYNC); end;

thischecksum = typecast(uint16(TMSIF_PACKETSYNC), 'int16');

% read blocktype and length
try tmp = fread(ph, 1, 'uint16');
catch error('fread failed.'); end;
packet.blocktype = uint8(bitshift(tmp, -8));
packet.length = uint8(bitand(tmp, hex2dec('FF')));
thischecksum = thischecksum + typecast(uint16(tmp), 'int16');
if (packet.length == hex2dec('FF'))
	try  packet.length = fread(ph, 1, 'uint16');
	catch error('fread failed.'); end;
	thischecksum = thischecksum + typecast(uint16(packet.length), 'int16');
end;

% read data
packet.data(packet.length) = uint16(0);
for i = 1:packet.length
	try packet.data(i) = fread(ph, 1, 'uint16');
	catch error('fread failed.'); end;

	thischecksum = thischecksum + typecast(uint16(packet.data(i)), 'int16');
end;

% checksum test
try packet.checksum  = fread(ph, 1, 'uint16');
catch error('fread failed.'); end;
thischecksum = thischecksum + typecast(uint16(packet.checksum), 'int16');
if (thischecksum)
	fprintf('\n%s: Packet checksum test failed, checksum=%s.', mfilename, ...
		dec2hex(typecast(uint16(thischecksum), 'uint16')));
	%tmsif_dumppacket(packet);
end;


