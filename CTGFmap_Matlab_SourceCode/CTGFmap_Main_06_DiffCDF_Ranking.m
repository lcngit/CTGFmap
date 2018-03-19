%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

clear
clc
dbstop if error

CTGFmap_IncludeConstants;
exp_num  = 1;
MIN_DISTRI_PERC = 0.05;

diaryfile = strcat('divgranking_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);
initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Ranking features based on CDFs difference +++');

loadfname = 'FrmFeatVec_CrossCDFdiff.mat';
disp(['*** Loadin cross classes CDFs difference to file: ', loadfname,  ...
    ' - ', datestr(now), ' ***']);
ClassesDivg = [];
load(loadfname, 'ClassesDivg');
disp(['*** Cross classes CDFs difference loaded from file: ', loadfname,  ...
    ' - ', datestr(now), ' ***']);

[~, ~, ~, fv_length, AllClassIds, AllDocIds, ...
    AllFrmIds, DsetPlan, AllFeatVecs, n_vec] = CTGFmap_LoadData();
Classes = sort(unique(AllClassIds));
n_cls = numel(Classes);

FinalXmax = zeros(1, fv_length);

disp(['*** Begin - Computing maximum feature value for each ', ...
    'feature - ', datestr(now), ' ***']);

for fv_idx = 1:fv_length
    x_max = -1;
    c1_max = 0;
    c2_max = 0;
    for c1 = 1:n_cls
        for c2 = 1:n_cls
            if ClassesDivg(c1, c2, fv_idx, CROSSDVG_XDVG) > x_max
                c1_max = c1;
                c2_max = c2;
                x_max = ClassesDivg(c1_max, c2_max, fv_idx, CROSSDVG_XDVG);
            end
        end
    end
    FinalXmax(fv_idx) = ClassesDivg(c1_max, c2_max, fv_idx, CROSSDVG_XDVG);
end

disp(['*** End - Computing maximum feature value for each ', ...
    'feature - ', datestr(now), ' ***']);
disp(' ');

disp(['*** Begin - Computing divergence at maximum feature value ', ...
    'for each class - ', datestr(now), ' ***']);

FinalDivg = zeros(n_cls, fv_length);
FinalXdvg = zeros(n_cls, fv_length);

for cls = 1:n_cls
    cls_id = Classes(cls);
    
    [FeatVecs, BinClassIds, ~, ~, ~, ~] = CTGFmap_SelectTwoClassesVectors( ...
        cls_id, 0, C_EXP_TRAINVAL, DsetPlan(:, exp_num), AllFeatVecs, AllClassIds, ...
        AllDocIds, AllFrmIds);
    
    SelPos = BinClassIds == C_CLASS_POSITIVE;
    FV_Pos = FeatVecs(SelPos, :);
    nfvpos = sum(SelPos);
    SelNeg = BinClassIds == C_CLASS_NEGATIVE;
    FV_Neg = FeatVecs(SelNeg, :);
    nfvneg = sum(SelNeg);
    
    for fv_idx = 1:fv_length
        xmax = FinalXmax(fv_idx);
        SelXdvg = FeatVecs(:, fv_idx) >= xmax;
        FV_cls = FeatVecs(SelPos & SelXdvg, fv_idx);
        nfvcls = numel(FV_cls);
        FV_oth = FeatVecs(SelNeg & SelXdvg, fv_idx);
        nfvoth = numel(FV_oth);
            cdf_cls = nfvcls / nfvpos;
            cdf_oth = nfvoth / nfvneg;
            cdf_dif = cdf_cls - cdf_oth;
        if (xmax == 0) || (abs(cdf_dif) < MIN_DISTRI_PERC)
            FinalDivg(cls, fv_idx) = 0;
            FinalXdvg(cls, fv_idx) = 0;
        else
           [~, ~, ks_h, ~, ~] = CTGFmap_MaxCDFdiff(FV_Pos(:, fv_idx), ...
                FV_Neg(:, fv_idx));
            if ks_h == 0
                FinalDivg(cls, fv_idx) = 0;
                FinalXdvg(cls, fv_idx) = 0;
            else
                FinalDivg(cls, fv_idx) = cdf_dif;
                FinalXdvg(cls, fv_idx) = xmax;
            end
        end
    end
    ct_pos = sum(FinalDivg(cls, :) > 0);
    ct_neg = sum(FinalDivg(cls, :) < 0);
    disp(['--- Class: ', num2str(cls_id), ...
        ', Features: ', num2str(fv_length), ...
        ', Positives: ', num2str(ct_pos), ...
        ', Zeros: ', num2str(fv_length - ct_pos - ct_neg), ...
        ', Negatives: ', num2str(ct_neg),  ...
        ' - ', datestr(now), ' ---']);
end

disp(['*** Begin - Computing divergence at maximum feature value ', ...
    'for each class - ', datestr(now), ' ***']);

disp(' ');

outfname = strcat('FrmFeatVec_Xdvg.csv');
dlmwrite(outfname, FinalXdvg, 'delimiter', ',', 'precision', 12);
disp(['*** Class Feature value on divergence point saved into file: ', outfname, ' ***']);

outfname = strcat('FrmFeatVec_Divg.csv');
dlmwrite(outfname, FinalDivg, 'delimiter', ',', 'precision', 12);
disp(['*** Class Feature divergence saved into file: ', outfname, ' ***']);

disp(['=== Begin - Ranking Features for all classes - ', datestr(now), ' +++']);

KeepVecs = true(n_cls, fv_length);
ClassAbsDivg = abs(FinalDivg);
CTGFmap_Rank_ClassesImp(KeepVecs, ClassAbsDivg, Classes, RNK_ALL_DVGSUP);

KeepVecs = FinalDivg > 0;
ClassPosDivg = ClassAbsDivg;
ClassPosDivg(KeepVecs == 0) = 0;
CTGFmap_Rank_ClassesImp(KeepVecs, ClassPosDivg, Classes, RNK_POS_DVGSUP);

KeepVecs = FinalDivg < 0;
ClassNegDivg = ClassAbsDivg;
ClassNegDivg(KeepVecs == 0) = 0;
CTGFmap_Rank_ClassesImp(KeepVecs, ClassNegDivg, Classes, RNK_NEG_DVGSUP);

disp(['=== End - Ranking Features for all classes - ', datestr(now), ' ===']);

endtime = datetime('now');
disp(['+++ End - Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
