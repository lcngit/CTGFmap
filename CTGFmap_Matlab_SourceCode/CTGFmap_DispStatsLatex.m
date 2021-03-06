%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.3r0/2017.09.24
%_application: CTGF Features mapping

function CTGFmap_DispStatsLatex(Classes, FinalStats, FVLengths)

CTGFmap_IncludeConstants;

n_cls = numel(Classes);
curdir = strrep(strrep(pwd,'\','/'),'_','\_');

disp('--- Classifier metrics Latex table ---');
disp(' ');
disp('\begin{table}[!htb]');
disp('	%\renewcommand{\arraystretch}{1.2}');
disp(['	\caption{Metrics from files in folder ',  curdir, ...
    '.\label{tab:metrics}}']);
disp('    \begin{center}');
disp('    \begin{adjustbox}{max totalsize={\textwidth}{0.9\textheight}}');
disp('      \begin{tabular}{|c|c|cccc|ccccc|}');
disp('            \hline');
disp(['            Class', ...
    ' & Vector', ...
    ' & True', ...
    ' & False', ...
    ' & True', ...
    ' & False', ...
    ' & Acc', ...
    ' & Rcl', ...
    ' & Spc', ...
    ' & Prc', ...
    ' & F1s', ...
    ' \\']);
disp(['            ', ...
    ' & Length', ...
    ' & Pos', ...
    ' & Pos', ...
    ' & Neg', ...
    ' & Neg', ...
    ' & \%', ...
    ' & \%', ...
    ' & \%', ...
    ' & \%', ...
    ' & \%', ...
    ' \\']);
disp('            \hline');
for cls = 1:n_cls
    truepos  = FinalStats(cls, METRIC_TRUEPOS);
    falsepos = FinalStats(cls, METRIC_FALSEPOS);
    trueneg  = FinalStats(cls, METRIC_TRUENEG);
    falseneg = FinalStats(cls, METRIC_FALSENEG);
    meanacc  = round(FinalStats(cls, METRIC_ACCURACY), 4) * 100;
    meanrcl  = round(FinalStats(cls, METRIC_RECALL), 4) * 100;
    meanspc  = round(FinalStats(cls, METRIC_SPECIFICITY), 4) * 100;
    meanprc  = round(FinalStats(cls, METRIC_PRECISION), 4) * 100;
    meanf1s  = round(FinalStats(cls, METRIC_F1SCORE), 4) * 100;
    disp(['            ', num2str(Classes(cls)), ...
        ' & ', num2str(FVLengths(cls)), ...
        ' & ', num2str(truepos), ...
        ' & ', num2str(falsepos), ...
        ' & ', num2str(trueneg), ...
        ' & ', num2str(falseneg), ...
        ' & ', num2str(meanacc), ...
        ' & ', num2str(meanrcl), ...
        ' & ', num2str(meanspc), ...
        ' & ', num2str(meanprc), ...
        ' & ', num2str(meanf1s), ...
        ' \\']);
end
meanacc  = round(mean(FinalStats(:, METRIC_ACCURACY)), 4) * 100;
meanrcl  = round(mean(FinalStats(:, METRIC_RECALL)), 4) * 100;
meanspc  = round(mean(FinalStats(:, METRIC_SPECIFICITY)), 4) * 100;
meanprc  = round(mean(FinalStats(:, METRIC_PRECISION)), 4) * 100;
meanf1s  = round(mean(FinalStats(:, METRIC_F1SCORE)), 4) * 100;
stdvacc  = round(std(FinalStats(:, METRIC_ACCURACY)), 4) * 100;
stdvrcl  = round(std(FinalStats(:, METRIC_RECALL)), 4) * 100;
stdvspc  = round(std(FinalStats(:, METRIC_SPECIFICITY)), 4) * 100;
stdvprc  = round(std(FinalStats(:, METRIC_PRECISION)), 4) * 100;
stdvf1s  = round(std(FinalStats(:, METRIC_F1SCORE)), 4) * 100;
disp('            \hline');
disp('            \hline');
disp(['            \multicolumn{6}{|r|}{Mean}', ...
    ' & ', num2str(meanacc), ...
    ' & ', num2str(meanrcl), ...
    ' & ', num2str(meanspc), ...
    ' & ', num2str(meanprc), ...
    ' & ', num2str(meanf1s), ...
    ' \\']);
disp(['            \multicolumn{6}{|r|}{$\sigma$}', ...
    ' & ', num2str(stdvacc), ...
    ' & ', num2str(stdvrcl), ...
    ' & ', num2str(stdvspc), ...
    ' & ', num2str(stdvprc), ...
    ' & ', num2str(stdvf1s), ...
    ' \\']);
disp('            \hline');
disp('      \end{tabular}');
disp('	\end{adjustbox}');
disp('	\end{center}');
disp('\end{table}');

end
