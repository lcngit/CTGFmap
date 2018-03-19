%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.0r1/2017.05.03
%_application: CTGF Features mapping

clear
clc

CTGFmap_IncludeConstants;
mtd      = METHOD_TREE_ENSAMBLE;
n_exp    = C_NUM_OF_EXP - 1;
tst_type = C_EXP_VALIDATION;

rnk_input = input('Rank type (0 to 7): ');
[rnk_str, ~] = CTGFmap_Rank_Type(rnk_input);
rnk_type = rnk_input;
max_seq = input('Maximum Sequence number: ');
rnk_str = strcat(rnk_str, '_T', num2str(tst_type));

diaryfile = strcat('metrics', rnk_str, '_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Metrics Consolidation +++')

mtrdocfname = strcat('DocAttribMetrics_R', num2str(rnk_type), ...
    '_M', num2str(mtd), '_E1_T', num2str(tst_type), '_S1.csv');
disp(['*** Load classes from file: ', mtrdocfname]);
CMetrics = csvread(mtrdocfname);
Classes = sort(unique(CMetrics(C_HDRMTR_CLASS, :)));
n_cls = numel(Classes);

AllMetrics = zeros(n_cls, n_exp, max_seq, C_HDRMTR_LENGTH + METRIC_LENGTH);
for exp_num = 1:n_exp
    for seq = 1:max_seq
        disp(['    Documents attribution metrics ', ...
            '- Experiment number: ', num2str(exp_num), ...
            ', teste type = ', num2str(tst_type), ...
            ', method = ', num2str(mtd), ...
            ', rnk_type = ', num2str(rnk_type)]);
        mtrdocfname = strcat('DocAttribMetrics_R', num2str(rnk_type), ...
            '_M', num2str(mtd), ...
            '_E', num2str(exp_num), ...
            '_T', num2str(tst_type), ...
            '_S', num2str(seq), ...
            '.csv');
        disp(['*** Processing documents metrics from file: ', mtrdocfname]);
        disp(['    Reading file: ', mtrdocfname]);
        Metrics = csvread(mtrdocfname);
        [nrdm, ncdm] = size(Metrics);
        if (nrdm ~= (C_HDRMTR_LENGTH + METRIC_LENGTH)) || ...
                (ncdm ~= n_cls)
            error('!!!Error: Invalid document metrics file!');
        end
        for cls = 1: n_cls
            AllMetrics(cls, exp_num, seq, :) = Metrics(:, cls)';
        end
    end
end


ClsLength = zeros(n_cls, max_seq);
N_ClsLengths = zeros(n_cls, 1);
for cls = 1:n_cls
    SeqLengths = AllMetrics(cls, :, :, C_HDRMTR_FVLENGTH);
    AuxLengths = unique(SeqLengths(:));
    n_len = numel(AuxLengths);
    N_ClsLengths(cls) = n_len;
    ClsLength(cls, 1:n_len) = AuxLengths;
end

n_mtr = sum(N_ClsLengths) * n_exp;
if n_mtr > 0
    
    i_mtr = 0;
    DocMetrics = zeros(n_mtr, C_HDRMTR_LENGTH + METRIC_LENGTH);
    for cls = 1: n_cls
        for exp_num = 1:n_exp
            for i_len = 1:N_ClsLengths(cls)
                
                i_mtr = i_mtr + 1;
                fv_len = ClsLength(cls, i_len);
                disp (['*** Consolidated Metrics of Class: ', num2str(Classes(cls)), ...
                    ', Experiment: ', num2str(exp_num), ...
                    ', length: ', num2str(fv_len), ' ***']);
                AuxSeqs = AllMetrics(cls, exp_num, :, C_HDRMTR_FVLENGTH);
                seq = find(AuxSeqs(:) == fv_len, 1, 'first');
                
                DocMetrics(i_mtr, :) = AllMetrics(cls, exp_num, seq, :);
                dsname = strcat('_R', num2str(rnk_type), ...
                    '_M', num2str(mtd), ...
                    '_E', num2str(exp_num), ...
                    '_T', num2str(tst_type), ...
                    '_C', num2str(Classes(cls)), ...
                    '_L', num2str(fv_len));
                CTGFmap_DispMetrics (dsname, DocMetrics(i_mtr, (C_HDRMTR_LENGTH+1):end));
            
            end
        end
    end
    
    docmfname = strcat('DocAttribMetrics_', rnk_str, '.csv');
    dlmwrite(docmfname, DocMetrics, 'delimiter', ',', 'precision', 12);
    disp(['*** Documents attribution metrics ', rnk_str, ...
        ' rank saved into file: ', docmfname, ' ****']);
end

endtime = datetime('now');
disp(['+++ End - Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
