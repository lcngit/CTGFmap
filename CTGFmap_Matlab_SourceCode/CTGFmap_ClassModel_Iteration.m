%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date:v1.0.2r0/2017.09.16
%_application: CTGF Features mapping

function [KeepVec, ClassRank, NormClassImp, Metrics] = ...
    CTGFmap_ClassModel_Iteration(itr, cls_id, k_length, mtd, exp_num, ...
    ExpPlan, rnk_type, Rank, storemodel, FeatVecsFull, FeatIdsFull, ...
    ClassIds, DocIds, FrmIds)

CTGFmap_IncludeConstants;

disp(['=== Begin Interation #', num2str(itr), ...
    ' - class: ', num2str(cls_id), ...
    ', rank type: ', num2str(rnk_type),...
    ', feature vector length: ', num2str(k_length), ...
    ', method: ', num2str(mtd), ...
    ', experiment ', num2str(exp_num), ...
    ' - ', datestr(datetime('now')), ' ===']);
fsuffix = strcat('_C', num2str(cls_id), ...
    '_R', num2str(rnk_type),...
    '_L', num2str(k_length), ...
    '_M', num2str(mtd), ...
    '_E', num2str(exp_num));

frmfname = strcat('FrmAttrib', fsuffix, '_T', num2str(C_EXP_VALIDATION), '.csv');
if exist(frmfname, 'file') == 2
    % If frame attritution file already exists for the validation return
    % empty values
    disp(['!Warning: Frame attribution file kept. ', frmfname, ' already exists!']);
    [KeepVec, ClassRank, NormClassImp, Metrics] = deal([]);
    return;
end

seedrng = (cls_id*827)+(rnk_type*2069)+(mtd*5503)+(k_length*197)+ ...
    (exp_num*409)+2753;
rng(seedrng); % set seed for random numbers
disp(['*** Random number generator seed: ', num2str(seedrng), ' ***']);

[FeatVecs, FeatIds, KeepVec] = CTGFmap_SelectFeatures(k_length, ...
    Rank, FeatVecsFull, FeatIdsFull);

ElapsedTime = zeros(2, C_ELAPSED_LENGTH);
iel = 0;

%********** Training **********

[ClassModel, elaptrain, n_train] = CTGFmap_ClassModel_Train(cls_id, mtd, ...
    exp_num, ExpPlan, FeatVecs, ...
    FeatIds, ClassIds, DocIds, FrmIds);
iel = iel + 1;
ElapsedTime(iel, C_ELAPSED_RANK)     = rnk_type;
ElapsedTime(iel, C_ELAPSED_CLASS)    = cls_id;
ElapsedTime(iel, C_ELAPSED_EXPNUM)   = exp_num;
ElapsedTime(iel, C_ELAPSED_TSTID)    = C_EXP_TRAINING;
ElapsedTime(iel, C_ELAPSED_METHOD)   = mtd;
ElapsedTime(iel, C_ELAPSED_FVLENGTH) = k_length;
ElapsedTime(iel, C_ELAPSED_NUMFVS)   = n_train;
ElapsedTime(iel, C_ELAPSED_TIME)     = elaptrain;
ElapsedTime(iel, C_ELAPSED_TIMEPFV)  = elaptrain / n_train;

%********** Validation **********
[~, Metrics, elapval, n_val] = CTGFmap_ClassModel_Test(cls_id, mtd, ...
    exp_num, C_EXP_VALIDATION, ExpPlan, FeatVecs, ClassModel, ClassIds, ...
    DocIds, FrmIds, fsuffix);
iel = iel + 1;
ElapsedTime(iel, C_ELAPSED_RANK)     = rnk_type;
ElapsedTime(iel, C_ELAPSED_CLASS)    = cls_id;
ElapsedTime(iel, C_ELAPSED_EXPNUM)   = exp_num;
ElapsedTime(iel, C_ELAPSED_TSTID)    = C_EXP_VALIDATION;
ElapsedTime(iel, C_ELAPSED_METHOD)   = mtd;
ElapsedTime(iel, C_ELAPSED_FVLENGTH) = k_length;
ElapsedTime(iel, C_ELAPSED_NUMFVS)   = n_val;
ElapsedTime(iel, C_ELAPSED_TIME)     = elapval;
ElapsedTime(iel, C_ELAPSED_TIMEPFV)  = elapval / n_val;

%********** Getting Importance **********
ClassImp = CTGFmap_ClassModel_Importance(KeepVec, ClassModel);

%********** Getting Importance **********
[ClassRank, NormClassImp] = CTGFmap_Rank_Importance(KeepVec, ClassImp);

%********** Store Validated Model if requested
if storemodel
    CTGFmap_ClassModel_Store(ClassModel, Rank, KeepVec, ClassImp, fsuffix)
end

%********* release resources **********
clearvars ClassModel
fclose('all');

% Elapsed time metrics.
outfname = strcat('ElapsedTime', fsuffix, '.csv');
dlmwrite(outfname, ElapsedTime, 'delimiter', ',', 'precision', 12);
disp(['--- Elapsed time metrics saved into file: ', outfname]);

disp(['=== End Interation - class: ', num2str(cls_id), ...
    ', rank type: ', num2str(rnk_type),...
    ', feature vector length: ', num2str(k_length), ...
    ', method: ', num2str(mtd), ...
    ', experiment: ', num2str(exp_num), ...
    ', elapsed training: ', num2str(elaptrain), ...
    ', elapsed validation: ', num2str(elapval), ...
    ' - ', datestr(datetime('now')), ' ===']);

end