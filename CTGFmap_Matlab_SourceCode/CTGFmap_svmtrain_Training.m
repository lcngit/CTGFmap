%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function SVM_Model = CTGFmap_svmtrain_Training (TrainFeatMtx, ...
    ClassActual, tolkkt, itlim)
% SVM Binary classifier, ClassActual is interpreted as:
%    ClassActual[i] = -1 -> first class on confusion matrix, negative class
%    ClassActual[i] = 1 -> second class on confusion matrix, positive class
Err = (ClassActual ~= -1) & (ClassActual ~= 1);
if sum(Err) ~= 0
    error('Program aborted in SVM Training consistency - Class vector is not (-1, 1)')
end

% if toolkkt is 0 then use default as 1e-5
if tolkkt == 0
    tolkkt = 1e-5;
end

% if iteration limit is 0 then use default as 1e7
if itlim == 0
    itlim = 1e7;
end

% Train classifier generating SVM model (binary classifier)
optSVM = statset('MaxIter', itlim); % to give enough room for convergence
SVM_Model = svmtrain(...
    TrainFeatMtx, ...       % Training Vectors, predictor values
    ClassActual, ...        % Actual class of each vector
    'kernel_function', 'linear', ...    % Linear kernel
    'options', optSVM, ...  % SVM options: maximum iterations set
    'tolkkt', tolkkt); %#ok<SVMTRAIN>   % kkt tolerance

end
