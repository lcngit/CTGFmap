%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

clear
clc
dbstop if error
dispall = false;    % set true for debug, true displays all features data

CTGFmap_IncludeConstants;
exp_num  = 1;
diaryfile = strcat('crossdivg_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);
initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Features distribution divergence analisys +++');

[~, ~, ~, fv_length, AllClassIds, AllDocIds, ...
    AllFrmIds, DsetPlan, AllFeatVecs, n_vec] = CTGFmap_LoadData();
Classes = sort(unique(AllClassIds));
n_cls = numel(Classes);

disp(['=== Begin - Computing Distributions Divergence of Features ', ...
    'for all pairs of classes - ', datestr(now), ' ===']);

ClassesDivg = zeros(n_cls, n_cls, fv_length, CROSSDVG_LENGTH);

for cls_1 = 1:(n_cls - 1)
    cls_1_id = Classes(cls_1);
    for cls_2 = (cls_1+1):n_cls
        cls_2_id = Classes(cls_2);
        
        disp(['*** Computing Distributions Divergence for class: ', ...
            num2str(cls_1_id), ' against class:', num2str(cls_2_id), ...
            ' - ', datestr(now), ' ***']);
        
        [FeatVecs, BinClassIds, ~, ~, ~, ~] = ...
            CTGFmap_SelectTwoClassesVectors(cls_1_id, cls_2_id, ...
            C_EXP_TRAINVAL, DsetPlan(:, exp_num), AllFeatVecs, ...
            AllClassIds, AllDocIds, AllFrmIds);
        
        ct_pos = 0;
        ct_neg = 0;
        SelPos = BinClassIds == C_CLASS_POSITIVE;
        nfvpos = sum(SelPos);
        SelNeg = BinClassIds == C_CLASS_NEGATIVE;
        nfvneg = sum(SelNeg);
        
        for fv_idx = 1:fv_length
            FV_Pos = FeatVecs(SelPos, fv_idx);
            FV_Neg = FeatVecs(SelNeg, fv_idx);
            [xdvg, divg, ks_h, ks_p, ks_k] = CTGFmap_MaxCDFdiff(FV_Pos, FV_Neg);
            if divg > 0
                ct_pos = ct_pos + 1;
            elseif divg < 0
                ct_neg = ct_neg + 1;
            else
                divg = 0;
                xdvg = 0;
            end
            ClassesDivg(cls_1, cls_2, fv_idx, :) = [xdvg, divg, ks_h, ks_p, ks_k];
            ClassesDivg(cls_2, cls_1, fv_idx, :) = [xdvg, -divg, ks_h, ks_p, ks_k];
            if dispall
                disp(['    Class 1: ', num2str(cls_1_id), ...
                    ' (', num2str(nfvpos), ')', ...
                    ', Class 2: ', num2str(cls_2_id), ...
                    ' (', num2str(nfvneg), ')', ...
                    ', feature: ', num2str(fv_idx), ...
                    ', divg=', num2str(divg), ...
                    ', xdvg=', num2str(xdvg), ...
                    ', ks_h=', num2str(ks_h), ...
                    ', ks_p=', num2str(ks_p), ...
                    ', ks_k=', num2str(ks_k), ...
                    ]); %#ok<UNRCH>
            end
        end
        
        disp(['    Class 1: ', num2str(cls_1_id), ...
            ' (', num2str(nfvpos), ')', ...
            ', Class 2: ', num2str(cls_2_id), ...
            ' (', num2str(nfvneg), ')', ...
            ', features evaluated: ', num2str(fv_length), ...
            ', Positives: ', num2str(ct_pos), ...
            ', Zeros: ', num2str(fv_length - ct_pos - ct_neg), ...
            ', Negatives: ', num2str(ct_neg)]);
        
    end
end

disp(['=== End - Computing Distributions Divergence of Features ', ...
    'for all pairs of classes - ', datestr(now), ' ===']);
disp(' ');

outfname = 'FrmFeatVec_CrossCDFdiff.mat';
disp(['*** Saving cross classes CDFs difference to file: ', outfname,  ...
    ' - ', datestr(now), ' ***']);
save(outfname, 'ClassesDivg');
disp(['*** Cross classes CDFs difference saved on file: ', outfname,  ...
    ' - ', datestr(now), ' ***']);

endtime = datetime('now');
disp(['+++ End - Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
