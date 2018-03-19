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
selmtd = input('Select Method (0 = SVM, 1 = RndFor): ');
if selmtd == 0
    mtd = METHOD_SVM_SMO;
else
    mtd = METHOD_TREE_ENSAMBLE;
end
rnk_type = RNK_NO;
dsz = -1;
while dsz < 0 || dsz > 90
    dsz = input('Dataset size reduction of [0(no reduction) to 90]% : ');
end
dsz = round(dsz, 0);

diaryfile = strcat('full_len_mtd_', num2str(mtd), '_dsz', ...
    num2str(dsz),'_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Full Length Method Training, Validation and Testing +++');
if dsz > 0
    disp(['+++ With dataset size reduction of ', num2str(dsz),'% +++']);
end

[ClassNames, n_names, FeatIdsFull, fv_length, ClassIds, DocIds, FrmIds, ...
    DsetPlan, FeatVecsFull, n_vec] = CTGFmap_LoadNormalizedData();

% Randomly decrease vector size
if dsz > 0
    disp(['*** Randomly frames selected for dataset size reduction of ', ...
        num2str(dsz),'% ***']);
    seedrng = (rnk_type*2069)+(mtd*5503)+(fv_length*197)+(dsz*409)+270456;
    rng(seedrng); % set seed for random numbers
    disp(['    Random number generator seed: ', num2str(seedrng)]);
    disp(['    Total number of original vectors: ', num2str(n_vec)]);
    SelRnd = rand(n_vec, 1) > (dsz / 100);
    ClassIds = ClassIds(SelRnd, :);
    DocIds = DocIds(SelRnd, :);
    FrmIds = FrmIds(SelRnd, :);
    DsetPlan = DsetPlan(SelRnd, :);
    FeatVecsFull = FeatVecsFull(SelRnd, :);
    n_vec = numel(ClassIds);
    disp(['    Total number of vectors after dataset reduction: ', ...
        num2str(n_vec)]);
end

Classes = sort(unique(ClassIds));
n_cls = numel(Classes);
Full_lengths = ones(n_cls, 1) .* fv_length;
ElapsedTime = zeros(n_exp*n_cls*3, C_ELAPSED_LENGTH);
iel = 0;

for exp_num = 1:n_exp
    
    for cls = 1:n_cls
        cls_id = Classes(cls);
        
        Rank = 1:fv_length;
        ExpPlan = DsetPlan(:, exp_num);
        
        disp(['=== Begin Full Lenght Classifier Generation for class: ', ...
            num2str(cls_id), ...
            ', rank type: ', num2str(rnk_type),...
            ', feature vector length: ', num2str(fv_length), ...
            ', method: ', num2str(mtd), ...
            ', experiment ', num2str(exp_num), ...
            ' - ', datestr(datetime('now')), ' ===']);
        
        fsuffix = strcat('_C', num2str(cls_id), ...
            '_R', num2str(rnk_type),...
            '_L', num2str(fv_length), ...
            '_M', num2str(mtd), ...
            '_E', num2str(exp_num));
        if dsz > 0
            fsuffix = strcat(fsuffix,'_Z', num2str(dsz));
        end
        
        seedrng = (cls_id*827)+(rnk_type*2069)+(mtd*5503)+(fv_length*197)+(exp_num*409)+2753;
        rng(seedrng); % set seed for random numbers
        disp(['*** Random number generator seed: ', num2str(seedrng), ' ***']);
        
        [FeatVecs, FeatIds, KeepVec] = CTGFmap_SelectFeatures(fv_length, ...
            Rank, FeatVecsFull, FeatIdsFull);
        
        %********** Training **********
        [ClassModel, elaptrain, n_train] = CTGFmap_ClassModel_Train( ...
            cls_id, mtd, exp_num, ExpPlan, FeatVecs, FeatIds, ClassIds, ...
            DocIds, FrmIds);
        iel = iel + 1;
        ElapsedTime(iel, C_ELAPSED_RANK)     = rnk_type;
        ElapsedTime(iel, C_ELAPSED_CLASS)    = cls_id;
        ElapsedTime(iel, C_ELAPSED_EXPNUM)   = exp_num;
        ElapsedTime(iel, C_ELAPSED_TSTID)    = C_EXP_TRAINING;
        ElapsedTime(iel, C_ELAPSED_METHOD)   = mtd;
        ElapsedTime(iel, C_ELAPSED_FVLENGTH) = fv_length;
        ElapsedTime(iel, C_ELAPSED_NUMFVS)   = n_train;
        ElapsedTime(iel, C_ELAPSED_TIME)     = elaptrain;
        ElapsedTime(iel, C_ELAPSED_TIMEPFV)  = elaptrain / n_train;
        disp(['### Training of class: ', num2str(cls_id), ...
            ', rank type: ', num2str(rnk_type),...
            ', feature vector length: ', num2str(fv_length), ...
            ', method: ', num2str(mtd), ...
            ', experiment ', num2str(exp_num), ...
            '  ', num2str(elaptrain), ' secs. ###']);
        
        %********** Validation **********
        [~, ~, elapval, n_val] = CTGFmap_ClassModel_Test(cls_id, mtd, ...
            exp_num, C_EXP_VALIDATION, ExpPlan, FeatVecs, ClassModel, ...
            ClassIds, DocIds, FrmIds, fsuffix);
        iel = iel + 1;
        ElapsedTime(iel, C_ELAPSED_RANK)     = rnk_type;
        ElapsedTime(iel, C_ELAPSED_CLASS)    = cls_id;
        ElapsedTime(iel, C_ELAPSED_EXPNUM)   = exp_num;
        ElapsedTime(iel, C_ELAPSED_TSTID)    = C_EXP_VALIDATION;
        ElapsedTime(iel, C_ELAPSED_METHOD)   = mtd;
        ElapsedTime(iel, C_ELAPSED_FVLENGTH) = fv_length;
        ElapsedTime(iel, C_ELAPSED_NUMFVS)   = n_val;
        ElapsedTime(iel, C_ELAPSED_TIME)     = elapval;
        ElapsedTime(iel, C_ELAPSED_TIMEPFV)  = elapval / n_val;
        disp(['### Test of class: ', num2str(cls_id), ...
            ', rank type: ', num2str(rnk_type),...
            ', feature vector length: ', num2str(fv_length), ...
            ', method: ', num2str(mtd), ...
            ', experiment ', num2str(exp_num), ...
            '  ', num2str(elapval), ' secs. ###']);
        
        %********** Testing **********
        [~, ~, elaptst, n_tst] = CTGFmap_ClassModel_Test(cls_id, mtd, ...
            exp_num, C_EXP_TEST, ExpPlan, FeatVecs, ClassModel, ...
            ClassIds, DocIds, FrmIds, fsuffix);
        iel = iel + 1;
        ElapsedTime(iel, C_ELAPSED_RANK)     = rnk_type;
        ElapsedTime(iel, C_ELAPSED_CLASS)    = cls_id;
        ElapsedTime(iel, C_ELAPSED_EXPNUM)   = exp_num;
        ElapsedTime(iel, C_ELAPSED_TSTID)    = C_EXP_TEST;
        ElapsedTime(iel, C_ELAPSED_METHOD)   = mtd;
        ElapsedTime(iel, C_ELAPSED_FVLENGTH) = fv_length;
        ElapsedTime(iel, C_ELAPSED_NUMFVS)   = n_tst;
        ElapsedTime(iel, C_ELAPSED_TIME)     = elaptst;
        ElapsedTime(iel, C_ELAPSED_TIMEPFV)  = elaptst / n_tst;
        disp(['### Test of class: ', num2str(cls_id), ...
            ', rank type: ', num2str(rnk_type),...
            ', feature vector length: ', num2str(fv_length), ...
            ', method: ', num2str(mtd), ...
            ', experiment ', num2str(exp_num), ...
            '  ', num2str(elaptst), ' secs. ###']);
        
        %********* release resources **********
        clearvars ClassModel Rank KeepVec ClassImp FeatVecs FeatIds
        fclose('all');
        
        disp(['=== End Full Length Classifier Generation for class: ', num2str(cls_id), ...
            ', rank type: ', num2str(rnk_type),...
            ', feature vector length: ', num2str(fv_length), ...
            ', method: ', num2str(mtd), ...
            ', experiment ', num2str(exp_num), ...
            ' - ', datestr(datetime('now')), ' ===']);
        
    end
    
    CTGFmap_Experiment_FrmToDoc(Classes, exp_num, ...
        C_EXP_VALIDATION, mtd, rnk_type, dsz, Full_lengths, 0);
    
    CTGFmap_Experiment_FrmToDoc(Classes, exp_num, ...
        C_EXP_TEST, mtd, rnk_type, dsz, Full_lengths, 0);
    
end

% Elapsed time metrics.
etsuffix = strcat('_R', num2str(rnk_type),...
    '_L', num2str(fv_length), ...
    '_M', num2str(mtd));
if dsz > 0
    etsuffix = strcat(etsuffix,'_Z', num2str(dsz));
end
outfname = strcat('ElapsedTime', etsuffix, '.csv');
dlmwrite(outfname, ElapsedTime, 'delimiter', ',', 'precision', 12);
disp(['    Elapsed time metrics saved into file: ', outfname]);

endtime = datetime('now');
disp(['+++ End - Step Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
