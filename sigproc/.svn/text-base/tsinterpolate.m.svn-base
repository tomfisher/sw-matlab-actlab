function [IData isig] = tsinterpolate(Data, varargin);

[LostsamplesCounter InsertNans verbose] = process_options(varargin, ...
	'LostsamplesCounter', [], 'InsertNans', false, 'verbose', 0);

[nsamples ncols] = size(Data);

%% mode: LostsamplesCounter
if (~isempty(LostsamplesCounter))
	%LostsamplesCounter = LostsamplesCounter - LostsamplesCounter(1)+1;
	if (diff(LostsamplesCounter) < 0) error('LostsamplesCounter not monotone increasing.'); end;
    
	IData = nan(nsamples+sum(diff(LostsamplesCounter)), ncols);
	isig = nan(nsamples+sum(diff(LostsamplesCounter)), 1);
	
	missingpos = [0; col(diff(LostsamplesCounter))];

%% copy & insert missings
	IData(1,:) = Data(1,:);
	isig(1) = 0;
    iold = 2;
	for i = 2:size(IData,1)
		if (missingpos(iold))
			if (InsertNans==false)
				% insert artificial samples
				IData(i,:) = Data(iold-1,:);
			end;
			missingpos(iold) = missingpos(iold) -1;
			isig(i) = 1;

		else
			
			% simple copy
			IData(i,:) = Data(iold,:);
			isig(i) = 0;
			iold = iold + 1;
		end;
	end;
%%
	return;
end; % (~isempty(LostsamplesCounter))

