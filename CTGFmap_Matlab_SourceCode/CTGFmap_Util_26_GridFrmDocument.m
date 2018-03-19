%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.2r0/2018.03.15
%_application: CTGF Features mapping

clear
clc
dbstop if error

doc_id = input('Document Identification: ');
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

diaryfile = strcat('gridfrmdoc_D', num2str(doc_id),'_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Draw a Grid on the target document showing frames +++');

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

fmfname = 'FrmFeatVec_All.csv';
disp (['    Reading Frame Feature Vectors File = ', fmfname]);
FrmFeatVec = csvread(fmfname);

SelDoc = FrmFeatVec(:, C_FRMVEC_DOCID) == doc_id;
n_frms = sum(SelDoc);
if n_frms <= 0
    error('!!!Error: Invalid document id!');
end
ClassIds = FrmFeatVec(SelDoc, C_FRMVEC_CLASS);
DocIds   = FrmFeatVec(SelDoc, C_FRMVEC_DOCID);
FrmIds   = FrmFeatVec(SelDoc, C_FRMVEC_FRMID);
FrmIrow  = FrmFeatVec(SelDoc, C_FRMVEC_IROW);
FrmFrow  = FrmFeatVec(SelDoc, C_FRMVEC_FROW);
FrmIcol  = FrmFeatVec(SelDoc, C_FRMVEC_ICOL);
FrmFcol  = FrmFeatVec(SelDoc, C_FRMVEC_FCOL);

% Build Image Name
SelDset = DsetPlan(:, C_DSETPLAN_DOCID) == doc_id;
if sum(SelDset) ~= 1
    error(['!!!!! Error: Invalid document id!', num2str(doc_id)]);
end
tiffname = char(ImgName(SelDset));
imgfname = tiffname(1:end-4);
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

pngfname = strcat('Framed_', imgfname, '_D', num2str(doc_id), '.png');
imwrite(Img_RGB, pngfname);
disp(['*** Framed image saved into file: ', pngfname, ' ****']);

endtime = datetime('now');
disp(['+++ End - Step Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
