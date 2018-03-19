%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function [ClassRank, NormClassImp] = CTGFmap_Rank_Importance(KeepVec, ClassImp)

disp(['+++ Begin - Ranking Features based on Importance - ', ...
    datestr(now), ' +++']);

fv_length = numel(KeepVec);
if numel(ClassImp) ~= fv_length
    error('!!!Error: Class Importance and Keep Vector does not match!');
end
k_length = sum(KeepVec);

NormClassImp = CTGFmap_Normalize_Importance(KeepVec, ClassImp);

ImpVec = NormClassImp(KeepVec);
Rank = zeros(1, k_length);
[~, IdxImpVec] = sort(abs(ImpVec), 'descend');
for k = 1:k_length
    Rank(IdxImpVec(k)) = k;
end

NormClassImp(KeepVec == 0) = 0;
ClassRank = zeros(1, fv_length);
ClassRank(KeepVec == 1) = Rank;

if max(ClassRank(KeepVec)) ~= k_length || min(ClassRank(KeepVec)) ~= 1 || ...
        sum(ClassRank > 0) ~= k_length
    error('!!!Error: Invalid Rank!')
end

disp(['+++ End - Ranking Features based on Importance - ', ...
    datestr(now), ' +++']);

end