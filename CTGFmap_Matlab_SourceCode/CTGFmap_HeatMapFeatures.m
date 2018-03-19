%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.3r0/2017.10.07
%_application: CTGF Features mapping

function [s_x, s_y] = CTGFmap_HeatMapFeatures (cls_id, glow, ghigh, ...
    nmatconv, dirtif, tiffname, doc_id, frm_id, ini_x, end_x, ...
    ini_y, end_y, feat_str, cls_filter, TexturesToMap, FeaturesToMap, ...
    legbar)

CTGFmap_IncludeConstants;
C_CLASS_FILTER_GRAY = 0;
C_CLASS_FILTER_CTGF = -1;

% Contant values, all constant value names begin as "C_" following by CAPS
C_GRAY_DEPTH = 8;                   % Color depth for Grayscale Image
C_MAX_N_MAP = 50;
C_MAX_TIT3 = 5;

% Number of features to map
n_map = numel(TexturesToMap);

[~, imgfname, ~] = fileparts(tiffname);
disp(['*** Begin mapping for image file: ', tiffname]);

% Create Convolution Matrix
MatConv = ones(nmatconv, nmatconv);

%%%%%%%%%% Get image and extract frame to process %%%%%%%%%%
imgInfo = imfinfo(fullfile(dirtif, tiffname));
ImgDoc = imread(fullfile(dirtif, tiffname));

% If image matrix is not grayscale, converts it to grayscale
if imgInfo.BitDepth > C_GRAY_DEPTH
    Img = single(rgb2gray(ImgDoc));
else
    Img = single(ImgDoc);
end
[nr_img, nc_img] = size(Img);

% Adjust frame coordinates
disp(['    Image size: ',num2str(nc_img), 'x', num2str(nr_img)])
if end_x > nc_img
    end_x = nc_img;
end
s_x = end_x - ini_x + 1;
if end_y > nr_img
    end_y = nr_img;
end
s_y = end_y - ini_y + 1;
Frame = Img (ini_y : end_y, ini_x : end_x);

disp(['    Frame size: ',num2str(s_x), 'x', num2str(s_y), ', ', num2str(s_x*s_y), ' pixels.'])
disp(['    Frame Left Superior pixel: (',num2str(ini_x), ',', num2str(ini_y), ...
    '), Right inferior pixel: (',num2str(end_x), ',', num2str(end_y), ')'])

% Build base name for figures
basefname = strcat('C', num2str(cls_id), '_', imgfname, ...
    '_Frm', num2str(frm_id), ...
    '_', num2str(ini_y), '_', num2str(end_y), ...
    '_', num2str(ini_x), '_', num2str(end_x), ...
    '_Most', num2str(n_map), '_', feat_str(1:3));

if cls_filter == C_CLASS_FILTER_GRAY 
    %%%%%%%%%% Grayscale Frame Image %%%%%%%%%%
    disp('    Creating frame image figure ');
    % Set the corner on images for reference
    Frame(1, 1)       = 0;
    Frame(1, s_x)     = 0;
    Frame(s_y, 1)     = 0;
    Frame(s_y, s_x)   = 0;
    %%%%%%%%%% Gray Scale Image %%%%%%%%%%
    figure;
    imagesc(Frame);
    colormap('gray');
    if legbar > 0
        colorbar;
    end
    tit1 = ['Fragment of document id: ', num2str(doc_id), ...
        ', frame: ', num2str(frm_id)];
    tit2 = 'Grayscale scanned image';
    title({tit1, tit2})
    axis equal tight
    axis off
    figfname = strcat(basefname, '_L', num2str(legbar), '_frame');
    disp(['    Investigated frame saved on: ', figfname]);
    print(figfname,'-dpdf', '-r300');
    
else
    
    %%%%%%%%%% Process CTGF convolution and filtering %%%%%%%%%%
    % include 1 pixel border in order to correct calculation of convolution
    % on the border of selected frame.
    FiltConv = CTGFmap_FrameConvTextGradFilt(Frame, glow, ghigh, MatConv);
    
    n_conv = sum(sum(FiltConv > 0));
    disp(['    Total number of CTGF textures in frame: ', num2str(n_conv)]);

    if cls_filter == C_CLASS_FILTER_CTGF
        %%%%%%%%%% Building CTGF Textures Map %%%%%%%%%%
        disp('    Building CTGF Textures map');
        CTGFmap = zeros(s_y, s_x);
        maxCTGF = nmatconv * nmatconv * 255;
        halfCTGF = floor(maxCTGF / 2);
        log2max = log2(halfCTGF);
        SelZeros = FiltConv == 0;
        SelUp = FiltConv > halfCTGF;
        SelDown = FiltConv > 0 & ~SelUp;
        CTGFmap(SelUp) = log2max - log2(maxCTGF - FiltConv(SelUp));
        CTGFmap(SelDown) = -(log2max - log2(FiltConv(SelDown)));
        TickMarks = round(log2max + 1 + [-log2max, -(log2max*4/5), -(log2max*3/5), ...
            -(log2max*2/5), -(log2max/5), 0, (log2max/5), ...
            (log2max*2/5), (log2max*3/5), (log2max*4/5), log2max]);
        CTGFmap = CTGFmap + log2max + 1;
        CTGFmap(SelZeros) = 0;
        % Set the corner on images for reference
        CTGFmap(1, 1)     = (2 * log2max) + 1;
        CTGFmap(1, s_x)   = 1;
        CTGFmap(s_y, 1)   = (2 * log2max) + 1;
        CTGFmap(s_y, s_x) = 1;
        %%%%%%%%%% CTGF Textures Image %%%%%%%%%%
        disp('    Creating CTGF Textures figure ');
        figure;
        imagesc(CTGFmap);
        CTGFcolor = colormap('jet');
        CTGFcolor(1, :) = 1;
        colormap(CTGFcolor)
        if legbar > 0
            colorbar('Ticks', TickMarks);
        end
        tit1 = ['Fragment of document id: ', num2str(doc_id), ...
            ', frame: ', num2str(frm_id)];
        tit2 = 'CTGF textures map';
        title({tit1, tit2})
        axis equal tight
        axis off
        figfname = strcat(basefname, '_L', num2str(legbar), '_texture');
        disp(['    Textures map saved on: ', figfname]);
        print(figfname,'-dpdf', '-r300');

    else
        %%%%%%%%%% Building Most important features heat map %%%%%%%%%%
        disp('    Building the heat map of most important textures');
        HeatMap = zeros(s_y, s_x);
        tot_txtr = 0;
        if n_map <= C_MAX_N_MAP
            max_map = n_map;
        else
            max_map = C_MAX_N_MAP;
            for i = n_map:-1:(max_map+1)
                MaskTxtr = FiltConv == TexturesToMap(i);
                n_txtr = sum(sum(MaskTxtr > 0));
                tot_txtr = tot_txtr + n_txtr;
                [~, HeatMask] = CTGF_ImgConv(single(MaskTxtr), MatConv);
                HeatMap(HeatMask > 0) = max_map;
                disp(['    #: ', num2str(i), ...
                    ', Class: ', num2str(cls_id), ...
                    ', Filter Class: ', num2str(cls_filter), ...
                    ', Feature Name: ', FeaturesToMap{i}, ...
                    ', Texture value: ', num2str(TexturesToMap(i)), ...
                    ', Texture count: ', num2str(n_txtr)]);
            end
        end
        for i = max_map:-1:1
            MaskTxtr = FiltConv == TexturesToMap(i);
            n_txtr = sum(sum(MaskTxtr > 0));
            tot_txtr = tot_txtr + n_txtr;
            [~, HeatMask] = CTGF_ImgConv(single(MaskTxtr), MatConv);
            HeatMap(HeatMask > 0) = i;
            disp(['    #: ', num2str(i), ...
                ', Class: ', num2str(cls_id), ...
                ', Filter Class: ', num2str(cls_filter), ...
                ', Feature Name: ', FeaturesToMap{i}, ...
                ', Texture value: ', num2str(TexturesToMap(i)), ...
                ', Texture count: ', num2str(n_txtr)]);                
        end
        pct_txtr = round((tot_txtr / n_conv) * 100, 2);
        disp(['    Total textures count on heatmap: ', num2str(tot_txtr), ...
            ', total of CTGF textures: ', num2str(n_conv), ...               
            ', percentage of CTGF textures: ', num2str(pct_txtr), '%']);                
       % Set the corner on images for reference
        HeatMap(1, 1)     = 1;
        HeatMap(1, s_x)   = 1;
        HeatMap(s_y, 1)   = 1;
        HeatMap(s_y, s_x) = 1;
        HeatMap(2, 2)     = max_map;
        HeatMap(2, s_x-1) = max_map;
        HeatMap(s_y-1, 2) = max_map;
        HeatMap(s_y-1, s_x-1) = max_map;
        % Build Background mask
        [~, Bkg] = CTGF_ImgConv (255-Frame, MatConv);
        BackFrame = (Bkg >= (nmatconv * 255 * 0.1));
        %%%%%%%%%% Most Important Textures (Features) Image %%%%%%%%%%
        disp('    Creating map for most important features figure ');
        figure;
        imagesc(BackFrame);
        hold on
        h = imagesc(HeatMap);
        Heatcolor = colormap('hot');
        [n_color, ~] = size(Heatcolor);
        if n_color >= (3*max_map)
            s_color = floor(n_color / max_map) - 1;
        else
            s_color = 2;
        end
        if s_color <= 1
            error('!!!Error: Invalid color map shift!')
        end
        Heatcolor(s_color+1:end, :) = Heatcolor(1:end-s_color, :);
        Heatcolor(1:s_color, :) = 1;
        colormap(Heatcolor);
        if legbar > 0
            colorbar('Ticks', 0:max_map);
        end
        alpha(h, 0.95);
        tit1 = ['Fragment of document id: ', num2str(doc_id), ...
            ', frame: ', num2str(frm_id)];
        tit2 = [num2str(n_map), ' most ', feat_str, ...
            ' discriminants of class: ', num2str(cls_filter)];
        n_tit = n_map;
        if n_tit > C_MAX_TIT3
            n_tit = C_MAX_TIT3;
        end
        tit3 = strcat('(', FeaturesToMap{1});
        for i = 2:n_tit
            tit3 = [tit3, ', ', FeaturesToMap{i}]; %#ok<AGROW>
        end
        if n_map > C_MAX_TIT3
            tit3 = [tit3, ', ...)'];
        else
            tit3 = [tit3, ')'];
        end
        title({tit1, tit2, tit3});
        axis equal tight
        axis off
        hold off
        figfname = strcat(basefname, '_Filt', num2str(cls_filter), ...
            '_Lbl', num2str(legbar), '_map');
        disp(['    Heat map saved on: ', figfname]);
        print(figfname,'-dpdf', '-r300');
    end
 
end

close all
    
end

