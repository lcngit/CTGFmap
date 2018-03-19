%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function Tree_Model = CTGFmap_fitcensembletree_Training (TrainFeatMtx, ...
    ClassActual, fvColIds, nlearncycles, prior)

% Tree Ensamble Binary classifier, ClassActual is interpreted as:
%    ClassActual[i] = -1 -> first class on confusion matrix, negative class
%    ClassActual[i] = 1 -> second class on confusion matrix, positive class
Err = (ClassActual ~= -1) & (ClassActual ~= 1);
if sum(Err) ~= 0
    error('Program aborted in Tree Ensamble Training consistency - Class vector is not (-1, 1)')
end

% if nlearn is 0 then use as default sqrt(max(number of features, number of samples))
if nlearncycles == 0
    [nr , nc] = size(TrainFeatMtx);
    nlearncycles = floor(sqrt(max(nr, nc)));
end

% Train classifier generating Tree Ensamble model (binary classifier)
Tree_Model = fitensemble( ...
    TrainFeatMtx, ...               % Training Vectors, predictor values
    ClassActual, ...                % Actual class of each vector
    'Bag', ...                      % Method
    nlearncycles, ...               % Number of ensamble cycles
    'Tree', ...                     % Name of the weak learner for ensamble
    'CrossVal', 'off', ...          % Without crossfolding
    'PredictorNames', fvColIds, ... % Name of each feature column
    'Type', 'Classification', ...   % Type of learning 
    'Prior', prior);                % Set prior probabilities for classes

end
