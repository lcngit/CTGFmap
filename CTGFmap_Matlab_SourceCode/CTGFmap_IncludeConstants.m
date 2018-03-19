%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.4r0/2017.09.16
%_application: CTGF Features mapping

% Minimum texture frequency to be considered a feature (100 ppm) for 1% of
% samples
MIN_TEXTURE_FREQ = 0.0001;
MIN_TEXTURE_PERC = 0.01;

% Frame types for classification
FRM_TYPE_TXT = 1;                   % only text
FRM_TYPE_FIG = FRM_TYPE_TXT + 1;    % only figures
FRM_TYPE_ALL = FRM_TYPE_FIG + 1;    % all frames

% Contant values, all constant value names begin as "C_" following by CAPS
% Frame Metrics Header
C_CLASS_ID      = 1;
C_DOC_LANG      = C_CLASS_ID     + 1;
C_DOC_PICT      = C_DOC_LANG     + 1;
C_DOC_NUM       = C_DOC_PICT     + 1;
C_DOC_ID        = C_DOC_NUM      + 1;
C_DOC_GROUP     = C_DOC_ID       + 1;
C_FRM_NUM       = C_DOC_GROUP    + 1;
C_GLOW          = C_FRM_NUM      + 1;
C_GHIGH         = C_GLOW         + 1;
C_BORDER_UP     = C_GHIGH        + 1;
C_BORDER_LEFT   = C_BORDER_UP    + 1;
C_FRM_IROW      = C_BORDER_LEFT  + 1;
C_FRM_FROW      = C_FRM_IROW     + 1;
C_FRM_ICOL      = C_FRM_FROW     + 1;
C_FRM_FCOL      = C_FRM_ICOL     + 1;
C_I_NR          = C_FRM_FCOL     + 1;
C_I_NC          = C_I_NR         + 1;
C_I_NBLACK      = C_I_NC         + 1;
C_I_NWHITE      = C_I_NBLACK     + 1;
C_I_NNEARBLACK  = C_I_NWHITE     + 1;
C_I_NNEARWHITE  = C_I_NNEARBLACK + 1;
C_I_NDARKGRAY   = C_I_NNEARWHITE + 1;
C_I_NLIGHTGRAY  = C_I_NDARKGRAY  + 1;
C_I_NDARK       = C_I_NLIGHTGRAY + 1;
C_I_NLIGHT      = C_I_NDARK      + 1;
C_H_PIX         = C_I_NLIGHT     + 1;
C_H_GRAD        = C_H_PIX        + 1;
C_H_CONV        = C_H_GRAD       + 1;
C_H_FILTGRAD    = C_H_CONV       + 1;
C_H_FILTCONV    = C_H_FILTGRAD   + 1;
C_METRICS       = C_H_FILTCONV;

% Common Constants
C_NPIX_VAL      = 256;              % Constant value number of pixel values;
C_WHITE         = C_NPIX_VAL - 1;   % Constant value for white color in negative image;

% Image File Ids
C_IMGID_CLASS_ID  = 1;
C_IMGID_DOC_LANG  = C_IMGID_CLASS_ID  + 1;
C_IMGID_DOC_PICT  = C_IMGID_DOC_LANG  + 1;
C_IMGID_DOC_NUM   = C_IMGID_DOC_PICT  + 1;
C_IMGID_DOC_ID    = C_IMGID_DOC_NUM   + 1;
C_IMGID_DOC_GROUP = C_IMGID_DOC_ID    + 1;
C_IMGID_NFRMS     = C_IMGID_DOC_GROUP + 1;
C_IMGID_LENGHT    = C_IMGID_NFRMS;

% Class values
C_CLASS_POSITIVE = 1;
C_CLASS_NEGATIVE = -1;

% Dataset Plan
C_NUM_OF_EXP = 5;
C_DSETPLAN_CLASS     = 1;
C_DSETPLAN_DOCLANG   = C_DSETPLAN_CLASS     + 1;
C_DSETPLAN_DOCPICT   = C_DSETPLAN_DOCLANG   + 1;
C_DSETPLAN_DOCNUM    = C_DSETPLAN_DOCPICT   + 1;
C_DSETPLAN_DOCID     = C_DSETPLAN_DOCNUM    + 1;
C_DSETPLAN_DOCGROUP  = C_DSETPLAN_DOCID     + 1;
C_DSETPLAN_NFRMS     = C_DSETPLAN_DOCGROUP  + 1;
C_DSETPLAN_EXP_GROUP = C_DSETPLAN_NFRMS     + 1;
C_DSETPLAN_EXP       = C_DSETPLAN_EXP_GROUP + 1;
C_DSETPLAN_LENGTH    = C_DSETPLAN_EXP + C_NUM_OF_EXP - 1;
C_DSETPLAN_COLOR_ID  = 100000;

% Frame Vector Header
C_FRMVEC_CLASS     = 1;
C_FRMVEC_DOCID     = C_FRMVEC_CLASS + 1;
C_FRMVEC_DOCGROUP  = C_FRMVEC_DOCID + 1;
C_FRMVEC_FRMID     = C_FRMVEC_DOCGROUP + 1;
C_FRMVEC_IROW      = C_FRMVEC_FRMID + 1;
C_FRMVEC_FROW      = C_FRMVEC_IROW + 1;
C_FRMVEC_ICOL      = C_FRMVEC_FROW + 1;
C_FRMVEC_FCOL      = C_FRMVEC_ICOL + 1;
C_FRMVEC_EXP_GROUP = C_FRMVEC_FCOL + 1;
C_FRMVEC_EXP       = C_FRMVEC_EXP_GROUP + 1;
C_FRMVEC_FVEC      = C_FRMVEC_EXP + C_NUM_OF_EXP;
C_FRMVEC_LENGTH    = C_FRMVEC_FVEC - 1;

% Dataset Experiments Code
C_EXP_TRAINING   = 1;
C_EXP_VALIDATION = 2;
C_EXP_TEST       = 3;
C_EXP_TRAINVAL   = 4;
C_EXP_ALL        = 5;

% Classification Methods
METHOD_SVM_SMO       = 1;
METHOD_SVM_ISDA      = METHOD_SVM_SMO + 1;
METHOD_SVM_OLD       = METHOD_SVM_ISDA + 1;
METHOD_TREE_ENSAMBLE = METHOD_SVM_OLD + 1;
METHOD_TREE_GDI      = METHOD_TREE_ENSAMBLE + 1;
METHOD_TREE_TWOING   = METHOD_TREE_GDI + 1;
METHOD_TREE_DEVIANCE = METHOD_TREE_TWOING + 1;
METHOD_LAST_VALUE    = METHOD_TREE_DEVIANCE;

% Ranking Types
RNK_NO         = 0;
RNK_ALL_DVGSUP = RNK_NO         + 1;
RNK_ALL_RNDFOR = RNK_ALL_DVGSUP + 1;
RNK_POS_DVGSUP = RNK_ALL_RNDFOR + 1;
RNK_POS_RNDFOR = RNK_POS_DVGSUP + 1;
RNK_NEG_DVGSUP = RNK_POS_RNDFOR + 1;
RNK_NEG_RNDFOR = RNK_NEG_DVGSUP + 1;

% Divergence Metrics
DVG_DIVG    = 1;
DVG_XDVG    = DVG_DIVG + 1;
DVG_KS_H    = DVG_XDVG + 1;
DVG_KS_P    = DVG_KS_H + 1;
DVG_KS_K    = DVG_KS_P + 1;
DVG_RNKDIVG = DVG_KS_K + 1;
DVG_RNKXDVG = DVG_RNKDIVG  + 1;
DVG_LENGTH  = DVG_RNKXDVG;

% Cross Classes Divergence Metrics
CROSSDVG_XDVG   = 1;
CROSSDVG_DIVG   = CROSSDVG_XDVG + 1;
CROSSDVG_KS_H   = CROSSDVG_DIVG + 1;
CROSSDVG_KS_P   = CROSSDVG_KS_H + 1;
CROSSDVG_KS_K   = CROSSDVG_KS_P + 1;
CROSSDVG_LENGTH = CROSSDVG_KS_K;

% Metrics
METRIC_METRICS      = 1;
METRIC_REALPOS      = METRIC_METRICS;
METRIC_REALNEG      = METRIC_REALPOS + 1;
METRIC_PREDPOS      = METRIC_REALNEG + 1;
METRIC_PREDNEG      = METRIC_PREDPOS + 1;
METRIC_TRUEPOS      = METRIC_PREDNEG + 1;
METRIC_FALSENEG     = METRIC_TRUEPOS + 1;
METRIC_FALSEPOS     = METRIC_FALSENEG + 1;
METRIC_TRUENEG      = METRIC_FALSEPOS + 1;
METRIC_TRUEPOSPERC  = METRIC_TRUENEG + 1;
METRIC_FALSENEGPERC = METRIC_TRUEPOSPERC + 1;
METRIC_FALSEPOSPERC = METRIC_FALSENEGPERC + 1;
METRIC_TRUENEGPERC  = METRIC_FALSEPOSPERC + 1;
METRIC_ACCURACY     = METRIC_TRUENEGPERC + 1;
METRIC_RECALL       = METRIC_ACCURACY + 1;
METRIC_SPECIFICITY  = METRIC_RECALL + 1;
METRIC_PRECISION    = METRIC_SPECIFICITY + 1;
METRIC_NEGPREDVAL   = METRIC_PRECISION + 1;
METRIC_F1SCORE      = METRIC_NEGPREDVAL + 1;
METRIC_F1NEG        = METRIC_F1SCORE + 1;
METRIC_LENGTH       = METRIC_F1NEG;

% Minimum value for recall and precision
MIN_THSR_METRIC = 0.6;

% Doc / Frames metrics file header
C_HDRMTR_CLASS    = 1;
C_HDRMTR_EXPNUM   = C_HDRMTR_CLASS + 1;
C_HDRMTR_TSTID    = C_HDRMTR_EXPNUM + 1;
C_HDRMTR_METHOD   = C_HDRMTR_TSTID + 1;
C_HDRMTR_FVLENGTH = C_HDRMTR_METHOD + 1;
C_HDRMTR_LENGTH   = C_HDRMTR_FVLENGTH;

% Attribution Frame File
C_ATTRIBFRM_DOCID     = C_HDRMTR_LENGTH + 1;
C_ATTRIBFRM_FRMID     = C_ATTRIBFRM_DOCID + 1;
C_ATTRIBFRM_PREDICTED = C_ATTRIBFRM_FRMID + 1;
C_ATTRIBFRM_LENGTH    = C_ATTRIBFRM_FRMID;

% Attribution Frame File
C_ATTRIBDOC_DOCID     = C_HDRMTR_LENGTH + 1;
C_ATTRIBDOC_NFRMS     = C_ATTRIBDOC_DOCID + 1;
C_ATTRIBDOC_PREDICTED = C_ATTRIBDOC_NFRMS + 1;
C_ATTRIBDOC_FRMPROB   = C_ATTRIBDOC_PREDICTED + 1;
C_ATTRIBDOC_CLASSOK   = C_ATTRIBDOC_FRMPROB + 1;
C_ATTRIBDOC_CLASSFRMS = C_ATTRIBDOC_CLASSOK + 1;
C_ATTRIBDOC_LENGTH    = C_ATTRIBDOC_CLASSOK;

% Doc / Frames metrics file header
C_HDRMTR_CLASS    = 1;
C_HDRMTR_EXPNUM   = C_HDRMTR_CLASS + 1;
C_HDRMTR_TSTID    = C_HDRMTR_EXPNUM + 1;
C_HDRMTR_METHOD   = C_HDRMTR_TSTID + 1;
C_HDRMTR_FVLENGTH = C_HDRMTR_METHOD + 1;
C_HDRMTR_LENGTH   = C_HDRMTR_FVLENGTH;

% Feature Analysis Metrics
C_FEAT_STATS_EXPNUM     = 1;
C_FEAT_STATS_CLASS      = C_FEAT_STATS_EXPNUM + 1;
C_FEAT_STATS_FEATIDX    = C_FEAT_STATS_CLASS + 1;
C_FEAT_STATS_FEATORG    = C_FEAT_STATS_FEATIDX + 1;
C_FEAT_STATS_RANK       = C_FEAT_STATS_FEATORG + 1;
C_FEAT_STATS_IMPORTANCE = C_FEAT_STATS_RANK + 1;
C_FEAT_STATS_DISTRIRANK = C_FEAT_STATS_IMPORTANCE + 1;
C_FEAT_STATS_DISTRI_IMP = C_FEAT_STATS_DISTRIRANK + 1;
C_FEAT_STATS_FEAT_TYPE  = C_FEAT_STATS_DISTRI_IMP + 1;
C_FEAT_STATS_N_FVCLASS  = C_FEAT_STATS_FEAT_TYPE + 1;
C_FEAT_STATS_N_FVOTHER  = C_FEAT_STATS_N_FVCLASS + 1;
C_FEAT_STATS_N_CLSGZER  = C_FEAT_STATS_N_FVOTHER + 1;
C_FEAT_STATS_N_NONGZER  = C_FEAT_STATS_N_CLSGZER + 1;
C_FEAT_STATS_MEDIAN_CLS = C_FEAT_STATS_N_NONGZER  + 1;
C_FEAT_STATS_MEDIAN_OTH = C_FEAT_STATS_MEDIAN_CLS + 1;
C_FEAT_STATS_STATS_H    = C_FEAT_STATS_MEDIAN_OTH + 1;
C_FEAT_STATS_STATS_P    = C_FEAT_STATS_STATS_H + 1;
C_FEAT_STATS_CLASS_INI  = C_FEAT_STATS_STATS_P + 1;
C_FEAT_STATS_CLASS_END  = C_FEAT_STATS_CLASS_INI + 1;
C_FEAT_STATS_OTHER_INI  = C_FEAT_STATS_CLASS_END + 1;
C_FEAT_STATS_OTHER_END  = C_FEAT_STATS_OTHER_INI + 1;
C_FEAT_STATS_LENGTH     = C_FEAT_STATS_OTHER_END;

% Features Length
C_FEAT_LENGTH_CLASS   = 1;
C_FEAT_LENGTH_TOT     = C_FEAT_LENGTH_CLASS + 1;
C_FEAT_LENGTH_EVAL    = C_FEAT_LENGTH_TOT + 1;
C_FEAT_LENGTH_MIN     = C_FEAT_LENGTH_EVAL + 1;
C_FEAT_LENGTH_MAX     = C_FEAT_LENGTH_MIN + 1;
C_FEAT_LENGTH_LENGTH  = C_FEAT_LENGTH_MAX;

% Class Frames Evaluation
C_FRM_EVAL_CLASS   = 1;
C_FRM_EVAL_DOC     = C_FRM_EVAL_CLASS + 1;
C_FRM_EVAL_FRM     = C_FRM_EVAL_DOC + 1;
C_FRM_EVAL_FRMHASH = C_FRM_EVAL_FRM + 1;
C_FRM_EVAL_NFVS    = C_FRM_EVAL_FRMHASH + 1;
C_FRM_EVAL_WEIGHT  = C_FRM_EVAL_NFVS + 1;
C_FRM_EVAL_RANK    = C_FRM_EVAL_WEIGHT + 1;
C_FRM_EVAL_LENGTH  = C_FRM_EVAL_RANK;

% Document Frame Metrics Header
C_FRM_MTR_CLASS_ID    = 1;
C_FRM_MTR_DOC_ID      = C_FRM_MTR_CLASS_ID + 1;
C_FRM_MTR_FRM_ID      = C_FRM_MTR_DOC_ID + 1;
C_FRM_MTR_FRM_HASH    = C_FRM_MTR_FRM_ID + 1;
C_FRM_MTR_DOC_LANG    = C_FRM_MTR_FRM_HASH + 1;
C_FRM_MTR_DOC_PICT    = C_FRM_MTR_DOC_LANG + 1;
C_FRM_MTR_DOC_NUM     = C_FRM_MTR_DOC_PICT + 1;
C_FRM_MTR_GLOW        = C_FRM_MTR_DOC_NUM + 1;
C_FRM_MTR_GHIGH       = C_FRM_MTR_GLOW + 1;
C_FRM_MTR_BORDER_UP   = C_FRM_MTR_GHIGH + 1;
C_FRM_MTR_BORDER_LEFT = C_FRM_MTR_BORDER_UP + 1;
C_FRM_MTR_FRM_IROW    = C_FRM_MTR_BORDER_LEFT + 1;
C_FRM_MTR_FRM_FROW    = C_FRM_MTR_FRM_IROW + 1;
C_FRM_MTR_FRM_ICOL    = C_FRM_MTR_FRM_FROW + 1;
C_FRM_MTR_FRM_FCOL    = C_FRM_MTR_FRM_ICOL + 1;
C_FRM_MTR_I_NR        = C_FRM_MTR_FRM_FCOL + 1;
C_FRM_MTR_I_NC        = C_FRM_MTR_I_NR + 1;
C_FRM_MTR_LENGTH        = C_FRM_MTR_I_NC;

% Frames Metrics Complements
C_FRM_MTR1_WEIGHT    = C_FRM_MTR_LENGTH + 1;
C_FRM_MTR1_RANKCLASS = C_FRM_MTR1_WEIGHT + 1;
C_FRM_MTR1_RANKALL   = C_FRM_MTR1_RANKCLASS + 1;
C_FRM_MTR1_LENGTH    = C_FRM_MTR1_RANKALL;

% Heat Maps Configuration File
C_HMAP_CLASS        = 1;
C_HMAP_LANG         = C_HMAP_CLASS        + 1;
C_HMAP_PICT         = C_HMAP_LANG         + 1;
C_HMAP_NUMDOC       = C_HMAP_PICT         + 1;
C_HMAP_DOCID        = C_HMAP_NUMDOC       + 1;
C_HMAP_DOCGROUP     = C_HMAP_DOCID        + 1;
C_HMAP_FRMID        = C_HMAP_DOCGROUP     + 1;
C_HMAP_INI_ROW      = C_HMAP_FRMID        + 1;
C_HMAP_END_ROW      = C_HMAP_INI_ROW      + 1;
C_HMAP_INI_COL      = C_HMAP_END_ROW      + 1;
C_HMAP_END_COL      = C_HMAP_INI_COL      + 1;
C_HMAP_CLASS_FILTER = C_HMAP_END_COL      + 1;
C_HMAP_COLORBAR     = C_HMAP_CLASS_FILTER + 1;
C_HMAP_LENGTH       = C_HMAP_COLORBAR; 

% Lenght Metrics
C_LEN_MTR_ITER    = 1;
C_LEN_MTR_MINLEN  = C_LEN_MTR_ITER    + 1;
C_LEN_MTR_MINF1S  = C_LEN_MTR_MINLEN  + 1;
C_LEN_MTR_BESTLEN = C_LEN_MTR_MINF1S  + 1;
C_LEN_MTR_BESTF1S = C_LEN_MTR_BESTLEN + 1;
C_LEN_MTR_LENGHT  = C_LEN_MTR_BESTF1S;

% Docs Frames Distribution Analysis
C_DOC_DISTRI_CLASS  = 1;
C_DOC_DISTRI_DOCID  = C_DOC_DISTRI_CLASS + 1;
C_DOC_DISTRI_NFRMS  = C_DOC_DISTRI_DOCID + 1;
C_DOC_DISTRI_SCORE  = C_DOC_DISTRI_NFRMS + 1;
C_DOC_DISTRI_MAXSCR = C_DOC_DISTRI_SCORE + 1;
C_DOC_DISTRI_LENGTH = C_DOC_DISTRI_MAXSCR;

% Final Metrics analysis
C_FINAL_METRICS_MIN    = 1;
C_FINAL_METRICS_MEAN   = C_FINAL_METRICS_MIN  + 1;
C_FINAL_METRICS_MAX    = C_FINAL_METRICS_MEAN + 1;
C_FINAL_METRICS_STDV   = C_FINAL_METRICS_MAX  + 1;
C_FINAL_METRICS_MS2SD  = C_FINAL_METRICS_STDV + 1;
C_FINAL_METRICS_MA2SD  = C_FINAL_METRICS_MS2SD + 1;
C_FINAL_METRICS_LENGTH = C_FINAL_METRICS_MA2SD;

% Elapsed Time Metrics
C_ELAPSED_RANK     = 1;
C_ELAPSED_CLASS    = C_ELAPSED_RANK + 1;
C_ELAPSED_EXPNUM   = C_ELAPSED_CLASS + 1;
C_ELAPSED_TSTID    = C_ELAPSED_EXPNUM + 1;
C_ELAPSED_METHOD   = C_ELAPSED_TSTID + 1;
C_ELAPSED_FVLENGTH = C_ELAPSED_METHOD + 1;
C_ELAPSED_NUMFVS   = C_ELAPSED_FVLENGTH + 1;
C_ELAPSED_TIME     = C_ELAPSED_NUMFVS + 1;
C_ELAPSED_TIMEPFV  = C_ELAPSED_TIME + 1;
C_ELAPSED_LENGTH   = C_ELAPSED_TIMEPFV;

C_TIMEXVAR_FVLEN   = 1;
C_TIMEXVAR_NUMFVS  = C_TIMEXVAR_FVLEN + 1;

% Paper Color codes
C_PAPERCOLOR_WHITE  = 0;
C_PAPERCOLOR_BLUE   = C_PAPERCOLOR_WHITE + 1;
C_PAPERCOLOR_GREEN  = C_PAPERCOLOR_BLUE + 1;
C_PAPERCOLOR_ROSE   = C_PAPERCOLOR_GREEN + 1;
C_PAPERCOLOR_BEIGE  = C_PAPERCOLOR_ROSE + 1;
C_PAPERCOLOR_YELLOW = C_PAPERCOLOR_BEIGE + 1;
C_PAPERCOLOR_ALL    = 99;

