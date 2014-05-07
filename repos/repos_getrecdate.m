function RecDate = repos_getrecdate(Repository, Partlist, varargin)
% function partfiles = repos_getrecdate(Repository, Partlist, varargin)
%
% Determine recording date&time using different methods. RecDate is
% returned in seconds (see Matlab datenum, datestr)
% 
% Option Method:
% 1. Date&time string provided in Repository.RepEntry().Recdate according
%     to ISO 8601, format 'yyyymmddTHHMMSS' (Matlab format 30, see datestr)
% 2. Date&time from keylabel file
% 3. Date&time from data files
% 4. Date&time from CRNT logfile content.
% 
% See also: repos_getpartsforevalday
% 
% Copyright 2008-2012 Oliver Amft

[Method DataType verbose] = process_options(varargin, ...
    'method', {'recentry', 'keylabel', 'datafile'}, 'DataType', '', 'verbose', 0);
if ~iscell(Method), Method = {Method}; end;
if isempty(Partlist), Partlist = Repository.UseParts; end;

if (verbose), fprintf('\n%s: Method: %s', cell2str(Method)); end;

RecDate = zeros(1, length(Partlist));
for partnr = 1:length(Partlist)
	
    % process in the order of methods listed
	for i = 1:length(Method)
		switch lower(Method{i})
			case 'recentry'
				tmp = repos_getfield(Repository, Partlist(partnr), 'Recdate');
				if isempty(tmp), continue; end;
                % changed based on bug report/fix of Martin
				%RecDate(partnr) = datenum(tmp, 30);
                RecDate(partnr) = datenum(tmp, 'yyyymmddTHHMMSS');

			case 'keylabel'
				[dummy1 dummy2 tmp] = getkeylabels(Repository, Partlist(partnr));
                if isempty(tmp), continue; end;
                RecDate(partnr) = datenum(tmp);

			case 'datafile'
				%partfiles = repos_findfilesforpart(Repository, Partlist(partnr));
                if isempty(DataType)
                    Systems = repos_getsystems(Repository, Partlist(partnr) );
                    for f = 1:length(Systems)
                        filename = repos_getfilename(Repository, Partlist(partnr), Systems{f});
                        tmp = dir(filename);
                        if ~isempty(tmp), break; end;
                    end;
                    DataType = Systems{f};
                end;
                filename = repos_getfilename(Repository, Partlist(partnr), DataType);
                tmp = dir(filename);

                %if isempty(tmp), error('Failed to find valid source file for PI %u', Partlist(partnr) ); end;
                if isempty(tmp), continue; end;
                % somehow Matlab versions/OS differences occur for dir()
                if isfield(tmp, 'datenum'),  RecDate(partnr) = tmp.datenum; end;
                if isfield(tmp, 'date'),  RecDate(partnr) = datenum(tmp.date); end;
                
            case 'crnttime' % analyse timestamp in CRNT log file
                if isempty(DataType)
                    Systems = repos_getsystems(Repository, Partlist(partnr) );
                    for f = 1:length(Systems)
                        filename = repos_getfilename(Repository, Partlist(partnr), Systems{f});
                        tmp = dir(filename);
                        if ~isempty(tmp), break; end;
                    end;
                    DataType = Systems{f};
                end;
                tmp = repos_loaddata(Repository, Partlist(partnr), DataType, 'Range', [1 1], 'Channels', {'CRNTtime'} );
                %tmp = readtextfilecols(filename, [1 inf], [1 2]);
                
                % OAM REVISIT: why divide by 1e6 here? Code was used like this for Paola's sergestudy; in NFC study not needed.
                t = round( tmp(1,1) / 1e6 );
%                t = round( tmp(1,1) );
                
                % unixsecs2date.m: expects input in seconds since Jan 1, 1970
                [year, month, day, hour, minute, second] = jd2date(t / 86400 + date2jd(1970, 1, 1));
                RecDate = datenum([year, month, day, hour, minute, second]);
                % date2unixsecs(year, month, day, hour, minute, second)

                
                
		end; % switch lower(Method{i})

		if (RecDate(partnr)~=0), break; end;
	end; % for i
end; % for partnr

if any(RecDate==0), 
    fprintf('\n%s: WARNING: Fetching recording days failed for PIs: %s.', mfilename, mat2str(Partlist(RecDate==0))); 
end;
