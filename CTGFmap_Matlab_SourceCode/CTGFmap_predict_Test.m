%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function [ClassPred, ConfMtx] = CTGFmap_predict_Test (Class_Model, ...
    TstFeatMtx, ClassActual)
% Binary classifier, ClassActual is interpreted as:
%    ClassActual[i] = -1 -> first class on confusion matrix, negative class
%    ClassActual[i] = 1 -> second class on confusion matrix, positive class

Err = (ClassActual ~= -1) & (ClassActual ~= 1);
if sum(Err) ~= 0
    error('Program aborted in Binary Class consistency - Actual Class vector is not (-1, 1)')
end

ClassPred = predict(Class_Model, TstFeatMtx);

Err = (ClassPred ~= -1) & (ClassPred ~= 1);
if sum(Err) ~= 0
    error('Program aborted in Binary Class consistency - Predicted Class vector is not (-1, 1)')
end

ConfMtx = confusionmat(ClassActual, ClassPred, 'order', [-1, 1]);

end
