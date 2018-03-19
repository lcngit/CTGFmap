%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.2r0/2018.03.18
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
disp('+++ Importance Charts +++');

idsfname = strcat('ImgClassIds.csv');
disp(['*** Reading Classes from file: ', idsfname, ' ***']);
ImgClsIds = csvread(idsfname);
Classes = sort(unique(ImgClsIds(:,1)));
n_cls = numel(Classes);

divgfname = 'FrmFeatVec_Divg.csv';
disp(['*** Reading Features Divergence from file: ', divgfname, ' ****']);
ClassDivg = csvread(divgfname);
[n_divg, fv_length] = size(ClassDivg);

xdvgfname = 'FrmFeatVec_Xdvg.csv';
disp(['*** Reading Features Frequency Xdvg from file: ', xdvgfname, ' ****']);
ClassXdvg = csvread(xdvgfname);

keepfname = 'FrmFeatVec_Keep.csv';
disp(['*** Reading Features initial keep vector from file: ', keepfname, ' ****']);
KeepVector = csvread(keepfname);
fv_full_length = numel(KeepVector);
FV_Xidx = find(KeepVector);
if numel(FV_Xidx) ~= fv_length
    error('!!!Error: Initial keep vector indexes does not match X divergence!');
end

maxfname = 'FrmFeatVec_Max.csv';
disp(['*** Reading X max normalization values from file: ', maxfname, ' ***']);
MaxXval = csvread(maxfname);
MaxXval = MaxXval(KeepVector ~= 0);
fv_len_max = numel(MaxXval);
if fv_len_max ~= fv_length
    error('!!! Error: X max normalization and Rank vectors do not match!');
end
disp('*** Denormalizing Feature Vectors to show actual feature values distribution ***');
for i = 1:fv_length
    ClassXdvg(:, i) = ClassXdvg(:, i) .* MaxXval(i);
end

ClassDivgFull = zeros(n_cls, fv_full_length);
ClassDivgFull(:, FV_Xidx) = ClassDivg;
ClassXdvgFull = zeros(n_cls, fv_full_length);
ClassXdvgFull(:, FV_Xidx) = ClassXdvg;
ClassXdvgFull(ClassDivgFull < 0) = -ClassXdvgFull(ClassDivgFull < 0); 
max_imp = max(max(ClassXdvgFull)) * 1.05;
min_imp = min(min(ClassXdvgFull)) * 1.05;

if n_most > 0
    rnkfname = strcat('FrmFeatVec_NewRank_', rnk_str, '_Final.csv');
    disp(['*** Reading Features Rank from file: ', rnkfname, ' ****']);
    AllRank = csvread(rnkfname);
    [nr_rnk, nc_rnk] = size(AllRank);
    if nr_rnk ~= n_cls || nc_rnk ~= fv_length
        error('!!!Error: Rank does not match with X divergence file!');
    end
    FullRank = zeros(n_cls, fv_full_length);
    FullRank(:, FV_Xidx) = AllRank;
end

disp(['=== Begin - Building Charts for all classes - ', datestr(now), ' ===']);

n_ltx = 4;
TexMtr = zeros(n_cls, n_ltx);

for cls = 1:n_cls
    
    disp(['--- Build Charts and Display Statistics of ', num2str(n_most), ...
        ' most important features of class ', num2str(Classes(cls)), ...
        ' - ', datestr(now), ' ---']);
    
    sumdvg = sum(abs(ClassDivgFull(cls, :)));
    if sumdvg == 0
        error('!!!Error: Sum of absolut X divergences equals zero!');
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
    disp(['cls=', num2str(Classes(cls)), ' ', ...
        'npos=', num2str(n_pos), ' ', ...
        'nzer=', num2str(n_zer), ' ', ...
        'nneg=', num2str(n_neg), ' ', ...
        ]);
    
    X_values = 0:(fv_full_length-1);
    fig1 = figure;
    p = bar(X_values, ClassXdvgFull(cls, :), 0.5);
    ax = gca;
    ax.YLim = [min_imp max_imp];
    ax.XLim = [-100 2400];
    ax.XTick = 0:200:2200;
    ax.TickDir = 'out';
    ax.FontSize = 14;
    hold on
    if n_most > 0
        Rank = FullRank(cls, :);
        SelMost = Rank > 0 & Rank <= n_most;
        X_Most = X_values(SelMost);
        Y_Most = ClassXdvgFull(cls, SelMost);
        plot(X_Most, Y_Most, '.r');
        lgd1 = legend('  feature frequency at maximum CDFs difference', ...
            ['  ', num2str(n_most), ' most discriminant ', feat_str, ' features'], ...
            'Location', 'south');
    else
        lgd1 = legend('  feature frequency at maximum CDFs difference', ...
            'Location', 'southwest');
    end
    xlabel(['Feature (', num2str(X_values(1)), ':', num2str(X_values(end)), ')']);
    ylabel('Feature frequency on frames');
    title(['Class ', num2str(Classes(cls)), ' - Features Frequency at max CDFs difference'])
    lgd1.FontSize = 12;
    fig1.Units = 'centimeters';
    fig1.Position = [0.5, 0.5, 25, 15];
    fig1.PaperType = 'a4';
    fig1.PaperOrientation = 'landscape';
    hold off
    
    figfname = strcat('FeaturesXdvgChart_C', num2str(Classes(cls)), ...
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
