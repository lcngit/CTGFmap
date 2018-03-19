%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function [ClassPred, ConfMtx] = CTGFmap_svmclassify_Test (SVM_Model, ...
    TstFeatMtx, ClassActual)
% SVM Binary classifier, ClassActual is interpreted as:
%    ClassActual[i] = -1 -> first class on confusion matrix, negative class
%    ClassActual[i] = 1 -> second class on confusion matrix, positive class

Err = (ClassActual ~= -1) & (ClassActual ~= 1);
if sum(Err) ~= 0
    error('Program aborted in SVM Test consistency - Actual Class vector is not (-1, 1)')
end

% Classify test data with SVM model (binary classifier)
ClassPred = svmclassify(SVM_Model, TstFeatMtx); %#ok<SVMCLASSIFY>
ConfMtx = confusionmat(ClassActual, ClassPred);

Err = (ClassPred ~= -1) & (ClassPred ~= 1);
if sum(Err) ~= 0
    error('Program aborted in SVM Test consistency - Predicted Class vector is not (-1, 1)')
end

end
