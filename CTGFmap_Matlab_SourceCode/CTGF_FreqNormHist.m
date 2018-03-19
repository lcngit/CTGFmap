%_author: Luiz Claudio Navarro (student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%

function HN = CTGF_FreqNormHist (Hist, dl, dh, n_rf, n_cf)
                              
% Input check to avoid input errors propagation and wrong use.
if ~isvector(Hist)
    error('Input must be a vector');
end

nc = numel(Hist);

if dl >= (nc / 2) || dh >= (nc / 2)   
    error('dl and dh - discarded itens to calculate normalization factor should be less than half size of vector');
end

% Normalize histogram dividing number by the number of pixels on the frame
H = double(abs(Hist(:)));
HN = H ./ (n_rf * n_cf);
if dl > 0
    HN(1:dl) = 0;
end
if dh > 0
    HN(end-dh+1:end) = 0;
end

end
