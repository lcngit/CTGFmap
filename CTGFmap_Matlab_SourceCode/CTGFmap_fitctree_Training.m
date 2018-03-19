%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function Tree_Model = CTGFmap_fitctree_Training (TrainFeatMtx, ...
    ClassActual, fvColIds, max_split, prior, split_crit)
% Tree Binary classifier, ClassActual is interpreted as:
%    ClassActual[i] = -1 -> first class on confusion matrix, negative class
%    ClassActual[i] = 1 -> second class on confusion matrix, positive class
Err = (ClassActual ~= -1) & (ClassActual ~= 1);
if sum(Err) ~= 0
    error('Program aborted in Tree Training consistency - Class vector is not (-1, 1)')
end

% if max_split is 0 then use as default
if max_split == 0
    [~ , nc] = size(TrainFeatMtx);
    max_split = nc - 1;
end

% Train classifier generating Tree model (binary classifier)
Tree_Model = fitctree(...
    TrainFeatMtx, ...               % Training Vectors, predictor values
    ClassActual, ...                % Actual class of each vector
    'CrossVal', 'off', ...          % Without crossfolding
    'MaxNumSplits', max_split, ...  % Maximum number of tree nodes = decision splits
    'PredictorNames', fvColIds, ... % Name of each feature column
    'Prior', prior, ...             % Set prior probabilities for classes
    'SplitCriterion', split_crit);  % Split criterion for node decision

end
