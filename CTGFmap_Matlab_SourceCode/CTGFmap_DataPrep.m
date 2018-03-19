%_author: Luiz Claudio Navarro (student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.5r0/2017.09.22
%_application: CTGF Features mapping

function CTGFmap_DataPrep(numcolor, glow, ghigh, nfrm_x, nfrm_y, ...
    nmatconv, dirtif, cfgfile)

CTGFmap_IncludeConstants;

C_FNAME_PRT   = 4;
C_FNAME_COLOR = C_FNAME_PRT + 1;
C_FNAME_LANG  = C_FNAME_COLOR + 1;
C_FNAME_PICT  = C_FNAME_LANG + 1;
C_FNAME_INUM  = C_FNAME_PICT + 1;
C_FNAME_FNUM  = C_FNAME_INUM + 1;
C_FNAME_EXT   = C_FNAME_FNUM + 1;
C_FNAME_LEN   = C_FNAME_EXT  + 3;

% Read from config file the image file names and identifications
disp (['Loading data set plan from config file = ', cfgfile]);
DsetPlan = csvread(cfgfile,0,1);
[nr_cfg, ~] = size(DsetPlan);
disp (['Loading image names from config file = ', cfgfile]);
ImgName = strings(nr_cfg, 1);
ndocs = 0;
fidcfg = fopen(cfgfile,'r');
cfgline = fgetl(fidcfg);
while ischar(cfgline)
    ndocs = ndocs + 1;
    ImgName(ndocs, :) = cfgline(1:C_FNAME_LEN);
    cfgline = fgetl(fidcfg);
end
fclose(fidcfg);
if nr_cfg ~= ndocs
    error('!!!!!! Image file names does not match with dataset plans!');
end
if numcolor ~= C_PAPERCOLOR_ALL
    disp (['Selecting only files with paper color ', num2str(numcolor)]);
    PaperColor = floor(DsetPlan(:, C_DSETPLAN_DOCID) ./ C_DSETPLAN_COLOR_ID);
    SelDifColor = PaperColor ~= numcolor;
    ImgName(SelDifColor, :) = [];
    DsetPlan(SelDifColor, :)   = [];
else
    disp ('All paper colors selected, no filter applied!');
end
[n_files, ~] = size(DsetPlan);
nframes = nfrm_x * nfrm_y * n_files;
ImgClassId = zeros(n_files, C_IMGID_LENGHT);

% Create Convolution Matrix
MatConv = ones(nmatconv, nmatconv);
convmaxv = sum(sum(MatConv * 255));
convsize = convmaxv + 1;

disp (['### Begin Image Metrics generation. Number of files = ', num2str(n_files)]);

% For all image files in the directory generate metrics
clsid_prev = 0;
n_frmscls = 0;
for f = 1 : n_files
    
    % start timer
    tic
    
    % Read image file
    fname = char(ImgName(f));
    fullfname = char(strcat(dirtif,fname));
    imgInfo = imfinfo(fullfname);
    ImgDoc = imread(fullfname);
    
    % Store Printer name and Printer id for the document image
    clsid   = DsetPlan(f, C_DSETPLAN_CLASS);
    doclang = DsetPlan(f, C_DSETPLAN_DOCLANG);
    docpic  = DsetPlan(f, C_DSETPLAN_DOCPICT);
    docnum  = DsetPlan(f, C_DSETPLAN_DOCNUM);
    docid   = DsetPlan(f, C_DSETPLAN_DOCID);
    groupid = DsetPlan(f, C_DSETPLAN_DOCGROUP);
    ImgClassId(f, C_IMGID_CLASS_ID)  = clsid;
    ImgClassId(f, C_IMGID_DOC_LANG)  = doclang;
    ImgClassId(f, C_IMGID_DOC_PICT)  = docpic;
    ImgClassId(f, C_IMGID_DOC_NUM)   = docnum;
    ImgClassId(f, C_IMGID_DOC_ID)    = docid;
    ImgClassId(f, C_IMGID_DOC_GROUP) = groupid;

    % If it is the first printer or printer id changed, then store
    % frames metrics calculated below
    if clsid_prev ~= clsid
        if n_frmscls ~= 0
            FrmMetr (n_frmscls + 1 : end, :)   = [];
            FrmHpix (n_frmscls + 1 : end, :)   = [];
            FrmHgrad (n_frmscls + 1 : end, :)  = [];
            FrmHgradf (n_frmscls + 1 : end, :) = [];
            FrmHconv (n_frmscls + 1 : end, :)  = [];
            FrmHconvf (n_frmscls + 1 : end, :) = [];
            outfname = strcat('FrameMetrics', fsuffix2, '.csv');
            disp (['Printer # = ', num2str(clsid_prev),  ...
                ', n. frames = ', num2str(n_frmscls), ...
                ', file = ', outfname]);
            dlmwrite (outfname, [FrmMetr, FrmHpix, FrmHgrad, ...
                FrmHgradf, FrmHconv, FrmHconvf], ...
                'delimiter', ',', 'precision', 12);
        end
        FrmMetr     = zeros (nframes, C_METRICS);
        FrmHpix     = zeros (nframes, C_NPIX_VAL);
        FrmHgrad    = zeros (nframes, C_NPIX_VAL);
        FrmHgradf   = zeros (nframes, C_NPIX_VAL);
        FrmHconv    = zeros (nframes, convsize);
        FrmHconvf   = zeros (nframes, convsize);
        clsid_prev  = clsid;
        n_frmscls = 0;
        fsuffix2 = strcat('_C',  num2str(clsid));
    end
    
    % Transform image to grayscale and crop borders that may have scanner
    % effects
    [ImgCroped, brd_up, brd_lft] = CTGF_ImgCrop(ImgDoc, imgInfo.BitDepth);
    clearvars Img
    [nr_crpd, nc_crpd] = size(ImgCroped);
    nr_frm = ceil(nr_crpd / nfrm_y);
    nc_frm = ceil(nc_crpd / nfrm_x);
    
    % For all frames in the document, i is a row of frames, j is a column
    % of frames
    n_frms = 0;
    id_frm = 0;
    for i = 1 : nfrm_y
        
        ifrm = ((i - 1) * nr_frm) + 1;
        ffrm = ifrm + nr_frm - 1;
        if ffrm > nr_crpd
            ffrm = nr_crpd;
        end
        
        for j = 1 : nfrm_x
            
            jfrm = ((j - 1) * nc_frm) + 1;
            gfrm = jfrm + nc_frm - 1;
            if gfrm > nc_crpd
                gfrm = nc_crpd;
            end
            
            Frame = ImgCroped (ifrm : ffrm, jfrm : gfrm);
            id_frm = id_frm + 1;
            
            % Compute metrics for the frame
            [Metrics, Hpix, ~, Hgrad, Hgradf, ~, Hconv, Hconvf, ~, ~] = ...
                CTGFmap_FrameMetrics(Frame, glow, ghigh, MatConv, clsid, ...
                doclang, docpic, docnum, docid, groupid, id_frm, ...
                brd_up, brd_lft, ifrm, ffrm, jfrm, gfrm);
            clearvars Frame
            
            n_frms = n_frms + 1;
            n_frmscls = n_frmscls + 1;
            FrmMetr (n_frmscls, :)   = Metrics;
            FrmHpix (n_frmscls, :)   = Hpix;
            FrmHgrad (n_frmscls, :)  = Hgrad;
            FrmHgradf (n_frmscls, :) = Hgradf;
            FrmHconv (n_frmscls, :)  = Hconv;
            FrmHconvf (n_frmscls, :) = Hconvf;
            
        end
    end
    
    % Store number of extracted frames for the image file
    ImgClassId(f, C_IMGID_NFRMS) = n_frms;
    
    % Stop timer
    elapdoc = toc;
    disp (['File #', num2str(f), ', ', num2str(docid), ', ', ...
        fname, ', num frames: ', num2str(n_frms), ', elapsed time: ', ...
        num2str(elapdoc), ' secs. - ', datestr(now)]);
    
end

% Store last file metrics
if n_frmscls ~= 0
    FrmMetr (n_frmscls + 1 : end, :)   = [];
    FrmHpix (n_frmscls + 1 : end, :)   = [];
    FrmHgrad (n_frmscls + 1 : end, :)  = [];
    FrmHgradf (n_frmscls + 1 : end, :) = [];
    FrmHconv (n_frmscls + 1 : end, :)  = [];
    FrmHconvf (n_frmscls + 1 : end, :) = [];
    outfname = strcat('FrameMetrics', fsuffix2, '.csv');
    disp (['Printer #', num2str(clsid_prev),  ...
        ', n. frames = ', num2str(n_frmscls), ...
        ', file = ', outfname]);
    dlmwrite (outfname, [FrmMetr, FrmHpix, FrmHgrad, ...
        FrmHgradf, FrmHconv, FrmHconvf], ...
        'delimiter', ',', 'precision', 12);
end

disp (['### End Image Metrics generation. Number of processed files = ', num2str(n_files)]);

% Create .csv files with all Images: Image Metrics Data, Printer Names, and Image Files
% Names
outfname = 'ImgClassIds.csv';
disp (['### Begin writing Images class id file = ', outfname]);
csvwrite (outfname, ImgClassId);
disp (['### End writing Images class id file = ', outfname]);

outfname = 'ImgsName.csv';
disp (['### Begin writing Images name = ', outfname]);
csvwrite (outfname, cellstr(ImgName));
disp (['### End writing Images name = ', outfname]);

end

