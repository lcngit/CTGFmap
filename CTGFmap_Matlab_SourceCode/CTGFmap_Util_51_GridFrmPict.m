%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2016.09.01
%_application: CTGF Features mapping

clear
clc
dbstop if error

suffix = input('Figures dir & files suffix: ');

% Set Initial parameters
CTGFmap_IncludeConstants;
dirtif = 'C:/Users/LCNavarro/CTGF_PrtAttribMethod/DocsPrt';
C_GRAY_DEPTH = 8;                   % Color depth for Grayscale Image
C_RED = 1;
C_GREEN = 2;
C_BLUE = 3;
C_RGBA = C_BLUE;
C_WHITE = 255;

diaryfile = strcat('gridfrmpict_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Draw a Grid on the target document showing figure frames +++');

disp(['*** Begin - Loading Feature Vectors - ', datestr(now), ' ***']);

[ClassNames, n_cls] = CTGFmap_LoadClassNames();

fmfname = 'FrmFeatVec_All_AllFrms.csv';
disp (['    Reading Frame Feature Vectors File = ', fmfname]);
FrmFeatVec = csvread(fmfname);
maxfrms = max(FrmFeatVec(:, C_FRMVEC_FRMID));

fgfname = strcat('FigFrms', num2str(suffix),'.csv');
disp (['    Reading Figure Frames = ', fgfname]);
DocFrms = csvread(fgfname);
[n_docs, ~] = size(DocFrms);
KeepFrm = false(n_docs, maxfrms);

for doc = 1:n_docs
    doc_id = DocFrms(doc, 1);
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
    
    IdxFrms = sort(unique(DocFrms(doc, 2:end)));
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
    cls = floor(doc_id / 1000);
    numdoc = mod(doc_id, 100);
    langpic = floor((doc_id - (cls * 1000) - numdoc) / 100);
    langdoc = floor(langpic / 2);
    pictdoc = mod(langpic, 2);
    if langdoc == 0
        langstr = 'I';
    else
        langstr = 'P';
    end
    if pictdoc == 0
        pictstr = 'C';
    else
        pictstr = 'S';
    end
    if numdoc < 10
        numstr = strcat('0', num2str(numdoc));
    else
        numstr = num2str(numdoc);
    end
    imgfname = strcat(ClassNames{cls}, langstr, pictstr, numstr);
    tiffname = strcat(imgfname,'.tif');
    disp(['*** Begin mapping for image file: ', tiffname]);
    imgInfo = imfinfo(fullfile(dirtif, tiffname));
    ImgDoc = imread(fullfile(dirtif, tiffname));
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
    
    pngfname = strcat('pics', num2str(suffix), '/Framed_', ...
        imgfname, '_D', num2str(doc_id), '.png');
    imwrite(Img_RGB, pngfname);
    disp(['*** Framed image saved into file: ', pngfname, ' ****']);
    
end

keepfname = strcat('KeepFigFrames', num2str(suffix), '.csv');
dlmwrite(keepfname, [DocFrms(:, 1), KeepFrm], ...
    'delimiter', ',', 'precision', 12);
disp(['*** Frames containing figures to keep saved into file: ', ...
    keepfname, ' ****']);

endtime = datetime('now');
disp(['+++ End - Step Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
