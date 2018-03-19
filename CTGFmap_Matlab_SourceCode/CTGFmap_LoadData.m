%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function [ClassNames, n_names, FVColIds, fv_length, ClassIds, DocIds, ...
          FrmIds, DsetPlan, FeatVec, n_vec] = CTGFmap_LoadData()

[ClassNames, n_names] = CTGFmap_LoadClassNames();

[FVColIds, fv_length] = CTGFmap_LoadFeatureIds();

[ClassIds, DocIds, FrmIds, DsetPlan, FeatVec, n_vec, fv_lgt] = ...
    CTGFmap_LoadFeatureVectors();

if fv_lgt ~= fv_length
    error('!!!Error: Feature column ids does not match feature vectors length!');
end

end
