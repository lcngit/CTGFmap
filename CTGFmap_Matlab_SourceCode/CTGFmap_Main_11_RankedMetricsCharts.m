%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0//2017.08.07
%_application: CTGF Features mapping

clear
clc

CTGFmap_IncludeConstants;

tst_type = input('Test type (2 = validation, 3 = final test): ');
rnk_input = input('Rank type (0 to 7): ');
[rnk_str, feat_type] = CTGFmap_Rank_Type(rnk_input);
rnk_type = rnk_input;
rnk_str_t = strcat(rnk_str, '_T', num2str(tst_type));

diaryfile = strcat('metricschart', rnk_str_t, '_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Metrics Charts +++')
disp('');

disp(['--- Getting document attribution metrics ', rnk_str_t, ' ranked - ', datestr(now), ' ---'])
dmtrfname = strcat('DocAttribMetrics_', rnk_str_t, '.csv');
disp(['*** Reading Documents Attribution Metrics from file: ', dmtrfname, ' ****']);
DocMetrics = csvread(dmtrfname);
Classes = sort(unique(DocMetrics(:, C_HDRMTR_CLASS)));
n_cls = numel(Classes);

lmfname = strcat('FrmFeatVec_Length_', rnk_str,'.csv');
disp(['*** Reading Lengtht ', rnk_str, ' metrics from file: ', lmfname, ' ****']);
LengthMetrics = csvread(lmfname);
[nr_lm, ~] = size(LengthMetrics);

if nr_lm ~= n_cls
    error('!!!!! Error: Incompatible metrics and feature vectors length!')
end

max_rnks = numel(unique(DocMetrics(:, C_HDRMTR_FVLENGTH)));
RankLength = zeros(n_cls, max_rnks);
NumRanks = zeros(n_cls,1);
MaxLength = zeros(n_cls,1);
for cls = 1:n_cls
    Ranks_cls = sort(unique(DocMetrics(DocMetrics(:, C_HDRMTR_CLASS) == ...
        Classes(cls), C_HDRMTR_FVLENGTH)));
    nranks_cls = numel(Ranks_cls);
    RankLength(cls, 1:nranks_cls) = Ranks_cls;
    NumRanks(cls) = nranks_cls;
    MaxLength(cls) = max(Ranks_cls);    
end

fv_length = max(MaxLength);

Metrics = zeros(n_cls, max_rnks, METRIC_LENGTH);
for cls = 1:n_cls
    n_rnksz = NumRanks(cls);
    for j = 1:n_rnksz
        rnksz = RankLength(cls, j);
        SelMtr = and(DocMetrics(:, C_HDRMTR_CLASS) == Classes(cls), ...
                     DocMetrics(:, C_HDRMTR_FVLENGTH) == rnksz);
        AuxMTR = DocMetrics(SelMtr, (C_HDRMTR_LENGTH + 1): end);
        [n_aux, ~] = size(AuxMTR);
        if n_aux == 1
            MeanMTR = AuxMTR;
        else
            MeanMTR = mean(AuxMTR);
        end
        Metrics(cls, j, :) = MeanMTR;
    end
end

disp(['--- Printing charts of most important ', feat_type, ' features  - ', datestr(now), ' ---'])

SummaryMetrics = zeros(cls, C_FEAT_LENGTH_LENGTH);
for cls = 1:n_cls
    disp(['*** Metrics chart of class ', num2str(Classes(cls)), ...
          ' - most important ', feat_type, ' features ***']); 
    disp(['    Number of most important ', feat_type, ...
          ' features for class: ', num2str(MaxLength(cls))]);
    disp(['    Number of ranked ', feat_type, ...
          ' features evaluated: ', num2str(NumRanks(cls))]);
    n_rnksz = NumRanks(cls);  
    max_fv_length = MaxLength(cls);
    disp(['    Maximum of vector length of most important ', feat_type, ...
          ' features evaluated: ', num2str(max_fv_length)]);
    Xaxis   = RankLength(cls, 1: n_rnksz);
    Yacc    = zeros(n_rnksz, 1);
    Yacc(:) = Metrics(cls, 1:n_rnksz, METRIC_ACCURACY) * 100;
    Yrcl    = zeros(n_rnksz, 1);
    Yrcl(:) = Metrics(cls, 1:n_rnksz, METRIC_RECALL) * 100;
    Yspc    = zeros(n_rnksz, 1);
    Yspc(:) = Metrics(cls, 1:n_rnksz, METRIC_SPECIFICITY) * 100;
    Yprc    = zeros(n_rnksz, 1);
    Yprc(:) = Metrics(cls, 1:n_rnksz, METRIC_PRECISION) * 100;
    Yf1s    = zeros(n_rnksz, 1);
    Yf1s(:) = Metrics(cls, 1:n_rnksz, METRIC_F1SCORE) * 100;
    
    x_min = LengthMetrics(cls, C_LEN_MTR_MINLEN);
    x_bst = LengthMetrics(cls, C_LEN_MTR_BESTLEN);
    i_min = find(Xaxis == x_min, 1, 'first');
    i_bst = find(Xaxis == x_bst, 1, 'first');
    if isnan(x_min) || isnan(x_bst)
        error('!!!Error: Invalid Xmin or Xbest!');
    end
       
    min_acc_y = Yacc(i_min);
    min_rcl_y = Yrcl(i_min);
    min_spc_y = Yspc(i_min);
    min_prc_y = Yprc(i_min);
    min_f1s_y = Yf1s(i_min);
    bst_acc_y = Yacc(i_bst);
    bst_rcl_y = Yrcl(i_bst);
    bst_spc_y = Yspc(i_bst);
    bst_prc_y = Yprc(i_bst);
    bst_f1s_y = Yf1s(i_bst);
    max_acc_y = Yacc(n_rnksz);
    max_rcl_y = Yrcl(n_rnksz);
    max_spc_y = Yspc(n_rnksz);
    max_prc_y = Yprc(n_rnksz);
    max_f1s_y = Yf1s(n_rnksz);
    
    disp(['    Minimum results length: ', num2str(x_min), ...
          ', f1score: ',   num2str(min_f1s_y), '%', ...
          ', recall: ',    num2str(min_rcl_y), '%', ...
          ', specificity: ', num2str(min_spc_y), '%', ...
          ', precision: ', num2str(min_prc_y), '%', ...
           ', accuracy: ', num2str(min_acc_y), '%']);
    disp(['    Best results length: ', num2str(x_bst), ...
          ', f1score: ',   num2str(bst_f1s_y), '%', ...
          ', recall: ',    num2str(bst_rcl_y), '%', ...
          ', specificity: ', num2str(bst_spc_y), '%', ...
          ', precision: ', num2str(bst_prc_y), '%', ...
           ', accuracy: ', num2str(bst_acc_y), '%']);
    disp(['    Maximum length results: ', num2str(max_fv_length), ...
          ', f1score: ',   num2str(max_f1s_y), '%', ...
          ', recall: ',    num2str(max_rcl_y), '%', ...
          ', specificity: ', num2str(max_spc_y), '%', ...
          ', precision: ', num2str(max_prc_y), '%', ...
           ', accuracy: ', num2str(max_acc_y), '%']);
    disp(['    Showing and writing file with chart for class: ', ...
        num2str(Classes(cls))]);
    disp(['Latex table lines ', feat_type(1:3), ':']);
    disp('			\hline');
    disp(['			\textbf{', num2str(Classes(cls)), ...
          '} & \textbf{min} & \textbf{', num2str(x_min), ...
          '} & ', num2str(round(min_acc_y,2)), ...
          ' & ', num2str(round(min_rcl_y,2)), ...
          ' & ', num2str(round(min_spc_y,2)), ...
          ' & ', num2str(round(min_prc_y,2)), ...
          ' & ', num2str(round(min_f1s_y,2)), ' \\']);
    disp(['			', num2str(Classes(cls)), ...
          ' & best & ', num2str(x_bst), ...
          ' & ', num2str(round(bst_acc_y,2)), ...
          ' & ', num2str(round(bst_rcl_y,2)), ...
          ' & ', num2str(round(bst_spc_y,2)), ...
          ' & ', num2str(round(bst_prc_y,2)), ...
          ' & ', num2str(round(bst_f1s_y,2)), ' \\']);
    disp(['			', num2str(Classes(cls)), ...
          ' & max & ', num2str(max_fv_length), ...
          ' & ', num2str(round(max_acc_y,2)), ...
          ' & ', num2str(round(max_rcl_y,2)), ...
          ' & ', num2str(round(max_spc_y,2)), ...
          ' & ', num2str(round(max_prc_y,2)), ...
          ' & ', num2str(round(max_f1s_y,2)), ' \\']);

    disp(['    Showing and writing file with chart for class: ', num2str(Classes(cls))]);
    fig = figure;
    vf1s = semilogx(Xaxis, Yf1s,'-*b');
    vf1s(1).LineWidth = 1;
    hold on
    semilogx(Xaxis, Yacc,'-+k');
    semilogx(Xaxis, Yrcl,'--c');
    semilogx(Xaxis, Yprc,'-.m');
    vmax = semilogx([x_bst, x_bst], [0, 100],'-g');
    vmax(1).LineWidth = 1.5;
    vmin = semilogx([x_min, x_min], [0, 100],':r');
    vmin(1).LineWidth = 1;
    title(['Class ', num2str(Classes(cls)), ' - ', upper(feat_type(1))...
           , feat_type(2:end),' features (', num2str(MaxLength(cls)),')'])
    xlabel(['most important ', feat_type, ' features length'])
    ylabel('metric value (%) on doc attribution')
    xlim([1 fv_length])
    ylim([50 100])
    legend('f1score', 'accuracy',  'recall',  'precision', ...
           'best length', 'min length', 'Location', 'southeast');
    hold off
    figfname = strcat('DocMetricsClass_', num2str(Classes(cls)), ...
        '_', rnk_str_t);
    print(figfname,'-dpdf', '-r300');
    close all
    
    SummaryMetrics(cls, :) = horzcat(Classes(cls), MaxLength(cls), ...
        max_fv_length, x_min, x_bst);
    
end

SummaryHdr = horzcat(n_cls, fv_length, 0, 0, 0);
SummaryMetrics = vertcat(SummaryHdr, SummaryMetrics);                
docmfname = strcat('DocSummaryMetrics_', rnk_str_t, '.csv');
dlmwrite(docmfname, SummaryMetrics, 'delimiter', ',', 'precision', 12);
disp(['*** Documents attribution summary ', rnk_str_t, ...
      ' feature metrics saved into file: ', docmfname, ' ***']);

endtime = datetime('now');
disp(['+++ End - Processing - ', datestr(initime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
