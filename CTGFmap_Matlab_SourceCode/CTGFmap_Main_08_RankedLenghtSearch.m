%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.2r0/2017.09.16
%_application: CTGF Features mapping

clear
clc
dbstop if error

% Set Initial parameters
CTGFmap_IncludeConstants;
n_exp = C_NUM_OF_EXP - 1;
mtd = METHOD_TREE_ENSAMBLE;

red_factor = input('Length reduction factor in each iteration: ');
if red_factor < 0.1 || red_factor > 0.9
    error('!!!Error: reduction factor should be between 0.1 and 0.9');
end
rnk_input = input('Rank type (0=all, 1=positive, -1=negative): ');
switch rnk_input
    case 0
        rnk_type = RNK_ALL_RNDFOR;
    case 1
        rnk_type = RNK_POS_RNDFOR;
    case -1
        rnk_type = RNK_NEG_RNDFOR;
    otherwise
        error('!!!Error: Invalid Rank Type!');
end
[rnk_str, ~] = CTGFmap_Rank_Type(rnk_type);

diaryfile = strcat('lengthsearch', rnk_str, '_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Length Search +++');

[ClassNames, ~, FeatIdsFull, fv_length, ClassIds, DocIds, ...
    FrmIds, DsetPlan, FeatVecsFull, n_vec] = CTGFmap_LoadNormalizedData();
Classes = sort(unique(ClassIds));
n_cls = numel(Classes);

ClassesRank = CTGFmap_LoadRanks(Classes, fv_length, rnk_type);

K_lengths = max(ClassesRank, [], 2);
Min_f1score  = zeros(n_cls, 1);
Min_lengths  = K_lengths;
Best_f1score = zeros(n_cls, 1);
Best_lengths = K_lengths;
Iterations   = ones(n_cls, 1);
Finished     = zeros(n_cls, 1);

count_iter = 0;
while true
    
    count_iter = count_iter + 1;
    ClassesRcl = zeros(n_cls, n_exp);
    ClassesPrc = zeros(n_cls, n_exp);
    ClassesF1s = zeros(n_cls, n_exp);
    
    % reset new ranks to the last effective for each class
    NewClassesRank = ClassesRank;
    
    for exp_num = 1:n_exp
        
        for cls = 1:n_cls
            Rank = NewClassesRank(cls, :); % work with new updated ranks
            k_length = K_lengths(cls);
            ExpPlan = DsetPlan(:, exp_num);
            [KeepVec, NewRank, ~, ~] = CTGFmap_ClassModel_Iteration(Iterations(cls), ...
                Classes(cls), k_length, mtd, exp_num, ExpPlan, rnk_type, Rank,...
                false, FeatVecsFull, FeatIdsFull, ClassIds, DocIds, FrmIds);
            if ~isempty(NewRank)
                NewerRank = CTGFmap_Rank_Combine(NewClassesRank(cls, :), ...
                    NewRank, KeepVec);
                NewClassesRank(cls, :) = NewerRank;
                Iterations(cls) = Iterations(cls) + 1;
            end
        end
        
        DocMetrics = CTGFmap_Experiment_FrmToDoc(Classes, exp_num, ...
            C_EXP_VALIDATION, mtd, rnk_type, 0, K_lengths, count_iter);
        for cls = 1:n_cls
            ClassesRcl(cls, exp_num) = DocMetrics(C_HDRMTR_LENGTH + METRIC_RECALL, cls);
            ClassesPrc(cls, exp_num) = DocMetrics(C_HDRMTR_LENGTH + METRIC_PRECISION, cls);
            ClassesF1s(cls, exp_num) = DocMetrics(C_HDRMTR_LENGTH + METRIC_F1SCORE, cls);
        end
        
    end
    
    for cls = 1:n_cls % update classes results
        
        if Finished(cls) == 0 % if class not finalized then consider results
            
            % Update best f1score
            meanf1s = mean(ClassesF1s(cls, :));
            if Best_f1score(cls) <= meanf1s
                Best_f1score(cls) =  meanf1s;
                Best_lengths(cls) = K_lengths(cls);
            end
            
            % verify if results of this iteration should be considered
            % or finalize search for the class
            meanrcl = mean(ClassesRcl(cls, :));
            meanprc = mean(ClassesPrc(cls, :));
            disp(['--- Class: ', num2str(Classes(cls)), ...
                ', length: ', num2str(K_lengths(cls)), ...
                ', mean recall: ', num2str(meanrcl*100), ...
                '%, mean precision: ', num2str(meanprc*100), ...
                '%, mean f1score: ', num2str(meanf1s*100), ...
                '% ---']);
            if (meanrcl < MIN_THSR_METRIC) || (meanprc < MIN_THSR_METRIC)
                Finished(cls) = 1;
                % keep last min length results for frame attribution on
                % next grid search
                K_lengths(cls) = Min_lengths(cls); 
                disp(['--- Class: ', num2str(cls), ...
                    ' - minimum length achieved - search finished ---']);
            else
                % update minimum length and make effective last updated
                % rank
                Min_lengths(cls) = K_lengths(cls);
                Min_f1score(cls) = meanf1s;
                ClassesRank(cls, :) = NewClassesRank(cls, :);
                % Update lenght for a new iteration or finalize if achieve
                % length 1
                if K_lengths(cls) <= 1
                    Finished(cls) = 1;
                    disp(['--- Class: ', num2str(Classes(cls)), ...
                        ' - minimum length equals 1 - search finished ---']);
                else
                    if K_lengths(cls) <= 10
                        K_lengths(cls) = K_lengths(cls) - 1;
                    else
                        K_lengths(cls) = floor(K_lengths(cls) * red_factor);
                    end
                    if K_lengths(cls) < 1
                        K_lengths(cls) = 1;
                    end
                end
            end
        end
    end
    disp(' ');
    
    % write updated rank
    outfname = strcat('FrmFeatVec_NewRank_', rnk_str, ...
        '_', num2str(count_iter), '.csv');
    dlmwrite(outfname, ClassesRank, 'delimiter', ',', 'precision', 12);
    disp(['*** Class New Feature Rank Vectors saved into file: ', outfname, ' ****']);
    
    % if search finalized for all classes, then end search
    if sum(Finished) == n_cls
        break;
    end
    disp(' ');

end

disp('++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
for cls = 1:n_cls
    disp(['Class: ', num2str(Classes(cls)), ...
        ', Iterations: ', num2str(Iterations(cls)), ...
        ', Min Length: ', num2str(Min_lengths(cls)), ...
        ', Min F1score: ', num2str(round(Min_f1score(cls)*100, 2)), '%', ...
        ', Best Length: ', num2str(Best_lengths(cls)), ...
        ', Best F1score: ', num2str(round(Best_f1score(cls)*100, 2)), '%',]);
end
disp('++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

outfname = strcat('FrmFeatVec_Length_', rnk_str,'.csv');
LengthMetrics = [Iterations, Min_lengths, Min_f1score, Best_lengths, Best_f1score];
dlmwrite(outfname, LengthMetrics, 'delimiter', ',', 'precision', 12);
disp(['*** Length ', rnk_str, ' metrics saved into file: ', outfname, ' ****']);

outfname = strcat('FrmFeatVec_NewRank_', rnk_str, ...
    '_Final.csv');
dlmwrite(outfname, ClassesRank, 'delimiter', ',', 'precision', 12);
disp(['*** Class New Feature Rank Vectors saved into file: ', outfname, ' ****']);

endtime = datetime('now');
disp(['+++ End - Step Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
