function initstruct = tmsi_init(ph)

initstruct = [];

TMSIF_CMD_FRONTENDINFO = uint8(hex2dec('02'));
TMSIF_CMD_FRONTENDINFO_DATA = uint16(hex2dec({ '000e' '0000' '0003'}));

% need to stop previous transfer, if any
% do this by emptying receive queue after sending data stop command
LastAckTime = tmsif_sendpacket(ph, TMSIF_CMD_FRONTENDINFO, TMSIF_CMD_FRONTENDINFO_DATA);
serial_clearrxbuffer(ph);
LastAckTime = tmsif_sendpacket(ph, TMSIF_CMD_FRONTENDINFO, TMSIF_CMD_FRONTENDINFO_DATA);
%packet = tmsif_receivepacket(ph, 'nonblocking', true);
packet = tmsif_receivepacket(ph);

tmsif_dumppacket(packet);

% start measurement data transfer

