%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function [x_dvg, divg, ks_h, ks_p, ks_k] = CTGFmap_MaxCDFdiff(Data_p, Data_q)

n_p = numel(Data_p(:));
n_q = numel(Data_q(:));
X_values = sort(unique([Data_p(:)', Data_q(:)']));
n_x = numel(X_values);
CDF_p = zeros(1, n_x);
CDF_q = zeros(1, n_x);
DiffCDFs = zeros(1, n_x);

% fill return values with default values for no difference
x_dvg = 0;
divg = 0;

if sum(isnan(X_values)) > 0
    error('!!!Error: data contains NaN values!');
end

% Test equality using Two-sample Kolmogorov-Smirnov test
[ks_h, ks_p, ks_k] = kstest2(Data_p, Data_q);

if ks_h ~= 0 % if null hypothesis rejected, compute maximum difference
    
    % Compute CDFs and their difference
    for i = 1:n_x
        CDF_p(i) = sum(Data_p(:) <= X_values(i)) ./ n_p;
        CDF_q(i) = sum(Data_q(:) <= X_values(i)) ./ n_q;
        if (CDF_p(i) + CDF_q(i)) == 2
            DiffCDFs(i) = 0;
        else
            DiffCDFs(i) = CDF_q(i) - CDF_p(i);
        end
    end
    
    % Find index of the maximum absolute difference
    AbsDif = abs(DiffCDFs);
    maxdif = max(AbsDif);
    Idx = find(AbsDif == maxdif);
    if isscalar(Idx)
        i_dvg = Idx;
    else
        i_dvg = Idx(ceil(numel(Idx) / 2));
    end
    
    % return X value and CDFs maximum difference
    x_dvg = X_values(i_dvg);
    divg = DiffCDFs(i_dvg);
    
end

end
