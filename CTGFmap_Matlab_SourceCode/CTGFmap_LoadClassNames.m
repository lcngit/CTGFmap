%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function [ClassNames, n_names] = CTGFmap_LoadClassNames()

% Load classes names
infname = 'ClassesName.csv';
disp(['*** Reading Classes name file = ', infname, ' ***']);
fp = fopen(infname,'r');
ClassAux = textscan(fp,'%s');
ClassNames = ClassAux {1, 1};
n_names  = numel(ClassNames);
for i = 1 : n_names
    ClassNames(i) = regexprep(ClassNames(i),',','');
end
clearvars ClassAux
fclose(fp);

end
