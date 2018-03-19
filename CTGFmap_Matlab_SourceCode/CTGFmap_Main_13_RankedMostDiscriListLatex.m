%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.3r0/2017.10.08
%_application: CTGF Features mapping

clear
clc
dbstop if error

CTGFmap_IncludeConstants;

rnk_input = input('Rank type (0 to 7): ');
[rnk_str, feat_str] = CTGFmap_Rank_Type(rnk_input);
rnk_type = rnk_input;
n_most = input('Number of most important features to analyze: ');
exp_num = 1;

diaryfile = strcat('mostdiscrlatex', rnk_str, '_N', num2str(n_most), '_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp(['+++ Most important ', feat_str, ' features +++']);

[FVColIds, fv_length] = CTGFmap_LoadFeatureIds();

idsfname = strcat('ImgClassIds.csv');
disp(['*** Reading Classes from file: ', idsfname, ' ***']);
ImgClsIds = csvread(idsfname);
Classes = sort(unique(ImgClsIds(:, C_IMGID_CLASS_ID)));
n_cls = numel(Classes);

rnkfname = strcat('FrmFeatVec_NewRank_', rnk_str, '_Final.csv');
disp(['*** Reading Features Rank from file: ', rnkfname, ' ***']);
AllRank = csvread(rnkfname);
[nr_rnk, nc_rnk] = size(AllRank);
if nr_rnk ~= n_cls || nc_rnk ~= fv_length 
    error('!!! Error: Rank and Feature vectors do not match!');
end

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
disp('*** Denormalizing Feature Vectors to show actual feature values distribution ***');
for i = 1:fv_length
    XdvgVal(:, i) = XdvgVal(:, i) .* MaxXval(i);
end

FeatList = zeros(1, n_cls * n_most);
FeatMat = zeros(n_cls, n_most);
n_ftr = 0;

disp('*** Latex most discriminant features table ***');
disp(' ');
disp('\begin{table}[!ht]');
disp('	%\renewcommand{\arraystretch}{1.2}');
disp(['	\caption{... most discriminant features of each printer and ', ...
    'their location. The two samples KS\_test of all those features ', ...
    'rejected null hypothesis with \textit{p values} equal to 1.', ...
    '\label{tab:mostdiscri}}']);
disp('	\begin{center}');
disp('		\begin{tabular}{|c|c|c|c|c|c|c|c|}');
disp('			\hline');
disp(['			& & & & &\textbf{Inside} & \multicolumn{2}{|c|}', ...
    '{\textbf{Outside body}} \\']);
disp('			\cline{7-8}');
disp(['			\textbf{Class} & \textbf{Rank} & \textbf{Feature} ', ...
    '& \textbf{$\cutpoint$} & \textbf{$D(\cutpoint)\ \%$} & ', ...
    '\textbf{body} & \textbf{near} & \textbf{far from} \\']);
disp(['			& & & & & \textbf{ROI 1} & \textbf{border ROI 2} & ', ...
    '\textbf{border ROI 3} \\']);
disp('			\hline');

for cls = 1:n_cls
    for rnk = 1:n_most
        if rnk <= max(AllRank(cls, :))
            fv_idx = find(AllRank(cls, :) == rnk,1,'first');
            fv_name = FVColIds{fv_idx};
            fv_name = strcat(strrep(fv_name,'X','X_{'), '}');
            rnk_divg = DivgVal(cls, fv_idx);
            rnk_xdvg = XdvgVal(cls, fv_idx);
            disp(['			', num2str(Classes(cls)), ...
                ' & ', num2str(rnk), ...
                ' & $', fv_name, ...
                '$ & ', sprintf('%0.2e', rnk_xdvg), ...
                ' & ', num2str(round(rnk_divg*100, 1)), ...
                ' & YesNoFewMany & YesNoFewMany & YesNoFewMany \\', ...
                ]);
            FeatMat(cls, rnk) = fv_idx;
            n_ftr = n_ftr + 1;
            FeatList(n_ftr) = fv_idx;
        end
    end
    disp('			\hline');
end
disp('		\end{tabular}');
disp('	\end{center}');
disp('\end{table}');
disp(' ');

disp('*** Most important features list (ordered by class) ***');
disp(' ');
for cls = 1:n_cls
    for rnk = 1:n_most
        if rnk <= max(AllRank(cls, :))
        fv_idx = FeatMat(cls, rnk);
        fv_name = FVColIds{fv_idx};
        rnk_divg = DivgVal(cls, fv_idx);
        rnk_xdvg = XdvgVal(cls, fv_idx);
        disp(['Class: ', num2str(Classes(cls)), ...
            ', rank: ', num2str(rnk), ...
            ', fv_name: ', fv_name, ...
            ', xdvg: ', sprintf('%0.2e', rnk_xdvg), ...
            ', divg: ', num2str(round(rnk_divg*100, 1))]);
        else
            disp(['!Warning: Most important ', num2str(rnk), ...
                ' ', feat_str, ' feature of class ', ...
                num2str(Classes(cls)), ' does not exist!']);
        end
    end
end
disp(' ');

disp('*** Most important features list (ordered by feature) ***');
if n_ftr < (n_cls * n_most)
    FeatList(n_ftr+1:end) = [];
end
n_ftr = numel(FeatList);
UniFeat = unique(FeatList);
nuni = numel(UniFeat);
if n_ftr ~= nuni
    disp(['!Warning: There are ', num2str(n_ftr - nuni), ...
        ' repeated most important!']);
end
for i = 1:nuni
    ndup = sum(FeatList == UniFeat(i));
    SelCls = sum(FeatMat == UniFeat(i), 2);
    ClassesOfX = find(SelCls > 0);
    Linestr = strcat('Feature: ', FVColIds{UniFeat(i)}, ...
        ', number of classes: ', num2str(ndup), ', classes: ');
    for j = 1:numel(ClassesOfX)
        if j > 1
            Linestr = strcat(Linestr, ',');
        end
        Linestr = strcat(Linestr, num2str(ClassesOfX(j)));
    end
    disp(Linestr);
end
disp(' ');

endtime = datetime('now');
disp(['+++ End - Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
