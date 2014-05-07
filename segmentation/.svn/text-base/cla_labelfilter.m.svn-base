function [relabeled varargout] = cla_labelfilter(FilterSpec, SegLabels, varargin)
%
% Reorders segment labels in CLA structured SegLabels according to
% FilterSpec. FilterSpec shall have the following outline:
%       FilterSpec{class} = [class1 class2 ... ]
% where each classx corresponds to the segment x in SegLabels at class
% class. Segments not references by a label will not be returned.

% [relabeled{[1:max(size(FilterSpec))]}] = deal([]);

for class = 1:max(size(FilterSpec))

    % sweep through all classlabels
    for newclass = 1:max(FilterSpec{class})
        thisclassidx = find(FilterSpec{class} == newclass);
        
        if (test('relabeled{newclass}')==0)
            relabeled{newclass} = [];
        end;
        relabeled{newclass} = segment_sort([relabeled{newclass}; SegLabels{class}(thisclassidx,:)]);

        for arg = 1:length(varargin)
            if (test('varargout{arg}{newclass}')==0)
                varargout{arg}{newclass} = [];
            end;
            varargout{arg}{newclass} = [varargout{arg}{newclass}; varargin{arg}{class}(thisclassidx,:)];
        end;
    end;
end;

% if (max(size(relabeled))==1) & (test('relabeled{1}'))
%     relabeled = relabeled{1};
% end;