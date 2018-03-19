%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

clear
clc
dbstop if error

CTGFmap_IncludeConstants;

exp_num = 1;

diaryfile = strcat('xdvgchart_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Xmax Chart +++');

keepfname = 'FrmFeatVec_Keep.csv';
disp(['*** Reading Features Keep Vector from file: ', keepfname, ' ****']);
KeepVec = csvread(keepfname);
fv_length = numel(KeepVec);

dvgfname = 'FrmFeatVec_Xdvg.csv';
disp(['*** Reading Features Xdvg from file: ', dvgfname, ' ****']);
ClassXdvg = csvread(dvgfname);
[~, k_length] = size(ClassXdvg);
if sum(KeepVec) ~= k_length
    error('!!!Error: Keep Vector does not match Xdvg vector!');
end

MaxClassXdvg = max(ClassXdvg);
XmaxValues = zeros(1, fv_length);
XmaxValues(KeepVec ~= 0) = MaxClassXdvg;
max_imp = max(max(XmaxValues));
min_imp = min(min(XmaxValues));

disp(['=== Begin - Building Chart for density cutting point - ', datestr(now), ' ===']);

X_values = 0:(fv_length-1);
fig1 = figure;
p = bar(X_values, XmaxValues, 0.5);
ax = gca;
ax.YLim = [min_imp max_imp];
ax.XLim = [-20 (fv_length+20)];
ax.XTick = 0:200:2200;
ax.TickDir = 'out';
ax.FontSize = 14;
hold on
X_Discarded = X_values(KeepVec == 0);
Y_Discarded = zeros(1, numel(X_Discarded));
plot(X_Discarded, Y_Discarded, '.r');
lgd1 = legend('  Density cuting point', ' Discarded feature ', ...
    'Location', 'north');
xlabel(['Feature (X', num2str(X_values(1)), ' to X', num2str(X_values(end)), ')']);
ylabel('CTGF density (textures/squared dots)');
title('Density cutting point for each feature')
lgd1.FontSize = 12;
fig1.Units = 'centimeters';
fig1.Position = [0.5, 0.5, 25, 15];
fig1.PaperType = 'a4';
fig1.PaperOrientation = 'landscape';
hold off

figfname = 'FeaturesXdvg_A4_300dpi';
print(figfname,'-dpdf', '-r300');


close all

endtime = datetime('now');
disp(['+++ End - Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
