function element = findseqelement(list, searchelement, varargin)

[Mode, Count, Direction verbose] = process_options(varargin, ...
	'mode', 'gt', 'N', inf, 'direction', 'first', 'verbose', 1);

switch lower(Mode)
    case 'lt' %less
        element = 1;
        for i = 1:length(list)
            if ( searchelement > list(i) ), break; end;
            element = element + 1;
        end;
    case 'gt'
        element = 1;
        for i = 1:length(list)
            if ( searchelement < list(i) ), break; end;
            element = element + 1;
        end;
    otherwise
        error('Mode %s not supported.', Mode);
end;        