%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.2r0/2017.09.16
%_application: CTGF Features mapping

clear
clc
dbstop if error

CTGFmap_IncludeConstants;

doc_id = input('Document Identification: ');
frm_id = input('Frame number: ');
rnk_input = input('Rank type (0 to 7): ');
[rnk_str, feat_str] = CTGFmap_Rank_Type(rnk_input);
rnk_type = rnk_input;
n_most = input('Number of most important features to analyze: ');
exp_num = 1;
N_INT = 50;
N_TAIL = 2;
DISTRI_MIN = 0.1;
DISTRI_MAX = 1 - DISTRI_MIN;

diaryfile = strcat('targetdistri', rnk_str, '_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Distribution Charts for Target Document +++');

[~, ~, FVColIds, fv_length, AllClassIds, AllDocIds, ...
    AllFrmIds, DsetPlan, AllFeatVecs, n_vec] = CTGFmap_LoadData();
Classes = sort(unique(AllClassIds));
n_cls = numel(Classes);

rnkfname = strcat('FrmFeatVec_NewRank_', rnk_str, '_Final.csv');
disp(['*** Reading Features Rank from file: ', rnkfname, ' ***']);
AllRank = csvread(rnkfname);
[nr_rnk, nc_rnk] = size(AllRank);
if (nr_rnk ~= n_cls) || (nc_rnk ~= fv_length)
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
    AllFeatVecs(:, i) = AllFeatVecs(:, i) .* MaxXval(i);
    XdvgVal(:, i) = XdvgVal(:, i) .* MaxXval(i);
end

SelDocFrm = AllDocIds == doc_id & AllFrmIds == frm_id;

if sum(SelDocFrm) ~= 1
    error('!!!Error: Invalid Document Id or Frame number!');
end

cls = AllClassIds(SelDocFrm);

disp(['*** Build Distribution chart of ', num2str(n_most), ...
    ' most important features of class ', num2str(cls), ...
    ' for document ', num2str(doc_id), ...
    ' frame number ', num2str(frm_id), ...
    ' - ', datestr(now), ' ***']);

[FeatVecs, BinClassIds, ~, ~, ~, ~] = CTGFmap_SelectExpVectors(cls, ...
    C_EXP_TRAINVAL, DsetPlan(:, exp_num), AllFeatVecs, AllClassIds, ...
    AllDocIds, AllFrmIds);

for rnk = 1:n_most
    if rnk <= max(AllRank(cls, :))
        
        fv_idx = find(AllRank(cls, :) == rnk,1,'first');
        fv_name = FVColIds{fv_idx};
        fv_xval = AllFeatVecs(SelDocFrm, fv_idx);
        
        disp(['--- Document: ', num2str(doc_id), ...
            ', frame number: ', num2str(frm_id), ...
            ', class: ', num2str(frm_id), ...
            ', feature rank: ', num2str(rnk), ...
            ', feature index: ', num2str(fv_idx), ...
            ', feature name: ', fv_name, ...
            ', frame feature value: ', num2str(fv_xval), ...
            ' ---']);
        
        FV_class = FeatVecs(BinClassIds == C_CLASS_POSITIVE, fv_idx);
        nfvcls = numel(FV_class);
        FV_other = FeatVecs(BinClassIds == C_CLASS_NEGATIVE, fv_idx);
        nfvoth = numel(FV_other);
        X_values = sort(unique([FV_class(:)', FV_other(:)']));
        n_x = numel(X_values);
        CDF_cls = zeros(1, n_x);
        CDF_oth = zeros(1, n_x);
        for i = 1:n_x
            CDF_cls(i) = sum(FV_class(:) <= X_values(i)) ./ nfvcls;
            CDF_oth(i) = sum(FV_other(:) <= X_values(i)) ./ nfvoth;
        end
        disp(['    class num. of vectors .....: ', num2str(nfvcls)]);
        disp(['    others num. of vectors ....: ', num2str(nfvoth)]);
        disp(['    X max normalization value .: ', num2str(MaxXval(fv_idx))]);
        rnk_divg = DivgVal(cls, fv_idx);
        rnk_xdvg = XdvgVal(cls, fv_idx);
        disp(['    Rank divg=', num2str(rnk_divg), ...
            ', Rank xdvg=', num2str(rnk_xdvg)]);
        i_x1 = find(CDF_cls >= DISTRI_MIN | CDF_oth >= DISTRI_MIN, 1, 'first');
        i_xn = find(CDF_cls <= DISTRI_MAX | CDF_oth <= DISTRI_MAX, 1, 'last');
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
        ItvPos = CDF_cls < CDF_oth & X_values >= rnk_xdvg;
        x1pos = X_values(find(ItvPos>0, 1, 'first'));
        xnpos = X_values(find(ItvPos>0, 1, 'last'));
        if isnan(x1pos)
            x1pos = 1;
            xnpos = X_values(end);
        elseif x1pos == xnpos
            xnpos = X_values(end);
        end
        
        fig1 = figure;
        hoth = histogram(FV_other, Xedges);
        hoth.Normalization = 'probability';
        hoth.FaceColor = [1 0 0];
        hothmax = max(hoth.Values);
        hold on
        hcls = histogram(FV_class, Xedges);
        hcls.Normalization = 'probability';
        hcls.FaceColor = [0 0 1];
        hclsmax = max(hcls.Values);
        ymax = max(hothmax, hclsmax)* 1.1;
        ymax = round(ymax, floor(-log10(ymax)) + 2);
        pdvg = plot([rnk_xdvg,rnk_xdvg], [0,ymax], '-.g');
        pdvg.LineWidth = 1.5;
        if fv_xval < xn
            x_feat = fv_xval;
        else
            x_feat = xn;
        end
        px = plot([x_feat,x_feat], [0,ymax], '-k');
        px.LineWidth = 2;
        tit_1 = ['Feature ', fv_name, ' of document id: ', num2str(doc_id), ...
            ', frame: ', num2str(frm_id), ', value = ', num2str(fv_xval)];
        tit_2 = ['Class: ', num2str(cls), ' - Feature: ', fv_name,  ...
            ' - #', num2str(rnk), ' most important ', feat_str];
        title({tit_1, tit_2})
        xlabel('feature value intervals')
        ylabel('probability to find a sample on the interval')
        xlim([x1 xn]);
        ylim([0 ymax]);
        ax1 = gca;
        ax1.TickDir = 'out';
        ax1.FontSize = 14;
        lgd1 = legend('other classes', 'class',  'Max. cross diff.', ...
            'document''s feature value', 'Location', 'northwest');
        lgd1.FontSize = 12;
        fig1.Units = 'centimeters';
        fig1.Position = [0.5, 0.5, 25, 15];
        fig1.PaperType = 'a4';
        fig1.PaperOrientation = 'landscape';
        hold off
        dfigfname = strcat('FeatTargetDistri_D', num2str(doc_id), ...
            '_F', num2str(frm_id), ...
            '_C', num2str(cls), ...
            '_', feat_str(1:3), '_R', num2str(rnk), '_', fv_name,'_A4_300dpi');
        print(dfigfname,'-dpdf', '-r300');
        
        disp(['    x_min .....................: ', num2str(X_values(1))]);
        disp(['    x_max .....................: ', num2str(X_values(end))]);
        disp(['    positive interval min .....: ', num2str(x1pos)]);
        disp(['    positive interval max .....: ', num2str(xnpos)]);
        disp(['    histogram x_min ...........: ', num2str(Xedges(1))]);
        disp(['    histogram x_max ...........: ', num2str(Xedges(n_edges))]);
        disp(['    histogram x_step ..........: ', num2str(xstep)]);
        disp(['    histogram y_max  ..........: ', num2str(ymax)]);
        disp(['    histogram y_max_cls  ......: ', num2str(hclsmax)]);
        disp(['    histogram y_max_oth  ......: ', num2str(hothmax)]);
        disp('-------- LaTex line -------');
        disp(['			', num2str(cls), ...
            ' & ', num2str(rnk), ...
            ' & ', fv_name, ...
            ' & ', num2str(rnk_xdvg), ...
            ' & ', num2str(rnk_divg), ...
            ' \\', ...
            ]);
    else
        disp(['!Warning: Most important ', num2str(rnk), ...
            ' ', feat_str, ' feature of class ', ...
            num2str(cls), ' does not exist!']);
    end
end

close all

endtime = datetime('now');
disp(['+++ End - Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
