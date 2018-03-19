%_author: Luiz Claudio Navarro (student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_professor: Prof. Dr. Anderson Rocha
%_version/date: v1.0.2r0/2017.09.16
%

function H_Img = CTGF_ImgPixHist (I)

% Consistency checks to guarantee function results
if ~ismatrix(I);
    error('Input must be a matrix of grayscale pixels - it is not integer');
end
if ~isa(I, 'single');
    error('Input must be a matrix of grayscale pixels - it is not single');
end
if max(I(:)) > 255;
    error('Input must be a matrix of grayscale pixels - There is(are) element(s) > 255');
end

% Compute pixel values histogram for the grayscale image
bins = 0:255;                        
H_Img = histc(I(:), bins);

end


