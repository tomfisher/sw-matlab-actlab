% main_simsweep
%
% Call script with different parameter settings
% 
% see also: main_allsim, main_simbatch

% requires
main_simsweep_RunFun;
main_simsweep_ParamName;
main_simsweep_ParamVals;

% if ~exist('main_simsweep_SimSetID', 'var'), main_simsweep_SimSetID = SimSetID; end;
main_simsweep_SimSetID = SimSetID;

for main_simsweep_i = 1:length(main_simsweep_ParamVals)
	eval([main_simsweep_ParamName '= main_simsweep_ParamVals(main_simsweep_i) ;']);
	
	SimSetID = [main_simsweep_SimSetID 'sweep' num2str(main_simsweep_i)];

	if ~test(main_simsweep_RunFun)
		fprintf('\n');
		errorprinter(lasterror, 'DoWriteFile', false);
		break;
	end;
end;


% testing
if (0)
	main_simsweep_RunFun = 'main_dummysim';
	main_simsweep_ParamName = 'mydummy';
	main_simsweep_ParamVals = 10:14;
	main_simsweep;
end;