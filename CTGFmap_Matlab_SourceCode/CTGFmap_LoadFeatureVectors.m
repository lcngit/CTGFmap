%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function [ClassIds, DocIds, FrmIds, ExpPlan, FeatVec, n_vec, fv_length] = ...
         CTGFmap_LoadFeatureVectors()

CTGFmap_IncludeConstants;

disp(['*** Begin - Loading Feature Vectors - ', datestr(now), ' ***']);

fmfname = 'FrmFeatVec_All.csv';
disp (['    Reading Frame Feature Vectors File = ', fmfname]);
FrmFeatVec = csvread(fmfname);

ClassIds = FrmFeatVec(:, C_FRMVEC_CLASS);
DocIds   = FrmFeatVec(:, C_FRMVEC_DOCID);
FrmIds   = FrmFeatVec(:, C_FRMVEC_FRMID);
ExpPlan  = FrmFeatVec(:, C_FRMVEC_EXP : (C_FRMVEC_EXP + C_NUM_OF_EXP - 1));
FeatVec  = FrmFeatVec(:, C_FRMVEC_FVEC : end);
[n_vec, fv_length] = size(FeatVec);
clearvars FrmFeatVec

disp(['    Number of vectors loaded = ', num2str(n_vec), ...
    ', Feature columns = ', num2str(fv_length)]);

disp(['*** End - Loading Feature Vectors - ', datestr(now), ' ***']);

end
