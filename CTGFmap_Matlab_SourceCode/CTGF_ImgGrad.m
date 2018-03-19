%_author: Luiz Claudio Navarro (student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_professor: Prof. Dr. Anderson Rocha
%_version/date: v1.0.2r0/2017.09.16
%

function [H_Grad, I_Grad] = CTGF_ImgGrad (I)

% Consistency checks to guarantee function results
if ~ismatrix(I)
    error('Input must be a matrix of grayscale pixels - it is not integer');
end
if ~isa(I, 'single')
    error('Input must be a matrix of grayscale pixels - it is not single');
end
if max(I(:)) > 255
    error('Input must be a matrix of grayscale pixels - There is(are) element(s) > 255');
end

[n_lines, n_cols] = size(I);

% Compute maximum absolute variation on neighbors related to the pixel
%  in the center of the nine pixels square.
PLin = I(2 : n_lines - 1, 2 : n_cols - 1);   % square (2,2)
G_1 = abs(I(1 : n_lines - 2 , 1 : n_cols - 2) - PLin);  % square (1,1)
for i = 1 : 3
    for j = 1 : 3
        if i == j % exclude 1,1; 2,2; 3,3
            continue
        end
        G_2 = abs(I(i : n_lines - 3 + i , j : n_cols - 3 + j) - PLin);
        G_1 = max(G_1, G_2);
    end
end
G_2 = abs(I(3 : n_lines, 3 : n_cols) - PLin);   % square (3,3)
I_Grad = zeros(n_lines, n_cols, 'single');
I_Grad(2 : n_lines - 1, 2 : n_cols - 1) = max(G_1, G_2);

%Compute gradient histogram
bins = 0:255;                        
H_Grad = histc(I_Grad(:), bins);

end


