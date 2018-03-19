%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.2r0/2017.09.16
%_application: CTGF Features mapping

function [TrainedModel, elaptrain, n_vec] = CTGFmap_ClassModel_Train(...
    cls_id, mtd, exp_num, ExpPlan, FeatVecs, FeatureIds, ClassIds, ...
    DocIds, FrmIds)

CTGFmap_IncludeConstants;
tic

disp(['*** Begin Training of Classifier for class: ', num2str(cls_id), ...
    ' - experiment: ', num2str(exp_num), ' - One Versus All - ', ...
    datestr(datetime('now')), ' ***'])

% Get Training data
[TrainFeatVecs, ActualClass, ~, ~, ~, ~] = CTGFmap_SelectExpVectors(cls_id, ...
    C_EXP_TRAINING, ExpPlan, FeatVecs, ClassIds, DocIds, FrmIds);
[n_vec, train_fv_length] = size(TrainFeatVecs);
n_ids = numel(ActualClass);

prob_pos = sum(ActualClass == C_CLASS_POSITIVE) / n_vec;
prob_neg = sum(ActualClass == C_CLASS_NEGATIVE) / n_vec;
prior = [prob_neg, prob_pos];

% Binary classifier training
disp(['    TrainData(',num2str(n_vec),'x',num2str(train_fv_length), ...
    '), TrainIds(',num2str(n_ids),')']);
disp(['    Positive class probability = ',num2str(prob_pos),...
    ', Negative class probability = ',num2str(prob_neg)]);

if mtd == METHOD_SVM_ISDA
    TrainedModel = CTGFmap_fitcsvm_Training (TrainFeatVecs, ...
        ActualClass, FeatureIds, 0, 0, 'ISDA', prior);
elseif mtd == METHOD_SVM_OLD
    TrainedModel = CTGFmap_svmtrain_Training (TrainFeatVecs, ...
        ActualClass, 0, 0);
elseif mtd == METHOD_TREE_ENSAMBLE
    TrainedModel = CTGFmap_fitcensembletree_Training (TrainFeatVecs, ...
        ActualClass, FeatureIds, 0, prior);
elseif mtd == METHOD_TREE_GDI
    TrainedModel = CTGFmap_fitctree_Training (TrainFeatVecs, ...
        ActualClass, FeatureIds, 0, prior, 'gdi');
elseif mtd == METHOD_TREE_TWOING
    TrainedModel = CTGFmap_fitctree_Training (TrainFeatVecs, ...
        ActualClass, FeatureIds, 0, prior, 'twoing');
elseif mtd == METHOD_TREE_DEVIANCE
    TrainedModel = CTGFmap_fitctree_Training (TrainFeatVecs, ...
        ActualClass, FeatureIds, 0, prior, 'deviance');
else
    TrainedModel = CTGFmap_fitcsvm_Training (TrainFeatVecs, ...
        ActualClass, FeatureIds, 0, 0, 'SMO', prior);
end

disp ('    Model trained:');
disp (TrainedModel)

disp(['*** End Training of Classifier for class: ', num2str(cls_id), ...
    ' - experiment: ', num2str(exp_num), ' - One Versus All - ', ...
    datestr(datetime('now')), ' ***'])

elaptrain = toc;

end

