%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.0r0/2017.09.20
%_application: CTGF Features mapping

clear
clc

CTGFmap_IncludeConstants;

mtr1dir = input('First method metrics folder: ', 's');
mtr1dir = strrep(mtr1dir, '\', '/');
if mtr1dir(end) ~= '/'
    mtr1dir = strcat(mtr1dir, '/');
end
selmtd1 = input('Select method of first method metrics (0 = SVM, 1 = RndFor): ');
if selmtd1 == 0
    mtd1 = METHOD_SVM_SMO;
    mtd1_str = 'SVM SMO Linear';
    mtdl_abrv = 'SVM';
else
    mtd1 = METHOD_TREE_ENSAMBLE;
    mtd1_str = 'Random Forest';
    mtdl_abrv = 'RandFor';
end

mtr2dir = input('Second method metrics folder: ', 's');
mtr2dir = strrep(mtr2dir, '\', '/');
if mtr2dir(end) ~= '/'
    mtr2dir = strcat(mtr2dir, '/');
end
selmtd2 = input('Select method of second method metrics folder(0 = SVM, 1 = RndFor): ');
if selmtd2 == 0
    mtd2 = METHOD_SVM_SMO;
    mtd2_str = 'SVM SMO Linear';
    mtd2_abrv = 'SVM';
else
    mtd2 = METHOD_TREE_ENSAMBLE;
    mtd2_str = 'Random Forest';
    mtd2_abrv = 'RandFor';
end

rnk_input = input('Rank type (0 to 7): ');
[rnk_str, ~] = CTGFmap_Rank_Type(rnk_input);
rnk_type = rnk_input;
tst_type = input('Test type (2 = validation, 3 = final test): ');

mtr_cmp = input('Metric to compare (0=Accuracy, 1= Recall, 2=Precision, 3=F1score): ');
if mtr_cmp == 0
    mtr_offset = C_HDRMTR_LENGTH + METRIC_ACCURACY;
    mtr_str = 'Acc';
elseif mtr_cmp == 1
    mtr_offset = C_HDRMTR_LENGTH + METRIC_RECALL;
    mtr_str = 'Rec';
elseif mtr_cmp == 2
    mtr_offset = C_HDRMTR_LENGTH + METRIC_PRECISION;
    mtr_str = 'Prc';
elseif mtr_cmp == 3
    mtr_offset = C_HDRMTR_LENGTH + METRIC_F1SCORE;
    mtr_str = 'F1s';
else
    error('!!!!! Invalid metric selected!');
end

diaryfile = strcat('mtdcompare_R', num2str(rnk_type), ...
    '_M', num2str(mtd1), '_M', num2str(mtd2), '_metrics_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Metrics Statistical comparison +++')

disp(['--- Loading Metrics file for first method, mtd = ', ...
    num2str(mtd1), ' ---']);
mtr1t2f1 = strcat(mtr1dir, 'ClassDocDetMetrics_M', num2str(mtd1), '_', ...
    rnk_str, '_T', num2str(tst_type), '_S0.csv');
disp(['    Reading validation metrics file: ', mtr1t2f1]);
Metrics_1 = csvread(mtr1t2f1);
[nr_t1, nc_t1] = size(Metrics_1);

disp(['--- Loading Metrics file for second method, mtd = ', ...
    num2str(mtd2), ' ---']);
mtr1t2f2 = strcat(mtr2dir, 'ClassDocDetMetrics_M', num2str(mtd2), '_', ...
    rnk_str, '_T', num2str(tst_type), '_S0.csv');
disp(['    Reading validation metrics file: ', mtr1t2f2]);
Metrics_2 = csvread(mtr1t2f2);
[nr_t2, nc_t2] = size(Metrics_2);

if nr_t1 ~= nr_t2 || nc_t1 ~= nc_t2
    error('!!!! Metric files does not match!');
end

HdrMetr = horzcat(Metrics_1(:, 1:C_HDRMTR_LENGTH), ...
    Metrics_2(:, 1:C_HDRMTR_LENGTH));
Metrics = horzcat(Metrics_1(:, mtr_offset), Metrics_2(:, mtr_offset));
[n_exp, ~] = size(Metrics);

disp(' ');
disp('\begin{table}[htb!]');
disp(['    \caption{', mtr_str, ' of experiments using ', mtd1_str, ...
    ' and ', mtd2_str, ...
    ' algorithms using same partitions, processes and programs ', ...
    ' of the proposed method. Test type: 2=Validation, 3=Final Test.)', ...
    ' \label{tab:RndForSVMmetric}}']);
disp('    \begin{center}');
disp('    \begin{adjustbox}{max totalsize={\textwidth}{0.9\textheight}}');
disp('      \begin{tabular}{|cccc|c|c|}');
disp('            \hline');
disp(['            \multicolumn{4}{|c|}{Experiments} & ', mtdl_abrv, ...
    ' & ', mtd2_abrv, ' \\']);
disp('            \hline');
disp(['            Class & Exp. & Test & Vector & ', mtr_str, ...
    ' &  ', mtr_str, ' \\']);
disp('            & Num. & Type & Length & \%      & \% \\');
disp('            \hline');
disp('            \hline');
for i = 1:n_exp
    disp(['            ', ...
        num2str(HdrMetr(i, C_HDRMTR_CLASS)), ' & ', ...
        num2str(HdrMetr(i, C_HDRMTR_EXPNUM)), ' & ', ...
        num2str(HdrMetr(i, C_HDRMTR_TSTID)), ' & ', ...
        num2str(HdrMetr(i, C_HDRMTR_FVLENGTH)), ' & ', ...
        num2str(round(Metrics(i, 1),4)*100), ' & ', ...
        num2str(round(Metrics(i, 2),4)*100), ' \\']);
end
Mtr_min  = min(Metrics);
Mtr_mean = mean(Metrics);
Mtr_max  = max(Metrics);
Mtr_std  = std(Metrics);
disp('            \hline');
disp('            \hline');
disp(['            \multicolumn{4}{|r|}{Min} & ', ...
    num2str(round(Mtr_min(1),4)*100), ' & ', ...
    num2str(round(Mtr_min(2),4)*100), ' \\']);
disp(['            \multicolumn{4}{|r|}{Mean} & ', ...
    num2str(round(Mtr_mean(1),4)*100), ' & ', ...
    num2str(round(Mtr_mean(2),4)*100), ' \\']);
disp(['            \multicolumn{4}{|r|}{Max} & ', ...
    num2str(round(Mtr_max(1),4)*100), ' & ', ...
    num2str(round(Mtr_max(2),4)*100), ' \\']);
disp(['            \multicolumn{4}{|r|}{$\sigma$} & ', ...
    num2str(round(Mtr_std(1),4)*100), ' & ', ...
    num2str(round(Mtr_std(2),4)*100), ' \\']);
disp('            \hline');
disp('      \end{tabular}');
disp('    \end{adjustbox}');
disp('    \end{center}');
disp('\end{table}');

disp(' ');
disp('\begin{table}[htb!]');
disp(['    \caption{Statistical comparison between ', mtd1_str, ' and ', ...
    mtd2_str, ' of experiment metrics exposed in ', ...
    'Table~\ref{tab:RndForSVMmetric} \label{tab:RndForSVMcomp}}']);
disp('    \begin{center}');
disp('    \begin{adjustbox}{max totalsize={\textwidth}{0.9\textheight}}');
disp('      \begin{tabular}{|c|c|c|c|}');
disp('            \hline');
disp('           Statistical Test & p & Null Hipothesis & Comparison \\');
disp('            \hline');
disp('            \hline');
for t = 1:3
    if t == 1
        p = friedman(Metrics);
        tst_str = 'Friedman';
    elseif t == 2
        p = kruskalwallis(Metrics);
        tst_str = 'Kruskal-Wallis';
    elseif t == 3
        p = anova1(Metrics);
        tst_str = 'ANOVA';
    else
        error('!!!! impossible!');
    end
    if p < 0.3
        hipo_str = 'Rejected';
        if Mtr_mean(1) > Mtr_mean(2)
            bettermtd = mtd1_str;
            worsemtd = mtd2_str;
        else
            bettermtd = mtd1_str;
            worsemtd = mtd2_str;
        end
        comp_str = [bettermtd, ' is better than ', worsemtd];
    elseif p > 0.7
        hipo_str = 'Not rejected';
        comp_str = [bettermtd, ' is equal to ', worsemtd];
    else
        hipo_str = 'Undefined';
        comp_str = 'Undefined';
    end
    disp(['            ', tst_str, ' & ', num2str(p), ' & ', ...
        hipo_str, ' & ', comp_str, ' \\']);
end
disp('            \hline');
disp('      \end{tabular}');
disp('    \end{adjustbox}');
disp('    \end{center}');
disp('\end{table}');

disp(' ');
endtime = datetime('now');
disp(['+++ End - Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
