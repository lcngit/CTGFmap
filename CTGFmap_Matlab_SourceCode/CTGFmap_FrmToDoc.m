%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.2r0/2017.09.16
%_application: CTGF Features mapping

function [DocAttribClasses, DocMetrics] = CTGFmap_FrmToDoc(FrmAttribClasses, ...
         Classes, exp_num, tstid, mtd, FV_Length)

CTGFmap_IncludeConstants;

n_cls = numel(Classes);
DocIds = unique(FrmAttribClasses(:, C_ATTRIBFRM_DOCID));
ndocs = numel(DocIds);
DocAttribClasses = zeros(ndocs, C_ATTRIBDOC_LENGTH + n_cls);
DocMetrics = zeros(C_HDRMTR_LENGTH + METRIC_LENGTH, n_cls);
for idoc = 1:ndocs
    doc = DocIds(idoc);
    FrmDoc = FrmAttribClasses;
    FrmDoc(FrmAttribClasses(:, C_ATTRIBFRM_DOCID) ~= doc, :) = [];
    [nfrms, ~] = size(FrmDoc);
    FrmClasses = zeros(1, n_cls);
    for icls = 1:n_cls
       FrmClasses(icls) = sum(FrmDoc(:, C_ATTRIBFRM_LENGTH + icls) ~=0);
    end
    cls_actual = FrmDoc(1, C_HDRMTR_CLASS);
    [nfmax, cls_pred_idx] = max(FrmClasses);
    if nfmax == 0
        cls_pred_idx = 0;
    end
    if cls_pred_idx ~= 0
        cls_pred = Classes(cls_pred_idx);
        fvlen = FV_Length(cls_pred_idx);
    else
        cls_pred = 0;
        fvlen = 0;
    end
        
    DocAttribClasses(idoc, C_HDRMTR_CLASS)        = cls_actual;
    DocAttribClasses(idoc, C_HDRMTR_EXPNUM)       = exp_num;
    DocAttribClasses(idoc, C_HDRMTR_TSTID)        = tstid;
    DocAttribClasses(idoc, C_HDRMTR_METHOD)       = mtd;
    DocAttribClasses(idoc, C_HDRMTR_FVLENGTH)     = fvlen;
    DocAttribClasses(idoc, C_ATTRIBDOC_DOCID)     = doc;
    DocAttribClasses(idoc, C_ATTRIBDOC_NFRMS)     = nfrms;
    DocAttribClasses(idoc, C_ATTRIBDOC_PREDICTED) = cls_pred;
    DocAttribClasses(idoc, C_ATTRIBDOC_FRMPROB)   = nfmax / nfrms;
    DocAttribClasses(idoc, C_ATTRIBDOC_CLASSOK)   = cls_actual == cls_pred;
    DocAttribClasses(idoc, C_ATTRIBDOC_CLASSFRMS:end) = FrmClasses;
end

for cls = 1:n_cls
    cls_id = Classes(cls);
    trueneg = sum(and(DocAttribClasses(:, C_HDRMTR_CLASS) ~= cls_id, ...
                      DocAttribClasses(:, C_ATTRIBDOC_PREDICTED) ~= cls_id));
    truepos = sum(and(DocAttribClasses(:, C_HDRMTR_CLASS) == cls_id, ...
                      DocAttribClasses(:, C_ATTRIBDOC_PREDICTED) == cls_id));
    falseneg = sum(and(DocAttribClasses(:, C_HDRMTR_CLASS) == cls_id, ...
                      DocAttribClasses(:, C_ATTRIBDOC_PREDICTED) ~= cls_id));
    falsepos = sum(and(DocAttribClasses(:, C_HDRMTR_CLASS) ~= cls_id, ...
                      DocAttribClasses(:, C_ATTRIBDOC_PREDICTED) == cls_id));
    alldoc = trueneg + truepos + falseneg + falsepos;
    if alldoc ~= ndocs
        error(['!!!Error: total confmat different from ndocs! classe = ', ...
              num2str(cls_id)]);
    end
    ConfMtx = zeros(2,2);
    ConfMtx(end, end) = truepos;
    ConfMtx(end, 1)   = falseneg;
    ConfMtx(1, 1)     = trueneg;
    ConfMtx(1, end)   = falsepos;
    Metrics = CTGFmap_CalcMetrics(ConfMtx);
    id_metrics = strcat('Class: ', num2str(cls_id), ...
        ', Experiment: ', num2str(exp_num), ...
        ', Type: ', num2str(tstid),...
        ', Method: ', num2str(mtd)); 
    CTGFmap_DispMetrics (id_metrics, Metrics);
    HdrMtr = [cls_id; exp_num; tstid; mtd; FV_Length(cls)];
    DocMetrics(:, cls) = vertcat(HdrMtr, Metrics');

end

end
