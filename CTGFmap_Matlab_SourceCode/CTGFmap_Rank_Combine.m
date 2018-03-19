%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function NewerRank = CTGFmap_Rank_Combine(OldRank, NewRank, KeepVec)

disp(['*** Begin - Combining NewRank(KeepVec) into Old Rank - ', ...
    datestr(now), ' ***']);

fv_keep = numel(KeepVec);
fv_old = numel(OldRank);
fv_new = numel(NewRank);
if fv_keep ~= fv_old || fv_old ~= fv_new
    error('!!!Error: Old, New and Keep Vectors with different sizes!');
end
k_length = sum(KeepVec);
R1 = OldRank(KeepVec);
R2 = NewRank(KeepVec);
if (max(R1) ~= k_length) || (min(R1) ~= 1) || (sum(R1 > 0) ~= k_length)
    error('!!!Error: Invalid Old Rank for update!')
end
if (max(R2) ~= k_length) || (min(R2) ~= 1) || (sum(R2 > 0) ~= k_length)
    error('!!!Error: Invalid Rank for update!')
end

[~, IdxNewR] = sort(abs(R1 + R2), 'ascend');
AuxR = zeros(1, k_length);
for k = 1:k_length
    AuxR(IdxNewR(k)) = k;
end

NewerRank = OldRank;
NewerRank(KeepVec) = AuxR;

if max(NewerRank(KeepVec)) ~= k_length || min(NewerRank(KeepVec)) ~= 1 || ...
        sum(NewerRank(KeepVec) > 0) ~= k_length
    error('!!!Error: Invalid updated new Rank!')
end

disp(['*** End - Combining NewRank(KeepVec) into Old Rank - ', ...
    datestr(now), ' ***']);

end