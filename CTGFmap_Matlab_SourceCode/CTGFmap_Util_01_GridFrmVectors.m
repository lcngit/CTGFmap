%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.2r0/2017.09.16
%_application: CTGF Features mapping

clear
clc
dbstop if error

dirtif   = input('Image files directory: ', 's');
dirtif   = strrep(dirtif, '\', '/');
if dirtif(end) ~= '/'
    dirtif = strcat(dirtif, '/');
end
cfgfile = input('Dataset plan config file: ', 's');
C_FNAME_LEN = 13;

% Set Initial parameters
CTGFmap_IncludeConstants;
C_GRAY_DEPTH = 8;                   % Color depth for Grayscale Image
C_RED = 1;
C_GREEN = 2;
C_BLUE = 3;
C_RGBA = C_BLUE;
C_WHITE = 255;

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

diaryfile = strcat('gridfrm', frmsuf, '_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Draw a Grid on the target document showing figure frames +++');

disp(['*** Begin - Loading Feature Vectors - ', datestr(now), ' ***']);

disp (['    Reading Datasets Experiments Plan File = ', cfgfile]);
DsetPlan = csvread(cfgfile, 0, 1);
[nr_cfg, ~] = size(DsetPlan);
disp (['    Loading image names from config file = ', cfgfile]);
ImgName = strings(nr_cfg, 1);
ndocs = 0;
fidcfg = fopen(cfgfile,'r');
fname = fgetl(fidcfg);
while ischar(fname)
    ndocs = ndocs + 1;
    ImgName(ndocs, :) = fname(1:C_FNAME_LEN);
    fname = fgetl(fidcfg);
end
fclose(fidcfg);
if nr_cfg ~= ndocs
    error('!!!!!! Image file names does not match with dataset plans!');
end

fmfname = strcat('FrmFeatVec_All', frmsuf, '.csv');
disp (['    Reading Frame Feature Vectors File = ', fmfname]);
FrmFeatVec = csvread(fmfname);
Classes = sort(unique(FrmFeatVec(:, C_FRMVEC_CLASS)));
maxfrms = max(FrmFeatVec(:, C_FRMVEC_FRMID));

for cls = 1:n_cls
    cls_id = Classes(cls);
    SelClass = FrmFeatVec(:, C_FRMVEC_CLASS) == cls_id;
    ClassDoc = sort(unique(FrmFeatVec(SelClass, C_FRMVEC_DOCID)));
    [n_docs, ~] = size(ClassDoc);
    doc = 0;
    KeepFrm = false(n_docs, maxfrms);
    
    for doc_id = ClassDoc'
        doc = doc + 1;
        SelDoc = FrmFeatVec(:, C_FRMVEC_DOCID) == doc_id;
        SelFrm = SelClass & SelDoc;
        n_frms = sum(SelFrm);
        if n_frms <= 0
            error('!!!Error: Invalid document id!');
        end
        ClassIds = FrmFeatVec(SelFrm, C_FRMVEC_CLASS);
        DocIds   = FrmFeatVec(SelFrm, C_FRMVEC_DOCID);
        FrmIds   = FrmFeatVec(SelFrm, C_FRMVEC_FRMID);
        FrmIrow  = FrmFeatVec(SelFrm, C_FRMVEC_IROW);
        FrmFrow  = FrmFeatVec(SelFrm, C_FRMVEC_FROW);
        FrmIcol  = FrmFeatVec(SelFrm, C_FRMVEC_ICOL);
        FrmFcol  = FrmFeatVec(SelFrm, C_FRMVEC_FCOL);
        
        IdxFrms = sort(unique(FrmIds(:)));
        if IdxFrms(1) == 0
            IdxFrms(1) = [];
        end
        n_fig = numel(IdxFrms);
        SelDel = true(n_frms, 1);
        for fr = 1:n_fig
            numfr = IdxFrms(fr);
            ifr = find(FrmIds == numfr, 1, 'first');
            if ~isempty(ifr)
                SelDel(ifr) = false;
                KeepFrm(doc, numfr) = true;
            else
                disp(['Frame not found ', num2str(numfr)]);
            end
        end
        ClassIds(SelDel) = [];
        DocIds(SelDel)   = [];
        FrmIds(SelDel)   = [];
        FrmIrow(SelDel)  = [];
        FrmFrow(SelDel)  = [];
        FrmIcol(SelDel)  = [];
        FrmFcol(SelDel)  = [];
        
        % Build Image Name
        SelDset = DsetPlan(:, C_DSETPLAN_DOCID) == doc_id;
        if sum(SelDset) ~= 1
            error(['!!!!! Error: Invalid document id!', num2str(doc_id)]);
        end
        tiffname = char(ImgName(SelDset));
        fulltiff = char(strcat(dirtif,tiffname));
        disp(['*** Begin mapping for image file: ', tiffname]);
        imgInfo = imfinfo(fulltiff);
        ImgDoc = imread(fulltiff);
        if imgInfo.BitDepth > C_GRAY_DEPTH
            Img = single(rgb2gray(ImgDoc));
        else
            Img = single(ImgDoc);
        end
        [nr_img, nc_img] = size(Img);
        Img_RGB = zeros(nr_img, nc_img, C_RGBA);
        Img_RGB(:, :, C_RED)   = Img ./ C_WHITE;
        Img_RGB(:, :, C_GREEN) = Img ./ C_WHITE;
        Img_RGB(:, :, C_BLUE)  = Img ./ C_WHITE;
        
        disp(['*** Showing frames of image file: ', tiffname, ...
            ', document id: ', num2str(doc_id), ...
            ', num. of frames: ', num2str(n_frms), ...
            ' ***']);
        
        for frm = 1:numel(FrmIds)
            ini_r = FrmIrow(frm);
            end_r = FrmFrow(frm);
            ini_c = FrmIcol(frm);
            end_c = FrmFcol(frm);
            disp(['   #: ', num2str(frm), ...
                ', Frame mumber: ', num2str(FrmIds(frm)), ...
                ', left superior corner: ', num2str(ini_r), ' x ', num2str(ini_c), ...
                ', right inferior corner: ', num2str(end_r), ' x ', num2str(end_c)]);
            for i = ini_r:end_r
                for j = ini_c:end_c
                    if Img_RGB(i, j, C_RED) > 0.9 && ...
                            Img_RGB(i, j, C_GREEN) > 0.9 && ...
                            Img_RGB(i, j, C_BLUE) > 0.9
                        Img_RGB(i, j, C_RED)   = 0;
                    end
                end
            end
            for i = [C_RED, C_GREEN, C_BLUE]
                for j =0:3
                    if i == C_RED
                        pix_color = 1;
                    else
                        pix_color = 0;
                    end
                    Img_RGB(ini_r:end_r, ini_c+j, i) = pix_color;
                    Img_RGB(ini_r:end_r, end_c-j, i) = pix_color;
                    Img_RGB(ini_r+j, ini_c:end_c, i) = pix_color;
                    Img_RGB(end_r-j, ini_c:end_c, i) = pix_color;
                end
            end
            
        end
        
        imgfname = tiffname(1:end-4);
        pngfname = strcat('pics', frmsuf, num2str(cls_id), '/Framed_', ...
            imgfname, '_D', num2str(doc_id), '.png');
        imwrite(Img_RGB, pngfname);
        disp(['*** Framed image saved into file: ', pngfname, ' ****']);
        
    end
    
    if cls == 1
        KeepAll = horzcat(ClassDoc(:, 1), KeepFrm);
    else
        KeepAll = vertcat(KeepAll, horzcat(ClassDoc(:, 1), KeepFrm)); %#ok<AGROW>
    end
    
end

keepfname = strcat('KeepFrames', frmsuf,'.csv');
dlmwrite(keepfname, KeepAll, 'delimiter', ',', 'precision', 12);
disp(['*** Frames containing figures to keep saved into file: ', ...
    keepfname, ' ****']);

endtime = datetime('now');
disp(['+++ End - Step Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
