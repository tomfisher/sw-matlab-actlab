% main_tb_anasim

% requires:
% fidx
initmain;

section_jitter = 0.5;
ftype = 'merged'; %'single'; % 'merged';

stats_fields = {'relevant', 'retrieved', 'recognised', 'insertions', 'deletions', 'recall', 'precision'};
classfiles = {'Cutlery', 'Drink', 'Spoon', 'Hand'};
SubjectList = {'Oliver', 'Holger', 'Bernhard', 'Corina'}
% classfiles = {'Cutlery'};



ftype
for classidx = 1:max(size(classfiles))
    ClassNo = strmatch(classfiles{classidx}, Repository.Classlist)

    clear res;
    for subj = 1:max(size(SubjectList))
        Subject = SubjectList{subj};
        SimSetID = [Subject fidx];
%         partlist = segment_getpartsforsubject(Subject, Repository.Classlist, RepEntry, Repository.ActiveRange);
%         [allSegLabels partoffsets] = segment_getlabels(Repository.Classlist, RepEntry, partlist);
        anasim_filename = dbfilename(Repository.RepEntries, ClassNo, ['ANASIM_' SimSetID], '', 'SIMCLF');
        load(anasim_filename, 'all_testSegLabels', 'all_trainSegLabels');

        filename = ['DATA' filesep 'SIMTB' filesep ftype filesep lower(classfiles{classidx}) '_' Subject];
        all_seglist = dlmread(filename);

        range_trainsegs = [all_trainSegLabels(1,1)-1 all_trainSegLabels(end,2)+1];
        test_seglist = segment_delovlist(range_trainsegs, all_seglist);
        res(subj) = prmetrics_fromsegments(all_testSegLabels, test_seglist, section_jitter);

        % load anasim data
        anasim_filename = dbfilename(Repository.RepEntries, ClassNo, ['ANASIM_' SimSetID], '', 'SIMCLF');
        load(anasim_filename, 'all_SimSeg', 'list_classdmin', 'bestindex')
        %     list_classdmin(bestindex)

        %     segment_plotrecognition(allSegLabels{ClassNo}, test_seglist, all_SimSeg{bestindex})

    end; % for subj

    % similarity results
    printstats(res, stats_fields);
end; % for classidx


