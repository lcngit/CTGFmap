%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.26
%_application: CTGF Features mapping

clear
clc
dbstop if error

mtrfname = input('Metrics file name = ', 's');
hipo_mtd = input('Hipothesis Test Method (1=Friedman, 2=Kruskal-Wallis, 3=ANOVA) = ');
if hipo_mtd == 1
    hip_tst = 'friedman';
    tst_str = 'Friedman';
elseif hipo_mtd == 2
    hip_tst = 'kruskalwallis';
    tst_str = 'Kruskal-Wallis';
elseif hipo_mtd == 3
    hip_tst = 'anova1';
    tst_str = 'ANOVA';
else
    error('!!!! Hipothesis Test Method selection is not 1 or 2 or 3 !!!!');
end

ctp = input('Statistical multcompare method (1=HSD Tukey, 2=Bonferroni) = ');
if ctp == 1
    ctype = 'hsd';
    ctp_str = 'Tukey''s honest significant difference criterion';
elseif ctp == 2
    ctype = 'bonferroni';
    ctp_str = 'Bonferroni method'; 
else
    error('!!!! Statistical multcompare method selection is not 1 or 2 !!!!');
end

scr_typ = input('Score (1=Mean, 2=Rank+Mean, 3=Mean-Stdv, 4=Rank+Mean-Stdv) = ');
if scr_typ == 1 
    scr_str = 'Column mean';
elseif scr_typ == 2 
    scr_str = 'Score of winner columns';
elseif scr_typ == 3 
    scr_str = 'Score of winner columns + Column mean';
elseif scr_typ == 4 
    scr_str = 'Score of winner columns + Column mean - Column std';
else
    error('!!!! Score selection is not in the range !!!!');
end

suffix = strcat('_H', num2str(hipo_mtd), 'C', num2str(ctp), 'S', num2str(scr_typ));

diaryfile = strcat('statcomp_metrics', suffix, '_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Metrics Statistical Comparison +++')

disp('--- Loading Metrics ---');
disp(['    Reading metrics from file: ', mtrfname]);
Metrics = csvread(mtrfname, 1, 0);
[nr_mtr, nc_mtr] = size(Metrics);
disp(['    Reading column names from file: ', mtrfname]);
fidmtr = fopen(mtrfname,'r');
mtrline = fgetl(fidmtr);
Hdr = textscan(mtrline,'%s', nc_mtr,'Delimiter',',');
Names = Hdr{1};
fclose(fidmtr);

suffix = strcat(suffix, '_', num2str(nr_mtr), 'x', num2str(nc_mtr));   

disp (['    Metrics: rows = ', num2str(nr_mtr), ...
    ', columns = ', num2str(nc_mtr)]);
ColumnMin  = min(Metrics)';
ColumnMean = mean(Metrics)';
ColumnMax  = max(Metrics)';
ColumnStd  = std(Metrics)';
ColMeanMinusStdv = ColumnMean - ColumnStd;


disp(' ');
disp(['--- ', num2str(nc_mtr), ...
    ' columns of metrics to statiscally compare ---']);
for col = 1:nc_mtr
    disp(['    Column #', num2str(col), ...
        ' name = ', char(Names{col}), ...
        ', rows = ', num2str(nr_mtr), ...
        ', min = ', num2str(round(ColumnMin(col), 2)), ...
        ', mean = ', num2str(round(ColumnMean(col), 2)), ...
        ', max = ', num2str(round(ColumnMax(col), 2)), ...
        ', std = ', num2str(round(ColumnStd(col), 2)), ...
        ', mean-std = ', num2str(round(ColMeanMinusStdv(col), 2))]);
end

disp(' ');
disp(['--- Comparing metrics using statistical test: ', tst_str, ' ---']);
if hipo_mtd == 1
    [p, table, stats] = friedman(Metrics);
elseif hipo_mtd == 2
    [p, table, stats] = kruskalwallis(Metrics);
elseif hipo_mtd == 3
    [p, table, stats] = anova1(Metrics);
else
    error('!!!! impossible!');
end

disp (['    ', tst_str, ' p_value = ', num2str(p)]);

disp(' ');
disp('--- Multcompare columns using the result of previous statistical test ---');
disp(['--- Type of critical value: ', ctp_str, ' ---']);

[c, m, ~, ~] = multcompare(stats, 'ctype', ctype, 'estimate', hip_tst);

[ncomp, ~] = size(c);
AbetterB = zeros(nc_mtr, nc_mtr);

for par = 1 : ncomp
    col = c(par, 1);
    j = c(par, 2);
    if (c(par, 3) < 0) && (c(par, 5) > 0)
        disp(['Column #', num2str(col), ' (', char(Names{col}), ...
            ') is equal to column #', ...
            num2str(j), ' (', char(Names{j}), ')']);
        AbetterB (col, j) = 0;
        AbetterB (j, col) = 0;
    else
        if ColumnMean(col) > ColumnMean(j)
            disp(['Column #', num2str(col), ' (', char(Names{col}), ...
                ') is better than  column #', ...
                num2str(j), ' (', char(Names{j}), ')']);
            AbetterB (col, j) = 1;
            AbetterB (j, col) = -1;
        else
            disp(['Column #', num2str(col), ' (', char(Names{col}), ...
                ') is worse than  column #', ...
                num2str(j), ' (', char(Names{j}), ')']);
            AbetterB (col, j) = -1;
            AbetterB (j, col) = 1;
        end
    end
end

disp(' ');
disp(['--- Ranking columns using: ', scr_str, ' ---']);

Rank = (sum(AbetterB > 0, 2, 'double') * 0.2) + (sum(AbetterB == 0, 2, 'double') * 0.1);
if scr_typ == 1
    MethodScore = ColumnMean;
elseif scr_typ == 2
    MethodScore =  Rank + ColumnMean;
elseif scr_typ == 3
    MethodScore = ColMeanMinusStdv;
else
    MethodScore = Rank + ColMeanMinusStdv;
end
[SortedScore, IdxScore] = sortrows(MethodScore, -1);

for rnk = 1:numel(IdxScore)
    col = IdxScore(rnk);
    disp(['    Rank #', num2str(rnk), ...
        ' - Column #', num2str(col), ...
        ' name = ', char(Names{col}), ...
        ', score = ',  num2str(MethodScore(col)), ...
        ', mean = ', num2str(round(ColumnMean(col), 2)), ...
        ', std = ', num2str(round(ColumnStd(col), 2)), ...
        ', mean-std = ', num2str(round(ColMeanMinusStdv(col), 2))]);
end

% Save Methods comparison results
disp(' ');
outfname = strcat('MetricsComparedStats', suffix, '.csv');
disp (['### Metrics Statistical Comparison file = ', outfname]);
csvwrite (outfname, [ColumnMean, MethodScore, AbetterB]);

outfname = strcat('MetricsComparedSort', suffix, '.csv');
disp (['### Metrics Sorted Score file = ', outfname]);
csvwrite (outfname, SortedScore);
