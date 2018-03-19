%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function [ExpFeatVecs, BinClassIds, ExpClassIds, ExpDocIds, ExpFrmIds, ...
    exp_str] = CTGFmap_SelectExpVectors(cls_id, exp_type, ExpPlan, FeatVecs,...
    ClassIds, DocIds, FrmIds)

CTGFmap_IncludeConstants;

switch exp_type
    case C_EXP_TRAINING
        exp_str = 'Train';
        SelExp = ExpPlan == exp_type;
    case C_EXP_VALIDATION
        exp_str = 'Validation';
        SelExp = ExpPlan == exp_type;
    case C_EXP_TEST
        exp_str = 'Test';
        SelExp = ExpPlan == exp_type;
    case C_EXP_TRAINVAL
        exp_str = 'Train and Validation';
        SelExp = ExpPlan == C_EXP_TRAINING | ExpPlan == C_EXP_VALIDATION;
    case C_EXP_ALL
        exp_str = 'All vectors';
        SelExp = true(numel(ExpPlan), 1);
    otherwise
        error('!!!Error: Invalid experiment type!');
end

ExpFeatVecs = FeatVecs(SelExp, :);
[n_vec, ~] = size(ExpFeatVecs);

ExpClassIds = ClassIds(SelExp, :);
BinClassIds = ExpClassIds;
BinClassIds(ExpClassIds == cls_id) = C_CLASS_POSITIVE;
BinClassIds(ExpClassIds ~= cls_id) = C_CLASS_NEGATIVE;
n_ids = numel(BinClassIds);

ExpDocIds = DocIds(SelExp, :);
ExpFrmIds = FrmIds(SelExp, :);

if n_vec ~= n_ids
    error('!!!Error: Number of vectors and class ids does not match!');
end

end
