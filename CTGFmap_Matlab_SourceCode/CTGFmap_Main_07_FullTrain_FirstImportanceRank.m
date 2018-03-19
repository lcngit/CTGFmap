%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.2r0/2017.09.16
%_application: CTGF Features mapping

clear
clc
dbstop if error

% Set Initial parameters
CTGFmap_IncludeConstants;
n_exp = C_NUM_OF_EXP - 1;
mtd = METHOD_TREE_ENSAMBLE;

rnk_input = input('Rank type (0=all, 1=positive, -1=negative): ');
switch rnk_input
    case 0
        rnk_in = RNK_ALL_DVGSUP;
        rnk_out = RNK_ALL_RNDFOR;
        rnk_str = 'all';
    case 1
        rnk_in = RNK_POS_DVGSUP;
        rnk_out = RNK_POS_RNDFOR;
        rnk_str = 'pos';
    case -1
        rnk_in = RNK_NEG_DVGSUP;
        rnk_out = RNK_NEG_RNDFOR;
        rnk_str = 'neg';
    otherwise
        error('!!!Error: Invalid Rank Type!');
end

diaryfile = strcat('fulltrain', rnk_str, '_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp(['+++ Full ', upper(rnk_str(1)), rnk_str(2:3), ...
    ' Vector Random Forest Training +++']);
disp(['+++ Initial Random Forest Full ', upper(rnk_str(1)), rnk_str(2:3), ...
    ' Feature Importance Vector Determination +++']);

[ClassNames, ~, FeatIdsFull, fv_length, ClassIds, DocIds, ...
    FrmIds, DsetPlan, FeatVecsFull, n_vec] = CTGFmap_LoadNormalizedData();
Classes = sort(unique(ClassIds));
n_cls = numel(Classes);

ClassesRank = CTGFmap_LoadRanks(Classes, fv_length, rnk_in);
K_lengths = max(ClassesRank, [], 2);
KeepVecs = false(n_cls, fv_length);
ClassesImp = zeros(n_cls, fv_length);

for exp_num = 1:n_exp
    
    for cls = 1:n_cls
        cls_id = Classes(cls);
        
        Rank = ClassesRank(cls, :);
        k_length = K_lengths(cls);
        ExpPlan = DsetPlan(:, exp_num);

        [KeepVec, ~, ClassImp, ~] = CTGFmap_ClassModel_Iteration(exp_num, ...
            cls_id, k_length, mtd, exp_num, ExpPlan, rnk_in, Rank, ...
            false, FeatVecsFull, FeatIdsFull, ClassIds, DocIds, FrmIds);

        if ~isempty(ClassImp)
            if sum(abs(ClassImp)) == 0
                error('!!!Error: Iteration Importance is zero!');
            end
            ClassesImp(cls, :) = ClassesImp(cls, :) + ClassImp;
            ClassesImp(cls, KeepVec == 0) = 0;
            KeepVecs(cls, :) = KeepVec;
        end
        
    end
    
    DocMetrics = CTGFmap_Experiment_FrmToDoc(Classes, exp_num, ...
        C_EXP_VALIDATION, mtd, rnk_in, 0, K_lengths, 1);
end

CTGFmap_Rank_ClassesImp(KeepVecs, ClassesImp, Classes, rnk_out);

endtime = datetime('now');
disp(['+++ End - Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
