%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.4r0/2017.10.07
%_application: CTGF Features mapping

clear
clc
dbstop if error

dirtif   = input('Image files directory: ', 's');
dirtif   = strrep(dirtif, '\', '/');
if dirtif(end) ~= '/'
    dirtif = strcat(dirtif, '/');
end
cfgdspfile  = input('Dataset plan config file: ', 's');
cfgfname  = input('Heatmaps config file: ', 's');
if isempty(cfgfname)
    cfgfname = 'Config_HeatMaps.csv';
end
rnk_input = input('Rank type (0 to 7): ');
[rnk_str, feat_str] = CTGFmap_Rank_Type(rnk_input);
rnk_type = rnk_input;
n_most = input('Number of most important features to display: ');

glow = 1;
ghigh = 32;
nmatconv = 3;
C_FNAME_LEN = 13;

CTGFmap_IncludeConstants;

diaryfile = strcat('heatmaps_log_', strrep(strrep(datestr(now), ...
    ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

% Read from config file the image file names and identifications
disp (['Loading data set plan from config file = ', cfgdspfile]);
DsetPlan = csvread(cfgdspfile,0,1);
[nr_cfg, ~] = size(DsetPlan);
disp (['Loading image names from config file = ', cfgdspfile]);
ImgName = strings(nr_cfg, 1);
ndocs = 0;
fidcfg = fopen(cfgdspfile,'r');
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

initime = datetime('now');
disp(['+++ Begin - Drawing Heat Maps as HeatMapsConfig File - ', datestr(initime), ' +++']);

[ClassNames, n_names] = CTGFmap_LoadClassNames();
[FVColIds, fv_length] = CTGFmap_LoadFeatureIds();

rnkfname = strcat('FrmFeatVec_NewRank_', rnk_str, '_Final.csv');
disp(['*** Reading Features Rank from file: ', rnkfname, ' ****']);
AllRank = csvread(rnkfname);
[~, nc_rnk] = size(AllRank);
if nc_rnk ~= fv_length
    error('!!!Error: Rank does not match Class Names or Feature Vectors!');
end
AllRank(AllRank == 0) = fv_length;
[~, IdxAllRank] = sort(AllRank, 2, 'ascend');

disp(['*** Heat Maps Configuration loading from file: ', cfgfname, ' ***']);
HeatMapsCfg = csvread(cfgfname);
[n_cfg, ~] = size(HeatMapsCfg);

for cfg = 1:n_cfg
    
    cls      = HeatMapsCfg(cfg, C_HMAP_CLASS);
    langdoc  = HeatMapsCfg(cfg, C_HMAP_LANG);
    pictdoc  = HeatMapsCfg(cfg, C_HMAP_PICT);
    numdoc   = HeatMapsCfg(cfg, C_HMAP_NUMDOC);
    doc_id   = HeatMapsCfg(cfg, C_HMAP_DOCID);
    doc_grp  = HeatMapsCfg(cfg, C_HMAP_DOCGROUP);
    frm_id   = HeatMapsCfg(cfg, C_HMAP_FRMID);
    ini_x    = HeatMapsCfg(cfg, C_HMAP_INI_COL);
    end_x    = HeatMapsCfg(cfg, C_HMAP_END_COL);
    ini_y    = HeatMapsCfg(cfg, C_HMAP_INI_ROW);
    end_y    = HeatMapsCfg(cfg, C_HMAP_END_ROW);
    cls_filt = HeatMapsCfg(cfg, C_HMAP_CLASS_FILTER);
    legbar   = HeatMapsCfg(cfg, C_HMAP_COLORBAR);
    SelDset  = DsetPlan(:, C_DSETPLAN_DOCID) == doc_id;
    if sum(SelDset) ~= 1
        error(['!!!!! Error: Invalid document id!', num2str(doc_id)]);
    end
    tiffname = char(ImgName(SelDset));
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
    
    disp('*** Creating map ***');
    disp(['    Image file name: ', tiffname, ' of class: ', ...
        num2str(cls)]);
    disp(['    Language: ', num2str(langdoc), ' (', langstr, ')']);
    disp(['    Pictures: ', num2str(pictdoc), ' (', pictstr, ')']);
    disp(['    Doc. number: ', num2str(numdoc), ' (', numstr, ')']);
    disp(['    Gradients: low = ', num2str(glow), ', high = ', ...
        num2str(ghigh)]);
    disp(['    Frame: Left Superior = (', num2str(ini_x), ',', num2str(ini_y), ...
        '), Right Inferior = (', num2str(end_x), ',', num2str(end_y), ')']);
    disp(['    Class filter to apply: ', num2str(cls_filt)]);
    TexturesToMap = zeros(1, n_most);
    FeaturesToMap = cell(1, n_most);
    if cls_filt > 0
        disp(['    Filter ', num2str(n_most), ' most important features to map:']);
        for i = 1:n_most
            fv_idx = IdxAllRank(cls_filt, i);
            fvcolstr = char(FVColIds(fv_idx));
            if ~strcmp(fvcolstr(1),'X')
                error('!!!Error: Invalid feature id!');
            end
            FeaturesToMap{i} = fvcolstr;
            TexturesToMap(i) = str2double(fvcolstr(2:end));
            disp(['    --- most important #', num2str(i), ...
                ', feature index: ', num2str(fv_idx), ...
                ', feature name: ', fvcolstr, ...
                ', texture value: ', num2str(TexturesToMap(i))]);
        end
    end

    CTGFmap_HeatMapFeatures (cls, glow, ghigh, ...
        nmatconv, dirtif, tiffname, doc_id, frm_id, ini_x, end_x, ...
        ini_y, end_y, feat_str, cls_filt, TexturesToMap, FeaturesToMap, ...
        legbar);
    
end

endtime = datetime('now');
disp(' ');
disp(['+++ End - Drawing Heat Maps as HeatMapsConfig File - ', ...
    datestr(initime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
