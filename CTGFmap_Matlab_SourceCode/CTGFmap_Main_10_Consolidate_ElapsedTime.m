%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.0r0/2017.08.07
%_application: CTGF Features mapping

clear
clc

CTGFmap_IncludeConstants;
mtd = METHOD_TREE_ENSAMBLE;
n_exp = C_NUM_OF_EXP - 1;

diaryfile = strcat('elapsedtime_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Elapsed Time Consolidation +++')

fmask = 'ElapsedTime_*.csv';
flist = dir(fmask);
n_f = numel(flist);

AllElapsedTime = zeros(1, C_ELAPSED_LENGTH);
for i_f = 1:n_f
    fname = flist(i_f).name;
    disp(['    #', num2str(i_f), ' Reading Elapsed Time file: ', fname]);
    ElapsedTime = csvread(fname);
    [nr, nc] = size(ElapsedTime);
    if isempty(ElapsedTime) || nc ~= C_ELAPSED_LENGTH
        error(['!!! Error: Invalid Elapsed Time file: ', fname]);
    end
    AllElapsedTime = vertcat(AllElapsedTime, ElapsedTime);  %#ok<AGROW>
end


ElapsedTime(1, :) = [];
[n_all, ~] = size(AllElapsedTime);
disp(['--- ', num2str(n_all), ' elapsed time records collected.']);

NonDupElapsedTime = unique(AllElapsedTime, 'rows');
[n_elt, ~] = size(NonDupElapsedTime);
outfname = strcat('AllElapsedTime.csv');
dlmwrite(outfname, NonDupElapsedTime, 'delimiter', ',', 'precision', 12);
disp(['--- ', num2str(n_elt), ...
    ' non duplicated elapsed time records saved into file: ', outfname]);

endtime = datetime('now');
disp(['+++ End - Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
