%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

clear
clc
dbstop if error

CTGFmap_IncludeConstants;

fv_idx = input('Feature Index (see FVColIds): ');
N_INT = 50;
N_TAIL = 2;
DISTRI_MIN = 0.1;
DISTRI_MAX = 1 - DISTRI_MIN;

diaryfile = strcat('distrifeatallclschart_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Divergence Chart of all classes for a single feature +++');

[~, ~, FVColIds, fv_length, AllClassIds, AllDocIds, ...
    AllFrmIds, DsetPlan, AllFeatVecs, n_vec] = CTGFmap_LoadData();
Classes = sort(unique(AllClassIds));
n_cls = numel(Classes);

dvgfname = 'FrmFeatVec_Divg.csv';
disp(['*** Reading Classes Divergence Metrics from file: ', dvgfname, ' ***']);
DivgVal = csvread(dvgfname);
[nr_dvg, nc_dvg] = size(DivgVal);
if (nr_dvg ~= n_cls) || (nc_dvg ~= fv_length)
    error('!!! Error: Divergence and Feature vectors do not match!');
end

xdvfname = 'FrmFeatVec_Xdvg.csv';
disp(['*** Reading Classes X Divergence Metrics from file: ', xdvfname, ' ***']);
XdvgVal = csvread(xdvfname);
[nr_xdv, nc_xdv] = size(XdvgVal);
if (nr_xdv ~= n_cls) || (nc_xdv ~= fv_length)
    error('!!! Error: X Divergence and Feature vectors do not match!');
end

keepfname = 'FrmFeatVec_Keep.csv';
disp(['*** Reading initial keep vector from file: ', keepfname, ' ***']);
KeepVector = csvread(keepfname);
if sum(KeepVector) ~= fv_length
    error('!!! Error: Initial keep vector and rank vectors do not match!');
end
maxfname = 'FrmFeatVec_Max.csv';
disp(['*** Reading X max normalization values from file: ', maxfname, ' ***']);
MaxXval = csvread(maxfname);
MaxXval = MaxXval(KeepVector ~= 0);
fv_len_max = numel(MaxXval);
if fv_len_max ~= fv_length
    error('!!! Error: X max normalization and Rank vectors do not match!');
end
for i = 1:fv_length
    AllFeatVecs(:, i) = AllFeatVecs(:, i) .* MaxXval(i);
    XdvgVal(:, i) = XdvgVal(:, i) .* MaxXval(i);
end

disp(['=== Begin - Computing Distributions Divergence of Features ', ...
    'for all classes - ', datestr(now), ' ===']);

fv_name = FVColIds{fv_idx};
All_FVs = AllFeatVecs(:, fv_idx);
X_values = sort(unique(All_FVs));
n_x = numel(X_values);
CDF_cls = zeros(n_cls, n_x);
for cls = 1:n_cls
    Selcls = AllClassIds == Classes(cls);
    nfvcls = sum(Selcls);
    for i = 1:n_x
        CDF_cls(cls, i) = sum(All_FVs(Selcls) <= X_values(i)) ./ nfvcls;
    end
    disp(['--- Class: ', num2str(Classes(cls)), ...
        ', feature index: ', num2str(fv_idx), ...
        ', feature name: ', fv_name, ' ---']);
    disp(['    class num. of vectors .....: ', num2str(nfvcls)]);
    disp(['    X max normalization value .: ', num2str(MaxXval(fv_idx))]);
    fv_divg = DivgVal(cls, fv_idx);
    fv_xdvg = XdvgVal(cls, fv_idx);
    disp(['    Feature divg=', num2str(fv_divg), ...
        ', Feature xdvg=', num2str(fv_xdvg)]);
end
CDFmin = min(CDF_cls);
CDFmax = max(CDF_cls);
i_x1 = find(CDFmax >= DISTRI_MIN, 1, 'first');
i_xn = find(CDFmin <= DISTRI_MAX, 1, 'last');
x1 = X_values(i_x1);
xn = X_values(i_xn);
if n_x < N_INT
    n_itv = n_x;
    n_tlv = floor(n_x / N_INT) * N_TAIL;
else
    n_itv = N_INT;
    n_tlv = N_TAIL;
end
xstep = (xn - x1) / n_itv;
xprec = -floor(log10(xstep))+1;
xstep = round(xstep, xprec);
x1 = round(x1 - (n_tlv * xstep), xprec);
if x1 < 0
    x1 = 0;
end
Xedges = x1 + ((0:(n_itv + (2 * n_tlv))) * xstep);
n_edges = numel(Xedges);
Xge1 = Xedges >= 1;
nge1 = sum(Xge1);
if nge1 > 1
    Xedges(n_edges-nge1+1:end) = [];
    n_edges = numel(Xedges);
end
xn = Xedges(n_edges);

fig2 = figure;
lgdtxt = '';
% class 1
pcls1 = plot(X_values, CDF_cls(1,:), '-k');
pcls1.LineWidth = 1.5;
hold on
% class 2
pcls2 = plot(X_values, CDF_cls(2,:), ':k');
pcls2.LineWidth = 1.5;
hold on
% class 3
pcls3 = plot(X_values, CDF_cls(3,:), '-b');
pcls3.LineWidth = 1.5;
hold on
% class 4
pcls4 = plot(X_values, CDF_cls(4,:), ':b');
pcls4.LineWidth = 1.5;
hold on
% class 5
pcls5 = plot(X_values, CDF_cls(5,:), '-r');
pcls5.LineWidth = 1.5;
hold on
% class 6
pcls6 = plot(X_values, CDF_cls(6,:), ':r');
pcls6.LineWidth = 1.5;
hold on
% class 7
pcls7 = plot(X_values, CDF_cls(7,:), '-c');
pcls7.LineWidth = 1.5;
hold on
% class 8
pcls8 = plot(X_values, CDF_cls(8,:), ':c');
pcls8.LineWidth = 1.5;
hold on
% class 9
pcls9 = plot(X_values, CDF_cls(9,:), '-m');
pcls9.LineWidth = 1.5;
hold on
% class 10
pcls10 = plot(X_values, CDF_cls(10,:), ':m');
pcls10.LineWidth = 1.5;
hold on

pdif = plot([fv_xdvg,fv_xdvg], [0,1], '-.g');
pdif.LineWidth = 1.5;
title(['All Classes Cumulative Distribution for Feature: ', fv_name])
xlim([x1 xn]);
ylim([0 1]);
xlabel('feature value')
ylabel('cumulative probability')
ax2 = gca;
ax2.TickDir = 'out';
ax2.FontSize = 14;
lgd2 = legend('class 1', 'class 2', 'class 3', 'class 4', 'class 5', ...
    'class 6', 'class 7', 'class 8', 'class 9', 'class 10', ...
    'X for max. cross diff.', 'Location', 'southeast');
lgd2.FontSize = 12;
fig2.Units = 'centimeters';
fig2.Position = [0.5, 0.5, 25, 15];
fig2.PaperType = 'a4';
fig2.PaperOrientation = 'landscape';
hold off
dfigfname = strcat('FeatDistriAllClassesChart', '_', fv_name,'_A4_300dpi');
print(dfigfname,'-dpdf', '-r300');

endtime = datetime('now');
disp(['+++ End - Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
