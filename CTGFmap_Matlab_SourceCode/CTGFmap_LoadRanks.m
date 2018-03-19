%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function ClassesRank = CTGFmap_LoadRanks(Classes, fv_length, rnk_type)

CTGFmap_IncludeConstants;

[rnk_str, ~] = CTGFmap_Rank_Type(rnk_type);

n_cls = numel(Classes);

disp('*** Begin Loading Classes Rank ***');

if rnk_type == RNK_NO
    ClassesRank = zeros(n_cls,fv_length);
    for cls = 1:n_cls
        ClassesRank(cls, :) = 1:fv_length;
    end
else
    rnkfname = strcat('FrmFeatVec_Rank_', rnk_str, '.csv');
    disp(['    Reading Ranking file: ', rnkfname]);
    ClassesRank = csvread(rnkfname);
    [nr_cr, nc_cr] = size(ClassesRank);
    if nr_cr ~= n_cls || nc_cr ~= fv_length
        error('!!!Error: Invalid Rank file!');
    end
end

disp('*** End Loading Classes Rank ***');

end
