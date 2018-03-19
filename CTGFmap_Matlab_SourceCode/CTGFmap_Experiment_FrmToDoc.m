%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.2r0/2017.09.16
%_application: CTGF Features mapping

function DocMetrics = CTGFmap_Experiment_FrmToDoc(Classes, exp_num, ...
    exp_type, mtd, rnk_type, dsz, FV_lengths, seq)

CTGFmap_IncludeConstants;

disp(['*** Begin - Frame to Document Attribution Experiment ', ...
    num2str(exp_num), ' Consolidation - ', ...
    datestr(datetime('now')), ' ***']);
n_cls = numel(Classes);
n_k = numel(FV_lengths);
if n_k ~= n_cls
    error('!!!Error: Invalid K_lengths!');
end

for cls = 1:n_cls
    cls_id = Classes(cls);
    frmsuffix = strcat('_C', num2str(cls_id), ...
        '_R', num2str(rnk_type),...
        '_L', num2str(FV_lengths(cls)), ...
        '_M', num2str(mtd), ...
        '_E', num2str(exp_num));
    if dsz > 0
        frmsuffix = strcat(frmsuffix,'_Z', num2str(dsz));
    end
    frmsuffix = strcat(frmsuffix, '_T', num2str(exp_type));
    frmfname = strcat('FrmAttrib', frmsuffix, '.csv');
    disp(['    Reading classes attribute to frames from file: ', frmfname]);
    FrmAttrib = csvread(frmfname);
    if FrmAttrib(1, C_HDRMTR_FVLENGTH) ~= FV_lengths(cls)
        error('!!!Error: Invalid frame length in Frame Attribution file!');
    end
    FrmAttrib(:, C_HDRMTR_FVLENGTH) = 0;
    if cls == 1
        FrmAttribClasses = FrmAttrib;
    else
        if ~isequal(FrmAttribClasses(:, 1:C_ATTRIBFRM_FRMID), ...
                FrmAttrib(:, 1:C_ATTRIBFRM_FRMID))
            error('!!!Error: Frame attribute classes header are different!')
        end
        FrmAttribClasses = horzcat(FrmAttribClasses, ...
            FrmAttrib(:, C_ATTRIBFRM_PREDICTED)); %#ok<AGROW>
    end
end

[DocAttribClasses, DocMetrics] = CTGFmap_FrmToDoc(FrmAttribClasses, ...
    Classes, exp_num, exp_type, mtd, FV_lengths);

docaccuracy = mean(DocMetrics(C_HDRMTR_LENGTH + METRIC_ACCURACY, :));
docf1score = mean(DocMetrics(C_HDRMTR_LENGTH + METRIC_F1SCORE, :));

fsuffix = strcat('_R', num2str(rnk_type),...
    '_M', num2str(mtd), ...
    '_E', num2str(exp_num));
if dsz > 0
    fsuffix = strcat(fsuffix,'_Z', num2str(dsz));
end
fsuffix = strcat(fsuffix, '_T', num2str(exp_type), ...
    '_S', num2str(seq));

% Save document attribution process data for logging purpose and next steps.
outfname = strcat('DocAttribClasses', fsuffix, '.csv');
dlmwrite(outfname, DocAttribClasses, 'delimiter', ',', 'precision', 12);
disp(['*** Classes Attributed to Documents saved into file: ', outfname, ' ****']);
outfname = strcat('DocAttribMetrics', fsuffix, '.csv');
dlmwrite(outfname, DocMetrics, 'delimiter', ',', 'precision', 12);
disp(['*** Documents Attribution Metrics saved into file: ', outfname, ' ****']);
disp(' ');
disp(['*** Begin - Frame to Document Attribution Experiment ', ...
    num2str(exp_num), ' Consolidation - ', ...
    datestr(datetime('now')), ' ***']);
disp(['    Class Attribution to Documents - All classes average', ...
    ' - Accuracy = ', num2str(docaccuracy * 100), '%', ...
    ' - F1score = ', num2str(docf1score * 100), '%', ...
    ' ***']);
disp(' ');

end
