%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2016.09.01
%_application: CTGF Features mapping

clear
clc
dbstop if error

for i = 1:10
    kpfname = strcat('KeepFigFrames', num2str(i), '.csv');
    disp(['*** Reading file: ', kpfname, ' ***']);
    Krec = csvread(kpfname);
    if i == 1
        KeepFrm = Krec;
    else
        KeepFrm = vertcat(KeepFrm, Krec); %#ok<AGROW>
    end
end

keepfname = strcat('KeepFigFrames.csv');
dlmwrite(keepfname, KeepFrm, 'delimiter', ',', 'precision', 12);
disp(['*** Frames containing figures to keep saved into file: ', ...
    keepfname, ' ***']);
