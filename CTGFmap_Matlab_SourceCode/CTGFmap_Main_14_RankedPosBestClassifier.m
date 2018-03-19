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

rnk_type = RNK_POS_RNDFOR;
[rnk_str, ~] = CTGFmap_Rank_Type(rnk_type);

diaryfile = strcat('posbestclasf', rnk_str, '_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Best Positive Classifier Training, Validation and Testing +++');

[ClassNames, ~, FeatIdsFull, fv_length, ClassIds, DocIds, ...
    FrmIds, DsetPlan, FeatVecsFull, n_vec] = CTGFmap_LoadNormalizedData();
Classes = sort(unique(ClassIds));
n_cls = numel(Classes);

rnkfname = strcat('FrmFeatVec_NewRank_', rnk_str, '_Final.csv');
disp(['*** Reading Features Rank from file: ', rnkfname, ' ****']);
AllRank = csvread(rnkfname);
[nr_rnk, nc_rnk] = size(AllRank);
if nr_rnk ~= n_cls || nc_rnk ~= fv_length
    error('!!!Error: Invalid Rank file!')
end

lenfname = strcat('FrmFeatVec_Length_', rnk_str,'.csv');
disp(['*** Reading Best Length from file: ', lenfname, ' ****']);
LengthMetrics = csvread(lenfname);
Best_lengths = LengthMetrics(:, C_LEN_MTR_BESTLEN);
if numel(Best_lengths) ~= n_cls
    error('!!!Error: Invalid lengths vector!')
end

ElapsedTime = zeros(n_exp*n_cls*3, C_ELAPSED_LENGTH);
iel = 0;

for exp_num = 1:n_exp
    
    for cls = 1:n_cls
        k_length = Best_lengths(cls);
        Rank = AllRank(cls, :);
        ExpPlan = DsetPlan(:, exp_num);

        disp(['=== Begin Pos Best Classifier Generation for class: ', ...
            num2str(cls), ...
            ', rank type: ', num2str(rnk_type),...
            ', feature vector length: ', num2str(k_length), ...
            ', method: ', num2str(mtd), ...
            ', experiment ', num2str(exp_num), ...
            ' - ', datestr(datetime('now')), ' ===']);

        fsuffix = strcat('_C', num2str(Classes(cls)), ...
            '_R', num2str(rnk_type),...
            '_L', num2str(k_length), ...
            '_M', num2str(mtd), ...
            '_E', num2str(exp_num)); 

        seedrng = (cls*827)+(rnk_type*2069)+(mtd*5503)+ ...
            (k_length*197)+(exp_num*409)+2753;
        rng(seedrng); % set seed for random numbers
        disp(['*** Random number generator seed: ', num2str(seedrng), ' ***']);
        
        [FeatVecs, FeatIds, KeepVec] = CTGFmap_SelectFeatures(k_length, ...
            Rank, FeatVecsFull, FeatIdsFull);
        
        %********** Training **********
        
        [ClassModel, elaptrain, n_train] = CTGFmap_ClassModel_Train( ...
            Classes(cls), mtd, exp_num, ExpPlan, FeatVecs, FeatIds, ...
            ClassIds, DocIds, FrmIds);
        iel = iel + 1;
        ElapsedTime(iel, C_ELAPSED_RANK)     = rnk_type;
        ElapsedTime(iel, C_ELAPSED_CLASS)    = Classes(cls);
        ElapsedTime(iel, C_ELAPSED_EXPNUM)   = exp_num;
        ElapsedTime(iel, C_ELAPSED_TSTID)    = C_EXP_TRAINING;        
        ElapsedTime(iel, C_ELAPSED_METHOD)   = mtd;
        ElapsedTime(iel, C_ELAPSED_FVLENGTH) = k_length;
        ElapsedTime(iel, C_ELAPSED_NUMFVS)   = n_train;
        ElapsedTime(iel, C_ELAPSED_TIME)     = elaptrain;
        ElapsedTime(iel, C_ELAPSED_TIMEPFV)  = elaptrain / n_train;
        
        %********** Validation **********
        [~, ~, elapval, n_val] = CTGFmap_ClassModel_Test(Classes(cls), ...
            mtd, exp_num, C_EXP_VALIDATION, ExpPlan, FeatVecs, ...
            ClassModel, ClassIds, DocIds, FrmIds, fsuffix);
        iel = iel + 1;
        ElapsedTime(iel, C_ELAPSED_RANK)     = rnk_type;
        ElapsedTime(iel, C_ELAPSED_CLASS)    = Classes(cls);
        ElapsedTime(iel, C_ELAPSED_EXPNUM)   = exp_num;
        ElapsedTime(iel, C_ELAPSED_TSTID)    = C_EXP_VALIDATION;        
        ElapsedTime(iel, C_ELAPSED_METHOD)   = mtd;
        ElapsedTime(iel, C_ELAPSED_FVLENGTH) = k_length;
        ElapsedTime(iel, C_ELAPSED_NUMFVS)   = n_val;
        ElapsedTime(iel, C_ELAPSED_TIME)     = elapval;
        ElapsedTime(iel, C_ELAPSED_TIMEPFV)  = elapval / n_val;
        
        %********** Testing **********
        [~, ~, elaptst, n_tst] = CTGFmap_ClassModel_Test(Classes(cls), ...
            mtd, exp_num, C_EXP_TEST, ExpPlan, FeatVecs, ClassModel, ...
            ClassIds, DocIds, FrmIds, fsuffix);
        iel = iel + 1;
        ElapsedTime(iel, C_ELAPSED_RANK)     = rnk_type;
        ElapsedTime(iel, C_ELAPSED_CLASS)    = Classes(cls);
        ElapsedTime(iel, C_ELAPSED_EXPNUM)   = exp_num;
        ElapsedTime(iel, C_ELAPSED_TSTID)    = C_EXP_TEST;        
        ElapsedTime(iel, C_ELAPSED_METHOD)   = mtd;
        ElapsedTime(iel, C_ELAPSED_FVLENGTH) = k_length;
        ElapsedTime(iel, C_ELAPSED_NUMFVS)   = n_tst;
        ElapsedTime(iel, C_ELAPSED_TIME)     = elaptst;
        ElapsedTime(iel, C_ELAPSED_TIMEPFV)  = elaptst / n_tst;
        
        %********* Store Classifier Models **********
        ClassImp = (k_length + 1) - Rank;
        ClassImp(KeepVec == 0) = 0;
        ClassImp = ClassImp ./ (sum(ClassImp));
        if numel(ClassImp) ~= fv_length || round(sum(ClassImp), 5) ~= 1
            error('!!!Error: Invalid ClassImp');
        end
        CTGFmap_ClassModel_Store(ClassModel, Rank, KeepVec, ClassImp, fsuffix)

        %********* release resources **********
        clearvars ClassModel Rank KeepVec ClassImp FeatVecs FeatIds
        fclose('all');       

        disp(['=== End Best Positive Classifier Generation for class: ', ...
            num2str(Classes(cls)), ...
            ', rank type: ', num2str(rnk_type),...
            ', feature vector length: ', num2str(k_length), ...
            ', method: ', num2str(mtd), ...
            ', experiment: ', num2str(exp_num), ...
            ', elapsed training: ', num2str(elaptrain), ...
            ', elapsed validation: ', num2str(elapval), ...
            ' - ', datestr(datetime('now')), ' ===']);
        
    end
    
    CTGFmap_Experiment_FrmToDoc(Classes, exp_num, ...
        C_EXP_VALIDATION, mtd, rnk_type, 0, Best_lengths, 0);

    CTGFmap_Experiment_FrmToDoc(Classes, exp_num, ...
        C_EXP_TEST, mtd, rnk_type, 0, Best_lengths, 0);

end

% Elapsed time metrics.
etsuffix = strcat('_R', num2str(rnk_type), '_M', num2str(mtd));
outfname = strcat('ElapsedTime', etsuffix, '.csv');
dlmwrite(outfname, ElapsedTime, 'delimiter', ',', 'precision', 12);
disp(['    Elapsed time metrics saved into file: ', outfname]);

endtime = datetime('now');
disp(['+++ End - Step Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
