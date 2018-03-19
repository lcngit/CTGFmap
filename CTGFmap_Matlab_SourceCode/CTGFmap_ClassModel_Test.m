%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.2r0/2017.09.16
%_application: CTGF Features mapping

function [FrmAttrib, Metrics, elaptst, n_vec] = CTGFmap_ClassModel_Test(...
    cls_id, mtd, exp_num, exp_type, ExpPlan, FeatVecs, ClassModel, ...
    ClassIds, DocIds, FrmIds, fsuffix)

CTGFmap_IncludeConstants;
tic

[TestFeatVecs, TestClass, ActualClassIds, PredDocIds, PredFrmIds, exp_str] = ...
    CTGFmap_SelectExpVectors(cls_id, exp_type, ExpPlan, FeatVecs, ...
    ClassIds, DocIds, FrmIds);
[n_vec, test_fv_length] = size(TestFeatVecs);
n_ids = numel(TestClass);

disp(['*** Begin ', exp_str, ' of Classifier for class: ', num2str(cls_id), ...
    ' - experiment: ', num2str(exp_num), ' - ', datestr(datetime('now')), ...
    ' ***'])

% Classifier test classification (binary classifier)
disp(['TestData(',num2str(n_vec),'x',num2str(test_fv_length), ...
    '), TestIds(',num2str(n_ids),')']);
disp('Model:');
disp(ClassModel);
if (mtd == METHOD_SVM_OLD)
    [BinPredClass, ConfMtx] = ...
        CTGFmap_svmclassify_Test(ClassModel, TestFeatVecs, TestClass);
else
    [BinPredClass, ConfMtx] = ...
        CTGFmap_predict_Test (ClassModel, TestFeatVecs, TestClass);
end

Metrics = CTGFmap_CalcMetrics (ConfMtx);
id_metrics = strcat('Class:', num2str(cls_id), ' - ', exp_str);
CTGFmap_DispMetrics (id_metrics, Metrics);

PredClass = ones(n_vec, 1) * (max(ClassIds) + 2);
PredClass(BinPredClass == C_CLASS_POSITIVE) = cls_id;
PredClass(BinPredClass == C_CLASS_NEGATIVE) = 0;

FrmAttrib = zeros(n_vec, C_ATTRIBFRM_LENGTH + 1);
FrmAttrib(:, C_HDRMTR_CLASS)        = ActualClassIds;
FrmAttrib(:, C_HDRMTR_EXPNUM)       = exp_num;
FrmAttrib(:, C_HDRMTR_TSTID)        = exp_type;
FrmAttrib(:, C_HDRMTR_METHOD)       = mtd;
FrmAttrib(:, C_HDRMTR_FVLENGTH)     = test_fv_length;
FrmAttrib(:, C_ATTRIBFRM_DOCID)     = PredDocIds;
FrmAttrib(:, C_ATTRIBFRM_FRMID)     = PredFrmIds;
FrmAttrib(:, C_ATTRIBFRM_PREDICTED) = PredClass;

% Save document attribution process data for logging purpose and next steps.
fsuffix = strcat(fsuffix, '_T', num2str(exp_type));
outfname = strcat('FrmAttrib', fsuffix, '.csv');
dlmwrite(outfname, FrmAttrib, 'delimiter', ',', 'precision', 12);
disp(['    Classes Attributed to Frames saved into file: ', outfname]);

disp(' ');
disp(['*** End ', exp_str, ' of Classifier for class: ', num2str(cls_id), ...
    ' - experiment: ', num2str(exp_num), ' - ', datestr(datetime('now')), ...
    ' ***'])

elaptst = toc;

end
