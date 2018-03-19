%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

clear
clc
dbstop if error

CTGFmap_IncludeConstants;

rnk_input = input('Rank type (0 to 7): ');
[rnk_str, feat_str] = CTGFmap_Rank_Type(rnk_input);
rnk_type = rnk_input;
n_most = input('Number of most important features to display: ');
exp_num = 1;

diaryfile = strcat('dvgcharts', rnk_str, num2str(n_most), '_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Divergence Charts +++');

idsfname = strcat('ImgClassIds.csv');
disp(['*** Reading Classes from file: ', idsfname, ' ***']);
ImgClsIds = csvread(idsfname);
Classes = sort(unique(ImgClsIds));
n_cls = numel(Classes);

dvgfname = 'FrmFeatVec_Divg.csv';
disp(['*** Reading Features Divergence from file: ', dvgfname, ' ****']);
ClassDivg = csvread(dvgfname);
[ne_divg, fv_length] = size(ClassDivg);
max_imp = max(max(ClassDivg));
min_imp = min(min(ClassDivg));

keepfname = 'FrmFeatVec_Keep.csv';
disp(['*** Reading Features initial keep vector from file: ', keepfname, ' ****']);
FV_Keep = csvread(keepfname);
fv_full_length = numel(FV_Keep);
FV_Xidx = find(FV_Keep);
if numel(FV_Xidx) ~= fv_length
    error('!!!Error: Initial keep vector indexes does not match divergence!');
end

ClassDivgFull = zeros(n_cls, fv_full_length);
ClassDivgFull(:, FV_Xidx) = ClassDivg;

if n_most > 0
    rnkfname = strcat('FrmFeatVec_NewRank_', rnk_str, '_Final.csv');
    disp(['*** Reading Features Rank from file: ', rnkfname, ' ****']);
    AllRank = csvread(rnkfname);
    [nr_rnk, nc_rnk] = size(AllRank);
    if nr_rnk ~= n_cls || nc_rnk ~= fv_length
        error('!!!Error: Rank does not match with divergence file!');
    end
    FullRank = zeros(n_cls, fv_full_length);
    FullRank(:, FV_Xidx) = AllRank;
end

disp(['=== Begin - Building Charts for all classes - ', datestr(now), ' ===']);

n_ltx = 5;
TexMtr = zeros(n_cls, n_ltx);

for cls = 1:n_cls
    
    disp(['--- Build Charts and Display Statistics of ', num2str(n_most), ...
        ' most important features of class ', num2str(Classes(cls)), ...
        ' - ', datestr(now), ' ---']);
    
    sumdvg = sum(abs(ClassDivgFull(Classes(cls), :)));
    if sumdvg == 0
        error('!!!Error: Sum of absolut divergences equals zero!');
    end
    TexMtr(cls, 1) = Classes(cls);
    SelPos = ClassDivgFull(cls, :) > 0;
    SelZer = ClassDivgFull(cls, :) == 0;
    SelNeg = ClassDivgFull(cls, :) < 0;
    n_pos = sum(SelPos);
    TexMtr(cls, 2) = n_pos;
    n_zer = sum(SelZer);
    TexMtr(cls, 3) = n_zer;
    n_neg = sum(SelNeg);
    TexMtr(cls, 4) = n_neg;
    sumabs = sum(abs(ClassDivgFull(cls, :))) / sumdvg;
    sumpos = sum(ClassDivgFull(cls, SelPos)) / sumdvg;
    TexMtr(cls, 5) = round(sumpos, 4) * 100;
    sumneg = sum(ClassDivgFull(cls, SelNeg));
    disp(['cls=', num2str(cls), ' ', ...
        'npos=', num2str(n_pos), ' ', ...
        'nzer=', num2str(n_zer), ' ', ...
        'nneg=', num2str(n_neg), ' ', ...
        'sumabs=', num2str(sumabs), ' ', ...
        'sumpos=', num2str(round(sumpos, 2)), ' ', ...
        'sumneg=', num2str(round(sumneg, 2)), ' ', ...
        ]);
    
    X_values = 0:(fv_full_length-1);
    fig1 = figure;
    p = bar(X_values, ClassDivgFull(cls, :), 0.5);
    ax = gca;
    ax.YLim = [min_imp max_imp];
    ax.XLim = [-20 (fv_full_length+20)];
    ax.XTick = 0:200:2200;
    ax.TickDir = 'out';
    ax.FontSize = 14;
    hold on
    if n_most > 0
        Rank = FullRank(cls, :);
        SelMost = Rank > 0 & Rank <= n_most;
        X_Most = X_values(SelMost);
        Y_Most = ClassDivgFull(cls, SelMost);
        plot(X_Most, Y_Most, '.r');
        lgd1 = legend('  Max cumulative probability difference', ...
            ['  ', num2str(n_most), ' most discriminant ', feat_str, ' features'], ...
            'Location', 'south');
    else
        lgd1 = legend('  Max cumulative probability difference', ...
            'Location', 'southwest');
    end
    xlabel(['Feature (X', num2str(X_values(1)), ' to X', num2str(X_values(end)), ')']);
    ylabel('Cumulative probability difference');
    title(['Class ', num2str(cls), ' - Features Max Cumulative Probability Difference'])
    lgd1.FontSize = 12;
    fig1.Units = 'centimeters';
    fig1.Position = [0.5, 0.5, 25, 15];
    fig1.PaperType = 'a4';
    fig1.PaperOrientation = 'landscape';
    hold off
    
    figfname = strcat('FeaturesDivgChart_C', num2str(cls), ...
        '_', rnk_str, num2str(n_most), '_A4_300dpi');
    print(figfname,'-dpdf', '-r300');
    
end

disp('-------- LaTex table -------');
disp('\hline');
for cls = 1:n_cls
    lin = '';
    for i = 1:n_ltx
        lin = strcat(lin, num2str(TexMtr(cls, i)));
        if i < n_ltx
            lin = strcat(lin, '#&#');
        else
            lin = strcat(lin, '#\\');
        end
    end
    lin = strrep(lin, '#', ' ');
    disp(lin);
    disp('\hline');
end

close all

endtime = datetime('now');
disp(['+++ End - Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
