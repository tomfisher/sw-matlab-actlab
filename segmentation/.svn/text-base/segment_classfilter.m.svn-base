function [newseglist classes removed] = segment_classfilter(Spec, oldseglist, varargin)
% function [newseglist classes removed] = segment_classfilter(Spec, oldseglist, varargin)
%
% Merge classes according to specification in Spec.
%
% Spec should look like this:
%       Spec = {[1 2], 3, [4:6]}
%
% Classes not in Spec will be deleted from the result. The resulting class
% number are counted 1..n. Parameter classes is a list of the first from the
% classes to be merged, e.g. 1,3,4 in the example above.
% 
% Copyright 2006-2007 Oliver Amft

newseglist = []; classes = []; removed = [];

ClassIDMode = process_options(varargin, 'ClassIDMode', 'renumber');

if isempty(oldseglist), return; end;

if size(oldseglist,2) < 4 
    error('Method works on full segment list only (min 4 columns).');
%     oldclassidlist = oldseglist;
%     issegmentlist = false;
else
    oldclassidlist = oldseglist(:,4);
%     issegmentlist = true;    
end;

if isempty(Spec)
    newseglist = oldseglist;
    classes = unique(oldclassidlist);
	removed = false(1,size(oldseglist,1));
    return;
end;


% determine new class label from Spec; cover all classes for that a spec
% entries persit, others are omitted.
classes = zeros(1,length(Spec));
for classno = 1:length(Spec)
    thisclass = Spec{classno}(1); % new class number, determined from 1st entry
    
    for oldclass = row(Spec{classno})
		switch lower(ClassIDMode)
			case 'renumber'
%                 if issegmentlist
                    newseglist = [newseglist; segment_createlist(oldseglist(oldclassidlist == oldclass, :), 'classlist', classno)];
%                 else
%                     newseglist = [newseglist; repmat(classno, sum(oldclassidlist == oldclass),1)];
%                 end;
			case 'keepid'
%                 if issegmentlist
                    newseglist = [newseglist; segment_createlist(oldseglist(oldclassidlist == oldclass, :), 'classlist', thisclass)]; %classes(end))];
%                 else
%                     newseglist = [newseglist; repmat(thisclass, sum(oldclassidlist == oldclass),1)];
%                 end;
			otherwise
				error('ClassIDMode not understood.');
		end;
		
        % store class if existing
        switch lower(ClassIDMode)
            case 'renumber'
                if (sum(oldclassidlist == oldclass)>0), classes(classno) = classno; end;
            case 'keepid'
                if (sum(oldclassidlist == oldclass)>0), classes(classno) = thisclass; end;
        end;
    end;
end;

removed = true(1, size(oldseglist,1));

classes(classes==0) = [];
classes = row(unique(classes));

% OAM REVISIT: check this
if isempty(newseglist)
	return; 
end;

% find entries that have been removed in oldseglist
% cmpcols = 1:size(oldseglist,2); cmpcols(cmpcols==4) = [];
%removed = (segment_countoverlap(oldseglist, newseglist, 0) == 0);
% if issegmentlist
    removed = ~segment_findequals(oldseglist, newseglist);
% else
%     removed = ~segment_findequals(oldseglist, newseglist, 'CheckCols', 1);
% end;
% for i = 1:size(oldseglist,1)
% 	removed(i) = isempty(find(oldseglist(i,cmpcols) == newseglist(:,cmpcols),1));
% end;

newseglist = segment_sort(newseglist);

