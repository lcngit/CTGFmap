%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function [ClassModel, Rank, KeepVec, ClassImp] = ...
    CTGFmap_ClassModel_Load(fsuffix)

disp(['+++ Begin - Loading Classifier Model - ', ...
    datestr(now), ' +++']);

ClassModel = {};
Rank = [];
KeepVec = [];
ClassImp = [];

loadfname = strcat('ClassModel', fsuffix,'.mat');
disp(['*** Loading Trained Model from file: ', loadfname, ' ***']);
load(loadfname, 'ClassModel', 'Rank', 'KeepVec', 'ClassImp');
disp('*** Trained Model loaded: ClassModel, Rank, KeepVec, ClassImp ***');

disp(['+++ End - Saving Classifier Model - ', ...
    datestr(now), ' +++']);

end
