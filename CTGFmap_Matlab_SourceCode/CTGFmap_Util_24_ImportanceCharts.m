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

diaryfile = strcat('impcharts', rnk_str, '_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Importance Charts +++');

idsfname = strcat('ImgClassIds.csv');
disp(['*** Reading Classes from file: ', idsfname, ' ***']);
ImgClsIds = csvread(idsfname);
Classes = sort(unique(ImgClsIds));
n_cls = numel(Classes);

rnkfname = strcat('FrmFeatVec_NewRank_', rnk_str, '_Final.csv');
disp(['*** Reading Features Rank from file: ', rnkfname, ' ****']);
AllRank = csvread(rnkfname);
[nr_rnk, fv_length] = size(AllRank);

impfname = strcat('FrmFeatVec_Imp_AllRndFor.csv');
disp(['*** Reading Random Forest Feature Importance from file: ', impfname, ' ****']);
AllImp = csvread(impfname);
[nr_imp, nc_imp] = size(AllImp);
if (nr_rnk ~= n_cls) || (nr_imp ~= n_cls) || (nc_imp ~= fv_length)
    error('!!! Error: Importance and Features Rank does not match!');
end

disp(['=== Begin - Building Charts for all classes - ', datestr(now), ' ===']);

n_ltx = 5;
TexMtr = zeros(n_cls, n_ltx);

for cls = 1:n_cls
    
    disp(['--- Build Charts and Display Statistics of ', num2str(n_most), ...
        ' most important features of class', num2str(Classes(cls)), ...
        ' - ', datestr(now), ' ---']);
    
    dvgfname = strcat('FrmFeatVec_DivgMetrics_C', ...
        num2str(Classes(cls)), '.csv');
    DivgMetrics = csvread(dvgfname);
    disp(['*** Class Divergence Metrics read from file: ', dvgfname, ' ****']);
    
    sumdvg = sum(abs(DivgMetrics(DVG_DIVG, :)));
    if sumdvg == 0
        error('!!!Error: Sum of absolut divergences equals zero!');
    end
    ClassDivg = DivgMetrics(DVG_DIVG, :) / sumdvg;
    ClassImp = AllImp(cls, :);
    if round(sum(ClassImp), 10) ~= 1.0
        error('!!!Error: Sum of Importances different from 1!');
    end
    TexMtr(cls, 1) = Classes(cls);
    SelPos = ClassDivg > 0;
    SelZer = ClassDivg == 0;
    SelNeg = ClassDivg < 0;
    n_pos = sum(SelPos);
    TexMtr(cls, 2) = n_pos;
    n_zer = sum(SelZer);
    TexMtr(cls, 3) = n_zer;
    n_neg = sum(SelNeg);
    TexMtr(cls, 4) = n_neg;
    sumabs = sum(abs(ClassImp));
    sumpos = sum(ClassImp(SelPos));
    TexMtr(cls, 5) = sumpos;
    sumneg = sum(ClassImp(SelNeg));
    disp(['cls=', num2str(cls), ' ', ...
        'npos=', num2str(n_pos), ' ', ...
        'nzer=', num2str(n_zer), ' ', ...
        'nneg=', num2str(n_neg), ' ', ...
        'sumabs=', num2str(sumabs), ' ', ...
        'sumpos=', num2str(round(sumpos, 2)), ' ', ...
        'sumneg=', num2str(round(sumneg, 2)), ' ', ...
        ]);
    
    SignImp = ClassImp;
    SignImp(SelNeg) = -SignImp(SelNeg);
    X_values = 0:(fv_length-1);
    max_imp = max(ClassImp);
    Rank = AllRank(cls, :);
    SelMost = Rank > 0 & Rank <= n_most;
    X_Most = X_values(SelMost);
    Y_Most = SignImp(SelMost);
    fig1 = figure;
    p = bar(X_values, SignImp, 0.5);
    ax = gca;
    ax.YLim = [-max_imp max_imp];
    ax.XLim = [-100 2400];
    ax.XTick = 0:200:2200;
    ax.FontSize = 14;
    hold on
    plot(X_Most, Y_Most, '.r');
    lgd1 = legend('  full vector random forest importance', ...
        ['  ', num2str(n_most), ' most discriminant ', feat_str, ' features' ], ...
        'Location', 'south');
    xlabel(['Feature (', num2str(X_values(1)), ':', num2str(X_values(end)), ')']);
    ylabel('Importance');
    title(['Class ', num2str(Classes(cls)), ...
        ' - Full Vector Random Forest Features Importance'])
    lgd1.FontSize = 12;
    fig1.Units = 'centimeters';
    fig1.Position = [0.5, 0.5, 25, 15];
    fig1.PaperType = 'a4';
    fig1.PaperOrientation = 'landscape';
    hold off
    figfname = strcat('FeaturesRndForImpChart_C', ...
        num2str(Classes(cls)), '_A4_300dpi');
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
