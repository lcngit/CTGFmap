%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.3r0/2017.09.16
%_application: CTGF Features mapping

clear
clc

CTGFmap_IncludeConstants;

tsttype = input('Select Test type (2 = Validation, 3 = Final Test): ');
selmtd = input('Select Method (0 = SVM, 1 = RndFor): ');
if selmtd == 0
    mtd = METHOD_SVM_SMO;
else
    mtd = METHOD_TREE_ENSAMBLE;
end
rnk_type = RNK_NO;
seq = 0;
dsz = -1;
while dsz < 0 || dsz > 90
    dsz = input('Dataset size reduction of [0(no reduction) to 90]% : ');
end
dsz = round(dsz, 0);

[rnk_str, ~] = CTGFmap_Rank_Type(rnk_type);
tstseq = strcat('_T',num2str(tsttype),'_S', num2str(seq));
if dsz > 0
    tstseq = strcat('_Z', num2str(dsz), tstseq);
end
rnk_str = strcat(rnk_str,tstseq);

diaryfile = strcat('full_len_mtd_', num2str(mtd), '_dsz', ...
    num2str(dsz),'_metrics_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Final Metrics Consolidation +++')
if dsz > 0
    disp(['+++ With dataset size reduction of ', num2str(dsz),'% +++']);
end

% get Document Metrics from current directory
wdfname = strcat('DocAttribMetrics_R', num2str(rnk_type), ...
    '_M', num2str(mtd),'_E*',tstseq,'.csv');
docmtrfiles = dir(wdfname);
n_docmtr = numel(docmtrfiles);
DocMetrics = zeros(1, C_HDRMTR_LENGTH + METRIC_LENGTH);
nd_p = 0;

for f = 1:n_docmtr
    
    % get file name and parameters
    mtrdocfname = docmtrfiles(f).name;
    disp(['*** Processing documents metrics from file: ', mtrdocfname]);
    j = strfind(mtrdocfname, '_E') - 1;
    k = strfind(mtrdocfname, '_T') - 1;
    if dsz > 0
        z = strfind(mtrdocfname, '_Z') - 1;
    else
        z = k;
    end
    i = strfind(mtrdocfname, '_S') - 1;
    exp_num = str2double(mtrdocfname((j+3):z));
    tst_type = str2double(mtrdocfname((k+3):i));
    if isnan(exp_num) || isnan(tst_type)
        continue;
    end
    disp(['    Documents attribution metrics ', ...
        '- Experiment number: ', num2str(exp_num), ...
        ', teste type = ', num2str(tst_type), ...
        ', method = ', num2str(mtd), ...
        ', rnk_type = ', num2str(rnk_type)]);
    
    % read metrics file
    disp(['    Reading file: ', mtrdocfname]);
    Metrics = csvread(mtrdocfname);
    [nrdm, ncdm] = size(Metrics);
    if (nrdm ~= (C_HDRMTR_LENGTH + METRIC_LENGTH))
        error('!!!Error: Invalid document metrics file!');
    end
    AuxMetrics = vertcat(DocMetrics, Metrics');
    DocMetrics = unique(AuxMetrics,'rows');
    
end

DocMetrics(1, :) = [];
Classes = sort(unique(DocMetrics(:, C_HDRMTR_CLASS)));
n_cls = numel(Classes);

if ~isempty(DocMetrics)
    docmfname = strcat('ClassDocDetMetrics_M', num2str(mtd), '_', ...
        rnk_str, '.csv');
    dlmwrite(docmfname, DocMetrics, 'delimiter', ',', 'precision', 12);
    disp(['*** Documents attribution metrics method M', num2str(mtd), ...
        ' ', rnk_str, ' rank saved into file: ', docmfname, ' ****']);
    
    ClassFVLengths = zeros(n_cls, 1);
    FinalStats = zeros(n_cls, METRIC_LENGTH);
    for cls = 1:n_cls
        cls_id = Classes(cls);
        SelCls = DocMetrics(:, C_HDRMTR_CLASS) == cls_id;
        ClassFVLengths(cls) = unique(DocMetrics(SelCls, C_HDRMTR_FVLENGTH));
        ConfMtx = zeros(2,2);
        stt =  C_HDRMTR_LENGTH + j;
        ConfMtx(end, end) = sum(DocMetrics(SelCls, ...
            C_HDRMTR_LENGTH + METRIC_TRUEPOS));
        ConfMtx(end, 1) = sum(DocMetrics(SelCls, ...
            C_HDRMTR_LENGTH + METRIC_FALSENEG));
        ConfMtx(1, 1) = sum(DocMetrics(SelCls, ...
            C_HDRMTR_LENGTH + METRIC_TRUENEG));
        ConfMtx(1, end) = sum(DocMetrics(SelCls, ...
            C_HDRMTR_LENGTH + METRIC_FALSEPOS));
        FMetrics = CTGFmap_CalcMetrics (ConfMtx);
        CTGFmap_DispMetrics (strcat('Class: ', num2str(cls_id)), FMetrics);
        FinalStats(cls, :) = FMetrics;
    end
    
    finfname = strcat('FinalFullLengthMetrics_M', num2str(mtd), ...
        '_', rnk_str);
    save(finfname, 'FinalStats');
    disp(['*** Final ', rnk_str, ...
        ' Full Length Classifiers metrics method M', num2str(mtd), ...
        ' saved into file: ', finfname, ' ****']);
    
    CTGFmap_DispStatsLatex(Classes, FinalStats, ClassFVLengths)
    
end
disp(' ');

endtime = datetime('now');
disp(['+++ End - Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
