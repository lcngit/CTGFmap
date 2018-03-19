%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function [FeatVecs, FeatIds, KeepVec] = CTGFmap_SelectFeatures(k_length, ...
    Rank, FeatVecsFull, FeatIdsFull)

CTGFmap_IncludeConstants;

disp (['*** Begin - Selecting Ranked Features - size ', num2str(k_length), ' ***']);

KeepVec = Rank > 0 & Rank <= k_length;
FeatVecs = FeatVecsFull(:, KeepVec);
FeatIds = FeatIdsFull(KeepVec);

disp (['*** End - Selecting Ranked Features - size ', num2str(k_length), ' ***']);

end
