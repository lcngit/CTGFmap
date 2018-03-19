%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function CTGFmap_ClassModel_Store(ClassModel, Rank, KeepVec, ...
    ClassImp, fsuffix) %#ok<INUSL>

disp(['+++ Begin - Saving Classifier Model - ', ...
    datestr(now), ' +++']);

savefname = strcat('ClassModel', fsuffix,'.mat');
disp(['*** Saving Trained Model into file: ', savefname, ' ***']);
save(savefname, 'ClassModel', 'Rank', 'KeepVec', 'ClassImp', '-v7.3');
disp('*** Trained Model saved: ClassModel, Rank, KeepVec, ClassImp ***');


disp(['+++ End - Saving Classifier Model - ', ...
    datestr(now), ' +++']);

end