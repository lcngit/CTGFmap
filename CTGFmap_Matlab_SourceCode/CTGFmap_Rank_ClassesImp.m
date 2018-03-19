%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function CTGFmap_Rank_ClassesImp(KeepVecs, ClassesImp, Classes, rnk_type)

[rnk_str, ~] = CTGFmap_Rank_Type(rnk_type);

disp(['+++ Begin - Ranking Features type ', rnk_str, ...
    ' for all classes - ', datestr(now), ' +++']);

[n_cls, ~] = size(Classes);
[nr_imp, fv_length] = size(ClassesImp);
[nr_kp, nc_kp] = size(KeepVecs);
if n_cls ~= nr_imp || n_cls ~= nr_kp || fv_length ~= nc_kp
    error('!!!!! Error: Invalid data sizes!');
end

ClassesRank    = zeros(n_cls, fv_length);
NormClassesImp = zeros(n_cls, fv_length);

for cls = 1:n_cls
    
    [Rank, NormImp] = CTGFmap_Rank_Importance(KeepVecs(cls, :), ...
        ClassesImp(cls, :));       
    NormClassesImp(cls, :) = NormImp;
    ClassesRank(cls, :) = Rank;
    disp(['--- Class ', num2str(Classes(cls)), ' - Ranked features ', ...
          num2str(sum(Rank ~= 0)), ' ---']);

end

disp(['+++ End - Ranking Features ', rnk_str, ' for all classes - ', ...
      datestr(now), ' +++']);

% Save Feature Importance and Feature Ranking.
outfname = strcat('FrmFeatVec_Imp_', rnk_str, '.csv');
dlmwrite(outfname, NormClassesImp, 'delimiter', ',', 'precision', 12);
disp(['*** Class Feature Importance Vectors saved into file: ', ...
    outfname, ' ****']);
outfname = strcat('FrmFeatVec_Rank_', rnk_str, '.csv');
dlmwrite(outfname, ClassesRank, 'delimiter', ',', 'precision', 12);
disp(['*** Class Feature Rank Vectors saved into file: ', ...
    outfname, ' ****']);
disp(' ');

end