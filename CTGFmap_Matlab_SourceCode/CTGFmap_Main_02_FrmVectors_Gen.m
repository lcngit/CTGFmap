%_author: Luiz Claudio Navarro (student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.04
%_application: CTGF Features mapping

clear
clc
dbstop if error

CTGFmap_IncludeConstants;
basefname = 'FrameMetrics_C';
C_WHITE_THSR = 0.99;
C_WHITE_STDV = 0.8;

planfname = input('Dataset plan config file: ', 's');
frmtype = 0;
while frmtype < FRM_TYPE_TXT || frmtype > FRM_TYPE_ALL
    frmtype = input('Frame type (1=txt, 2=fig, 3=all): ');
end
if frmtype == FRM_TYPE_TXT
    frmsuf = '_txt';
elseif frmtype == FRM_TYPE_FIG
    frmsuf = '_fig';
elseif frmtype == FRM_TYPE_ALL
    frmsuf = '_all';
else
    error('Invalid frame type!');
end

diaryfile = strcat('frm', frmsuf, '_vecgen_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);
initime = datetime('now');
disp ('*** Begin - Converting Frame Feature Vectors according Dataset Plan ***');
disp (['*** ', datestr(initime), ' ***'])

disp (['Reading Datasets Experiments Plan File = ', planfname]);
DsetPlan = csvread(planfname, 0, 1);
[nr_cfg, ~] = size(DsetPlan);

if (frmtype == FRM_TYPE_TXT) || (frmtype == FRM_TYPE_FIG)
    kpfname = strcat('KeepFrames', frmsuf, '.csv');
    disp(['Reading Keep figures file: ', kpfname]);
    KeepRec = csvread(kpfname);
    KeepDoc = KeepRec(:,1);
    KeepFrm = KeepRec(:,2:end);
    [~, nkeep] = size(KeepFrm);
end

alocfrms = max(DsetPlan(:,C_DSETPLAN_NFRMS)) * nr_cfg;
nfrms = sum(DsetPlan(:,C_DSETPLAN_NFRMS));
Classes = sort(unique(DsetPlan(:,C_DSETPLAN_CLASS)));
n_cls = numel(Classes);
disp (['Number of frames on the plan  = ', num2str(nfrms)]);
disp (['Number of classes on the plan = ', num2str(n_cls)]);
disp (['Maximum number of frames for allocation  = ', num2str(alocfrms)]);

frmfname = strcat(basefname,'1.csv');
disp (['Getting Feature Vector Length from file = ', frmfname]);
FvszFeatVec = dlmread(frmfname,',',[1 0 2 C_H_FILTCONV+1]);
fv_length = FvszFeatVec(1, C_H_FILTCONV);
disp (['Feature Vector length = ', num2str(fv_length)]);
clearvars FvszFeatVec

FrmVec = zeros(alocfrms+10, (C_FRMVEC_LENGTH + fv_length));
[ifrm, nfrm, tot_f] = deal(0);

cls = 0;
for ipl = 1:nr_cfg
    
    if DsetPlan(ipl,C_DSETPLAN_CLASS) ~= cls % DSetPlan should be class sorted
        
        cls = DsetPlan(ipl,C_DSETPLAN_CLASS);
        fmtrfname = strcat(basefname, num2str(cls), '.csv');
        disp (['*** Class = ', num2str(cls), ' ***']);
        disp (['    Reading Frame Feature Vectors File = ', fmtrfname]);
        FrmMetrics = csvread(fmtrfname);
        
        % Eliminate blank frames for all types
        Npix    = FrmMetrics(:, C_I_NR) .* FrmMetrics(:, C_I_NR);
        Nwht    = FrmMetrics(:, C_I_NWHITE) ./ Npix;
        thrNwht = mean(Nwht) + (std(Nwht) * C_WHITE_STDV);
        if thrNwht > C_WHITE_THSR
            thrNwht = C_WHITE_THSR;
        end
        disp(['    Class: ', num2str(cls), ...
            ' white threshold for discarding blank frames = ', ...
            num2str(thrNwht*100), ' %']);
        SelWht  = Nwht > thrNwht;
        FrmMetrics(SelWht, :) = [];
        
        % Select frames according required frame type
        maxfrms = max(FrmMetrics(:, C_FRM_NUM));
        if frmtype == FRM_TYPE_TXT
            Docs = sort(unique(FrmMetrics(:, C_DOC_ID)));
            n_d = numel(Docs);
            for i = 1:n_d
                doc = Docs(i);
                SelDoc = FrmMetrics(:, C_DOC_ID) == doc;
                Keep = KeepFrm(KeepDoc == doc, :);
                if ~isempty(Keep)
                    Frms = sort(FrmMetrics(SelDoc, C_FRM_NUM));
                    n_f = numel(Frms);
                    for j = 1:n_f
                        frm = Frms(j);
                        if Keep(frm) ~= 0
                            SelFrm = SelDoc & FrmMetrics(:, C_FRM_NUM) == frm;
                            SelDoc(SelFrm) = false;
                        end
                    end
                end
                FrmMetrics(SelDoc, :) = [];
            end
        elseif frmtype == FRM_TYPE_FIG
            SelPict = FrmMetrics(:,C_DOC_PICT) ~= 0;
            FrmMetrics(SelPict, :) = [];
            Docs = sort(unique(FrmMetrics(:, C_DOC_ID)));
            n_d = numel(Docs);
            for i = 1:n_d
                doc = Docs(i);
                SelDoc = FrmMetrics(:, C_DOC_ID) == doc;
                Keep = KeepFrm(KeepDoc == doc, :);
                if ~isempty(Keep)
                    Frms = sort(FrmMetrics(SelDoc, C_FRM_NUM));
                    n_f = numel(Frms);
                    for j = 1:n_f
                        frm = Frms(j);
                        if Keep(frm) ~= 0
                            SelFrm = SelDoc & FrmMetrics(:, C_FRM_NUM) == frm;
                            SelDoc(SelFrm) = false;
                        end
                    end
                end
                FrmMetrics(SelDoc, :) = [];
            end
        end
        
        % Discard documents with few frames
        Docs = unique(FrmMetrics(:, C_DOC_ID));
        for dc = Docs'
            SelDoc = FrmMetrics(:, C_DOC_ID) == dc;
            if sum(SelDoc) < floor(0.1 * maxfrms)
                FrmMetrics(SelDoc, :) = [];
            end
        end
        
        % Process remaining frames
        [nrfmtr, ncfmtr] = size(FrmMetrics);
        if sum(FrmMetrics(:, C_H_FILTCONV) == fv_length) ~= nrfmtr
            error('!!!Error: Filtconv length is not fv_length!');
        end
        tot_f = tot_f + nrfmtr;
        n_docs = numel(unique(FrmMetrics(:, C_DOC_ID)));
        disp (['    Number of documents for the class ... = ', num2str(n_docs)]);
        disp (['    Number of frame metrics for the class = ', num2str(nrfmtr)]);
        ifrm = nfrm + 1;
        nfrm = ifrm + nrfmtr - 1;
        FrmVec(ifrm:nfrm, C_FRMVEC_CLASS) = FrmMetrics(:, C_CLASS_ID);
        FrmVec(ifrm:nfrm, C_FRMVEC_DOCID) = FrmMetrics(:, C_DOC_ID);
        FrmVec(ifrm:nfrm, C_FRMVEC_DOCGROUP) = FrmMetrics(:, C_DOC_GROUP);
        FrmVec(ifrm:nfrm, C_FRMVEC_FRMID) = FrmMetrics(:, C_FRM_NUM);
        FrmVec(ifrm:nfrm, C_FRMVEC_IROW) = FrmMetrics(:, C_FRM_IROW) + ...
            FrmMetrics(:, C_BORDER_UP);
        FrmVec(ifrm:nfrm, C_FRMVEC_FROW) = FrmMetrics(:, C_FRM_FROW) + ...
            FrmMetrics(:, C_BORDER_UP);
        FrmVec(ifrm:nfrm, C_FRMVEC_ICOL) = FrmMetrics(:, C_FRM_ICOL) + ...
            FrmMetrics(:, C_BORDER_LEFT);
        FrmVec(ifrm:nfrm, C_FRMVEC_FCOL) = FrmMetrics(:, C_FRM_FCOL) + ...
            FrmMetrics(:, C_BORDER_LEFT);
        FrmVec(ifrm:nfrm, C_FRMVEC_FVEC:end) = FrmMetrics(:,(ncfmtr-fv_length+1):end);
    end
    
    docid = DsetPlan(ipl, C_DSETPLAN_DOCID);
    SelDocId = FrmVec(:, C_FRMVEC_DOCID) == docid;
    ndocfrms = sum(SelDocId);
    if FrmVec(SelDocId, C_FRMVEC_DOCGROUP) ~= DsetPlan(ipl, C_DSETPLAN_DOCGROUP)
        error(['!!!Error: Doc Group of frames for document ', num2str(docid), ...
            ' does not match Dataset Plan!']);
    end
    
    FrmVec(SelDocId, C_FRMVEC_EXP_GROUP) = DsetPlan(ipl, C_DSETPLAN_EXP_GROUP);
    for i = 0:C_NUM_OF_EXP-1
        FrmVec(SelDocId, C_FRMVEC_EXP + i) = DsetPlan(ipl, C_DSETPLAN_EXP + i);
    end
    
end

FrmVec(FrmVec(:, C_FRMVEC_EXP) == 0,:) = [];
[nfr, nfc] = size(FrmVec);
if nfc ~= (C_FRMVEC_LENGTH + fv_length)
    error('!!!Error: Frame Feature Vectors wrong length!');
end
disp (['Total frame vectors read ', num2str(tot_f)]);
disp (['Total frame vectors converted ', num2str(nfr)]);

disp(' ');
disp('*** Save Normalization Values Vector and Normalized Feature Ids ***');
MaxFeatureVal = max(FrmVec(:, C_FRMVEC_FVEC:end));
MinFeatureVal = min(FrmVec(:, C_FRMVEC_FVEC:end));
ThrsFeatureVal = sum(FrmVec(:, C_FRMVEC_FVEC:end) >= MIN_TEXTURE_FREQ) ./ nfr;
KeepVec = (MaxFeatureVal >= MIN_TEXTURE_FREQ) & ...
    (MaxFeatureVal ~= MinFeatureVal) & ...
    (ThrsFeatureVal >= MIN_TEXTURE_PERC);
maxfname = strcat('FrmFeatVec_Max', frmsuf, '.csv');
disp (['    Writing Maximum Feature Values (for normalization) on file ', maxfname]);
dlmwrite(maxfname, MaxFeatureVal, 'delimiter', ',', 'precision', 12);
disp (['    Number of columns max ..........: ', num2str(numel(MaxFeatureVal))]);
keepfname = strcat('FrmFeatVec_Keep', frmsuf, '.csv');
disp (['    Writing Initial Keep Vector on file ', keepfname]);
dlmwrite(keepfname, KeepVec, 'delimiter', ',', 'precision', 12);
disp (['    Number of features considered ..: ', num2str(sum(KeepVec))]);

AllIds = 0:(fv_length-1);
FeatureIds = AllIds(KeepVec);
fvidfname = strcat('FrmFeatVec_Ids', frmsuf, '.csv');
disp (['    Writing Feature Ids on file ', fvidfname]);
dlmwrite(fvidfname, FeatureIds, 'delimiter', ',', 'precision', 12);
disp (['    Number of column Ids: ', num2str(numel(FeatureIds))]);

AuxVecs = zeros(nfr, fv_length);
for i = 1:fv_length
    if MaxFeatureVal(i) ~= 0
        AuxVecs(:, i) = FrmVec(:, C_FRMVEC_FVEC + i - 1) ./ MaxFeatureVal(i);
    end
end
NormVecs = AuxVecs(:, KeepVec);
[nr_norm, fv_norm_length] = size(NormVecs);
FrmFeatVec = horzcat(FrmVec(:, 1 : C_FRMVEC_LENGTH), NormVecs);

fvfname = strcat('FrmFeatVec_All', frmsuf, '.csv');
[nr_vec, nc_vec] = size(FrmFeatVec);
disp ('*** Normalized Frame Feature Vectors ***');
disp (['    Number of vectors ....: ', num2str(nr_vec)]);
disp (['    Number of columns ....: ', num2str(nc_vec)]);
disp (['    Header columns .......: ', num2str(C_FRMVEC_LENGTH)]);
disp (['    Normalized feature vector length: ', num2str(fv_norm_length)]);
disp (['    Writing Normalize Frame Feature Vectors on file ', fvfname]);
dlmwrite(fvfname, FrmFeatVec, 'delimiter', ',', 'precision', 12);
disp (['    File writen ', num2str(nfr), ' records']);

if nr_vec ~= nr_norm || nr_vec ~= nfr
    error('!!!Error: Invalid number of vectors!');
end
if sum(round(max(FrmFeatVec(:, C_FRMVEC_FVEC:end)), 6)) ~= fv_norm_length
    error('!!!Invalid normalized feature vectors!');
end

endtime = datetime('now');
disp ('*** End - Converting Frame Feature Vectors according new Dataset Plan ***');
disp (['*** End processing - ', datestr(endtime), ' ***'])
disp (['    Initial time: ', datestr(initime)]);
disp (['    End time ...: ', datestr(endtime)]);

diary('off')
