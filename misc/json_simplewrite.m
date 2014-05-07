function ok = json_simplewrite(filename, struct, AccessMode)
% function ok = json_simplewrite(filename, struct, AccessMode)
% 
% Simple JSON format write function
% 
% Example:
%     configstruct.test1 = 'huhu'; configstruct.test2 = 'haha'; 
%     json_simplewrite('test', [configstruct configstruct])
% 
% Copyright 2009 Oliver Amft

IndentSpaces = 4;

if ~exist('AccessMode', 'var'), AccessMode = 'create';  end;

% open file
switch lower(AccessMode)
    case {'create', 'c'}
        fh = fopen(filename,'w');
        %fwrite(fh, '');
    case {'append', 'a'}
        fh = fopen(filename,'a');
        fprintf(fh, ',\n');
end;
if (fh < 0), error('\n%s: Cannot write file.', mfilename); end;

IndentStr = repmat(' ', 1, IndentSpaces);

% write out struct
fields = fieldnames(struct);
for i = 1:length(struct)
    if i > 1, fprintf(fh, ',\n'); end;
    fprintf(fh, '{\n');
    for f = 1:length(fields)
        if f > 1, fprintf(fh, ',\n'); end;
        if ischar(struct(i).(fields{f}))
            fprintf( fh, '%s"%s" : "%s"', IndentStr, fields{f}, struct(i).(fields{f}) );
        elseif hasfrac(struct(i).(fields{f}))
            fprintf( fh, '%s"%s" : %f', IndentStr, fields{f}, struct(i).(fields{f}) );
        else
            fprintf( fh, '%s"%s" : %u', IndentStr, fields{f}, struct(i).(fields{f}) );
        end;
    end;
    fprintf(fh, '\n}');
end;

fclose(fh);
ok = true;