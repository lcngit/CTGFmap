%_author: Luiz Claudio Navarro (student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%

function [CodeDoc, CodeGroup] = CTGF_CodeDocHash(PrtDoc,  LangDoc, PictDoc, NumDoc)

% Creates a numeric value that represents file name
CodeGroup  = (((LangDoc * 2) + PictDoc) * 100) + NumDoc;
CodeDoc  = PrtDoc * 1000 + CodeGroup;

end

