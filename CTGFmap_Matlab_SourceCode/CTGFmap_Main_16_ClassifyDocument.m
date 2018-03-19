%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.06
%_application: CTGF Features mapping

clear
clc
dbstop if error

doc_id = input('Document Identification: ');

% Set Initial parameters
CTGFmap_IncludeConstants;
n_exp = C_NUM_OF_EXP - 1;
mtd = METHOD_TREE_ENSAMBLE;
rnk_type = RNK_ALL_RNDFOR;
[rnk_str, ~] = CTGFmap_Rank_Type(rnk_type);

diaryfile = strcat('classifydoc', rnk_str, '_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Classify Document +++');

[ClassNames, ~, FeatIdsFull, fv_length, ClassIds, DocIds, ...
    FrmIds, ~, FeatVecsFull, n_vec] = CTGFmap_LoadNormalizedData();
Classes = sort(unique(ClassIds));
n_cls = numel(Classes);

SelDoc = DocIds == doc_id;
n_frms = sum(SelDoc);
if n_frms <= 0
    error('!!!Error: Invalid document id!');
end

DocClassIds = ClassIds(SelDoc, :);
DocFrmIds   = FrmIds(SelDoc, :);
DocFeatVecs = FeatVecsFull(SelDoc, :);

DocPredClass = zeros(n_exp, n_cls, n_frms);

for exp_num = 1:n_exp
    
    for cls = 1:n_cls
         
        disp(['=== Begin testing document frames with class: ', ...
            num2str(Classes(cls)), ...
            ' best classifier, rank type: ', rnk_str, ...
            ', feature length: ', num2str(fv_length), ...
            ', method: ', num2str(mtd), ...
            ', experiment: ', num2str(exp_num), ...
            ' - ', datestr(datetime('now')), ' ===']);
        
        fsuffix = strcat('_C', num2str(Classes(cls)), ...
            '_R', num2str(rnk_type),...
            '_L', num2str(fv_length), ...
            '_M', num2str(mtd), ...
            '_E', num2str(exp_num));
        
        %********* Load Classifier Model **********
        [ClassModel, Rank, KeepVec, ClassImp] = ...
            CTGFmap_ClassModel_Load(fsuffix);
        if sum(KeepVec) ~= fv_length
            error('!!!Error: Invalid Keep Vector!');
        end
        
        %********* Prepare Data for Testing **********
        TestFeatVecs = DocFeatVecs(:, KeepVec);
        TestClass = DocClassIds;
        TestClass(DocClassIds == Classes(cls)) = C_CLASS_POSITIVE;
        TestClass(DocClassIds ~= Classes(cls)) = C_CLASS_NEGATIVE;
        n_ids = numel(TestClass);
        
        disp(['TestData(',num2str(n_frms),'x',num2str(fv_length), ...
            '), TestIds(',num2str(n_ids),')']);
        disp('Model:');
        disp(ClassModel);
        [PredClass, ConfMtx] = CTGFmap_predict_Test (ClassModel, ...
            TestFeatVecs, TestClass);
        
        Metrics = CTGFmap_CalcMetrics (ConfMtx);
        id_metrics = strcat('Class:', num2str(Classes(cls)), ...
            ' - ', num2str(exp_num));
        CTGFmap_DispMetrics (id_metrics, Metrics);
        
        PredClass(PredClass == C_CLASS_POSITIVE) = Classes(cls);
        PredClass(PredClass == C_CLASS_NEGATIVE) = 0;
        DocPredClass(exp_num, cls, :) = PredClass;

        %********* release resources **********
        clearvars ClassModel Rank KeepVec ClassImp FeatVecs FeatIds
        fclose('all');
        
        disp(['=== End testing document frames with class: ', ...
            num2str(Classes(cls)), ...
            ' best classifier, rank type: ', rnk_str, ...
            ', feature length: ', num2str(fv_length), ...
            ', method: ', num2str(mtd), ...
            ', experiment: ', num2str(exp_num), ...
            ' - ', datestr(datetime('now')), ' ===']);
        
    end
       
end

FrmClasses = DocPredClass(:);
FrmClasses(FrmClasses == 0) = [];
n_atrfrms_all = numel(FrmClasses);
attribcls     = mode(FrmClasses);
n_atrfrms_cls = sum(FrmClasses == attribcls);

disp(['------------------ Atribution results of document id: ', num2str(doc_id), ' --------------------']);
disp('---- Final classifiers applied: best feature vector length of all features ----');
disp('-------------------------------------------------------------------------------');
disp(['    Number of analyzed document''s frames .............................: ', ...
    num2str(n_frms)])
disp(['    Number of OvA (class x others) classifiers .......................: ', ...
    num2str(n_exp*n_cls)])
disp(['    Number of tests performed ........................................: ', ...
    num2str(n_exp*n_cls*n_frms)])
disp(['    Number of tests which returned an attributed class ...............: ', ...
    num2str(n_atrfrms_all)])
disp('    -------------------------------------------------------------------');
disp(['    Class attributed to document .....................................: ', ...
    num2str(attribcls)])
disp(['    Number of tests which returned this class ........................: ', ...
    num2str(n_atrfrms_cls)])
disp(['    % of tests with attributed class which returned this class .......: ', ...
    num2str(round(n_atrfrms_cls ./ n_atrfrms_all, 4) * 100), ' %'])
disp('    -------------------------------------------------------------------');

endtime = datetime('now');
disp(['+++ End - Step Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
