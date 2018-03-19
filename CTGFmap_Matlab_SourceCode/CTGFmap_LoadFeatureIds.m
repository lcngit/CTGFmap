%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: CTGFmap_HeatMapFeatures
%_application: CTGF Features mapping

function [FVColIds, fv_length] = CTGFmap_LoadFeatureIds()

idsfname = 'FrmFeatVec_Ids.csv';
disp(['*** Reading Feature Ids File = ', idsfname, ' ***']);
X_Ids = csvread(idsfname);
[nrid, fv_length] = size(X_Ids);
if nrid ~= 1
    error('!!!Error: Invalid Feature Ids File');
end
FVColIds = cell(1, fv_length);
for i = 1 : fv_length
    FVColIds{i} = strcat('X', num2str(X_Ids(i)));
end

end
