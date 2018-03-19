%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function FiltConv = CTGFmap_FrameConvTextGradFilt(Frame, glow, ghigh, ConvMat)

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

% Negative Image for white equals 0
N = C_WHITE - Frame;

% Compute Gradient
[~, GradFrm] = CTGF_ImgGrad(N);

% Eliminate Pixels that are out of scope
% Low Gradient (plain areas) and High Gradient (borders)
GRAD_LOW  = GradFrm < glow;
GRAD_HIGH = GradFrm > ghigh;
N_WHITE   = N == 255;

% Compute Image Convolution
[~, ConvFrm] = CTGF_ImgConv (N, ConvMat);

% Eliminate Pixels that are out of scope
% Low Gradient (plain areas) and High Gradient (borders)
FiltConv = ConvFrm;
FiltConv(GRAD_LOW)  = 0;     % Eliminate codes from pixels that are <= GRAD_LOW
FiltConv(GRAD_HIGH) = 0;     % Eliminate codes from pixels that are >= GRAD_HIGH
FiltConv(N_WHITE)   = 0;     % Eliminate codes from pixels those central is White

end



