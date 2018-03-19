%_author: Luiz Claudio Navarro (student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%

function [Metrics, PixH, GradFrm, GradH, GradLH, ConvFrm, ConvH, ConvLH, FiltConv, FiltGrad] ...
    = CTGFmap_FrameMetrics(Frame, glow, ghigh, ConvMat, cls_id, ...
    doc_lang, doc_pic, doc_num, doc_id, group_id, id_frm, ...
    brd_up, brd_lft, frm_irow, frm_frow, frm_icol, frm_fcol)

CTGFmap_IncludeConstants;

% Check parameters
if (glow > C_WHITE) || (ghigh > C_WHITE)
    error('Input thresholds should be less than white color value');
end

% Check convolution matrix
[nrconv, ncconv] = size(ConvMat);
if nrconv ~= ncconv
    error('Convolution Matrix should be less a square matrix');
end
convmaxv = sum(sum(ConvMat * 255));

% Compute Image Metrics
[n_rf, n_cf] = size(Frame);
Metrics = zeros (C_METRICS, 1);
Metrics(C_CLASS_ID)     = cls_id;
Metrics(C_DOC_LANG)     = doc_lang;
Metrics(C_DOC_PICT)     = doc_pic;
Metrics(C_DOC_NUM)      = doc_num;
Metrics(C_DOC_ID)       = doc_id;
Metrics(C_DOC_GROUP)    = group_id;
Metrics(C_FRM_NUM)      = id_frm;
Metrics(C_GLOW)         = glow;
Metrics(C_GHIGH)        = ghigh;
Metrics(C_BORDER_UP)    = brd_up;
Metrics(C_BORDER_LEFT)  = brd_lft;
Metrics(C_FRM_IROW)     = frm_irow;
Metrics(C_FRM_FROW)     = frm_frow;
Metrics(C_FRM_ICOL)     = frm_icol;
Metrics(C_FRM_FCOL)     = frm_fcol;
Metrics(C_I_NR)         = n_rf;
Metrics(C_I_NC)         = n_cf;
Metrics(C_I_NBLACK)     = sum(sum(Frame == 0));
Metrics(C_I_NWHITE)     = sum(sum(Frame == 255));
Metrics(C_I_NNEARBLACK) = sum(sum((Frame ~= 0) & (Frame < 32)));
Metrics(C_I_NNEARWHITE) = sum(sum((Frame ~= 255) & (Frame >= 224)));
Metrics(C_I_NDARKGRAY)  = sum(sum((Frame >= 64) & (Frame < 128)));
Metrics(C_I_NLIGHTGRAY) = sum(sum((Frame < 192) & (Frame >= 128)));
Metrics(C_I_NDARK)      = sum(sum(Frame < 128));
Metrics(C_I_NLIGHT)     = sum(sum(Frame >= 128));
Metrics(C_H_PIX)        = C_NPIX_VAL;
Metrics(C_H_GRAD)       = C_NPIX_VAL;
Metrics(C_H_CONV)       = convmaxv+1;
Metrics(C_H_FILTGRAD)   = C_NPIX_VAL;
Metrics(C_H_FILTCONV)   = convmaxv+1;

% Negative Image for white equals 0
N = C_WHITE - Frame;

% Compute Pixels Histogram                   
PixH = CTGF_ImgPixHist(N);
PixH = CTGF_FreqNormHist (PixH, 1, 1, n_rf, n_cf);

% Compute Gradient
[GradH, GradFrm] = CTGF_ImgGrad(N);
GradH = CTGF_FreqNormHist (GradH, 1, 1, n_rf, n_cf);

% Eliminate Pixels that are out of scope
% Low Gradient (plain areas) and High Gradient (borders)
GRAD_LOW  = GradFrm < glow;
GRAD_HIGH = GradFrm > ghigh;
N_WHITE   = N == 255;

FiltGrad = GradFrm;
FiltGrad(GRAD_LOW)  = 0;     % Eliminate codes from pixels those grad is <= GRAD_LOW
FiltGrad(GRAD_HIGH) = 0;     % Eliminate codes from pixels those grad is >= GRAD_HIGH
FiltGrad(N_WHITE)   = 0;     % Eliminate codes from pixels those central is White

% Compute Filtered Gradient histogram
I_grad = FiltGrad(FiltGrad(:) > 0);
bins = 0:C_WHITE;                 
GradLH = histc(I_grad, bins);
GradLH = CTGF_FreqNormHist(GradLH, 1, 1, n_rf, n_cf);

% Compute Image Convolution
[ConvH, ConvFrm] = CTGF_ImgConv (N, ConvMat);
ConvH = CTGF_FreqNormHist(ConvH, 1, 1, n_rf, n_cf);

% Eliminate Pixels that are out of scope
% Low Gradient (plain areas) and High Gradient (borders)
FiltConv = ConvFrm;
FiltConv(GRAD_LOW)  = 0;     % Eliminate codes from pixels that are <= GRAD_LOW
FiltConv(GRAD_HIGH) = 0;     % Eliminate codes from pixels that are >= GRAD_HIGH
FiltConv(N_WHITE)   = 0;     % Eliminate codes from pixels those central is White

% Compute Filtered Convolution histogram
I_Code = FiltConv(FiltConv(:) > 0);
codes = 0:convmaxv;                 
ConvLH = histc(I_Code, codes);
ConvLH = CTGF_FreqNormHist (ConvLH, 1, 1, n_rf, n_cf);

end



