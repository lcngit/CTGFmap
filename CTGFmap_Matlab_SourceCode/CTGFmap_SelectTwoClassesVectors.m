%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function [ExpFeatVecs, BinClassIds, ExpClassIds, ExpDocIds, ExpFrmIds, ...
    exp_str] = CTGFmap_SelectTwoClassesVectors(cls_1, cls_2, exp_type, ...
    ExpPlan, FeatVecs, ClassIds, DocIds, FrmIds)

CTGFmap_IncludeConstants;

n_cls = max(ClassIds);
if cls_1 <= 0 || cls_1 > n_cls
    error('!!!Error: Invalid class 1!');
end
SelCls1 = ClassIds == cls_1;
if cls_2 < 0 || cls_2 > n_cls
    error('!!!Error: Invalid class 2!');
end
if cls_2 == 0
    SelCls2 = ClassIds ~= cls_1;
else
    SelCls2 = ClassIds == cls_2;
end

switch exp_type
    case C_EXP_TRAINING
        exp_str = 'Train';
        SelExp = (ExpPlan == exp_type) & (SelCls1 | SelCls2);
    case C_EXP_VALIDATION
        exp_str = 'Validation';
        SelExp = (ExpPlan == exp_type) & (SelCls1 | SelCls2);
    case C_EXP_TEST
        exp_str = 'Test';
        SelExp = (ExpPlan == exp_type) & (SelCls1 | SelCls2);
    case C_EXP_TRAINVAL
        exp_str = 'Train and Validation';
        SelExp = ExpPlan == ((C_EXP_TRAINING) |  ...
            (ExpPlan == C_EXP_VALIDATION)) & (SelCls1 | SelCls2);
    case C_EXP_ALL
        exp_str = 'All vectors';
        SelExp = SelCls1 | SelCls2;
    otherwise
        error('!!!Error: Invalid experiment type!');
end

ExpFeatVecs = FeatVecs(SelExp, :);
[n_vec, ~] = size(ExpFeatVecs);

ExpClassIds = ClassIds(SelExp, :);
BinClassIds = ExpClassIds;
BinClassIds(ExpClassIds == cls_1) = C_CLASS_POSITIVE;
if cls_2 == 0
    BinClassIds(ExpClassIds ~= cls_1) = C_CLASS_NEGATIVE;
else
    BinClassIds(ExpClassIds == cls_2) = C_CLASS_NEGATIVE;
end
n_ids = numel(BinClassIds);

ExpDocIds = DocIds(SelExp, :);
ExpFrmIds = FrmIds(SelExp, :);

if n_vec ~= n_ids
    error('!!!Error: Number of vectors and class ids does not match!');
end

end
