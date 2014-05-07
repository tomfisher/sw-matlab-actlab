function ok = textlog(text)

ok = 1;

callername = evalin('caller', 'sprintf(''%s'', mfilename)');

thistext = sprintf('%s: %s', callername, text);

ok = evalin('caller', [ 'fprintf(''\n' thistext ''');' ]);

