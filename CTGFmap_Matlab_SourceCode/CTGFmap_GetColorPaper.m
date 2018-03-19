%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function [strcolor, numcolor] = CTGFmap_GetColorPaper(msginput)

CTGFmap_IncludeConstants;

disp('Paper color (only first letter):');
disp('White');
disp('Blue');
disp('Green');
disp('Rose');
disp('X=beige');
disp('Yellow');
disp('All colors');
strcolor = input(msginput,'s');
strcolor = upper(strcolor(1));
if strcolor == 'W'
    numcolor = C_PAPERCOLOR_WHITE;
elseif strcolor == 'B' 
    numcolor = C_PAPERCOLOR_BLUE;
elseif strcolor == 'G' 
    numcolor = C_PAPERCOLOR_GREEN;
elseif strcolor == 'R' 
    numcolor = C_PAPERCOLOR_ROSE;
elseif strcolor == 'X' 
    numcolor = C_PAPERCOLOR_BEIGE;
elseif strcolor == 'Y' 
    numcolor = C_PAPERCOLOR_YELLOW;
elseif strcolor == 'A' 
    numcolor = C_PAPERCOLOR_ALL;
else
    error(['!!!!! Error: Invalid color selected: ', strcolor]);
end    

end
