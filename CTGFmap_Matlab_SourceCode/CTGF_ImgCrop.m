%_author: Luiz Claudio Navarro (student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_professor: Prof. Dr. Anderson Rocha
%_version/date: v1.0.2r0/2017.09.16
%

function [I, bord_r, bord_c] = CTGF_ImgCrop(Img, BitDepth)

% Contant values, all constant value names begin as "C_" following by CAPS
C_GRAY_DEPTH = 8;                   % Color depth for Grayscale Image

% If image matrix is not grayscale, converts it to grayscale                                   
if BitDepth > C_GRAY_DEPTH
    Img = rgb2gray(Img);
end

% Compute and crop image borders
[n_r, n_c] = size(Img);
bord_r = floor(n_r * (6/100)); 
bord_c = floor(n_c * (6/100));
I = single(Img(bord_r : (n_r - bord_r), bord_c: (n_c - bord_c))); 

end

