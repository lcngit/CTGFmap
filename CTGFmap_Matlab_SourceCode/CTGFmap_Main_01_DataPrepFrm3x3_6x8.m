%_author: Luiz Claudio Navarro (student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.5r0/2017.09.22
%_application: CTGF Features mapping

clear
clc
dbstop if error

[strcolor, numcolor] = CTGFmap_GetColorPaper('Select paper color: ');
dirtif   = input('Image files directory: ', 's');
dirtif   = strrep(dirtif, '\', '/');
if dirtif(end) ~= '/'
    dirtif = strcat(dirtif, '/');
end
cfgfile  = input('Dataset plan config file: ', 's');
diaryfile = strcat('colorpaper_dataprep_log_', strrep(strrep(datestr(now), ...
    ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);
initime = datetime('now');
disp(['+++ Begin - CTGF Data Preparation - ', datestr(initime), ' +++']);

disp(['Image files directory: ', dirtif]);
disp(['Config file (dataset plan): ', cfgfile]);
CTGFmap_DataPrep(numcolor, 1, 32, 6, 8, 3, dirtif, cfgfile);

endtime = datetime('now');
disp(['+++ End - CTGF Data Preparation - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

close all
diary('off')
