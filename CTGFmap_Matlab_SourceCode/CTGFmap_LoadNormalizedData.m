%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function [ClassNames, n_names, FVColIds, fv_length, ClassIds, DocIds, ...
    FrmIds, DsetPlan, FeatVec, n_vec] = CTGFmap_LoadNormalizedData()

[ClassNames, n_names, FVColIds, ~, ClassIds, DocIds, FrmIds, DsetPlan, ...
    FeatVec, n_vec] = CTGFmap_LoadData();

%********** Min-Max Normalization **********
MinFVs = min(FeatVec);
MaxFVs = max(FeatVec);
DifFVs = MaxFVs - MinFVs;
SelZer = DifFVs == 0;
MinFVs(SelZer) = [];
DifFVs(SelZer) = [];
FeatVec(:, SelZer) = [];
for i=1:n_vec
    FeatVec(i, :) = (FeatVec(i, :) - MinFVs) ./ DifFVs; 
end
[~, fv_length] = size(FeatVec);

end
