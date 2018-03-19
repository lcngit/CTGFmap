%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function NormClassImp = CTGFmap_Normalize_Importance(KeepVec, ClassImp)

ClassImp(KeepVec == 0) = 0;
% abs is important on the following formula to normalize positive and
% negative importance values to abs sum equals 1.
sumClassImp = sum(abs(ClassImp));
if sumClassImp == 0
    error('!!!Error: Sum of Importance Vector is 0!');
end
NormClassImp = ClassImp ./ sumClassImp;

end