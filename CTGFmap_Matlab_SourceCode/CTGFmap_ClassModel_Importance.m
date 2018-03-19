%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function NormClassImp = CTGFmap_ClassModel_Importance(KeepVec, ClassModel)

disp(['+++ Begin - Getting Feature Importance from Classifier - ', ...
    datestr(now), ' +++']);

fv_length = numel(KeepVec);
ClassImp = zeros(1, fv_length);

ImpModel = predictorImportance(ClassModel);
IdxVector = find(KeepVec);
n_idx = numel(IdxVector);
n_imp = numel(ImpModel);
if n_imp ~= n_idx || n_idx ~= sum(KeepVec)
    error('!!!Error: Invalid importance vector!');
end
ClassImp(IdxVector) = ImpModel;

NormClassImp = CTGFmap_Normalize_Importance(KeepVec, ClassImp);

disp(['+++ End - Getting Feature Importance from Classifier - ', ...
    datestr(now), ' +++']);

end