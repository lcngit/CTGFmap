%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

clear
clc
dbstop if error
dispall = false;    % set true for debug, true displays all features data

C_DPI = 600;

CTGFmap_IncludeConstants;
exp_num  = 1;
diaryfile = strcat('density_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);
initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Printer Defects Density Calculation +++');

[~, ~, ~, fv_length, AllClassIds, AllDocIds, ...
    AllFrmIds, DsetPlan, AllFeatVecs, n_vec] = CTGFmap_LoadData();
Classes = sort(unique(ClassIds));
n_cls = numel(Classes);

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
disp('*** Denormalizing Feature Vectors to actual defects density ***');
for i = 1:fv_length
    AllFeatVecs(:, i) = AllFeatVecs(:, i) .* MaxXval(i);
end

disp('*** Class density ***');
dpi2 = C_DPI * C_DPI;
for cls = 1:n_cls
    
    SelClass = AllClassIds == Classes(cls);
    Rho = sum(AllFeatVecs(SelClass, :), 2);
    meanRho = mean(Rho);
    medianRho = median(Rho);
    stdRho = std(Rho);
    minRho = min(Rho);
    maxRho = max(Rho);
    disp(['*** Class: ', num2str(Classes(cls)), ' ***']);
    
    disp(['    textures per squared dots -', ...
        ' min Rho: ', num2str(round(minRho, 3)), ...
        ', mean Rho: ', num2str(round(meanRho, 3)), ...
        ', median Rho: ', num2str(round(medianRho, 3)), ...
        ', max Rho: ', num2str(round(maxRho, 3)), ...
        ', std Rho: ', num2str(round(stdRho, 3)), ...
        ]);
    
    disp(['    textures per squared inch -', ...
        ', min Rho: ', num2str(round(minRho*dpi2,0)), ...
        ', mean Rho: ', num2str(round(meanRho*dpi2,0)), ...
        ', median Rho: ', num2str(round(medianRho*dpi2,0)), ...
        ', max Rho: ', num2str(round(maxRho*dpi2,0)), ...
        ', std Rho: ', num2str(round(stdRho*dpi2,0)), ...
        ]);
    
    disp(['    textures ppm -', ...
        ', min Rho: ', num2str(round(minRho*1E6,0)), ...
        ', mean Rho: ', num2str(round(meanRho*1E6,0)), ...
        ', median Rho: ', num2str(round(medianRho*1E6,0)), ...
        ', max Rho: ', num2str(round(maxRho*1E6,0)), ...
        ', std Rho: ', num2str(round(stdRho*1E6,0)), ...
        ]);
    
end

endtime = datetime('now');
disp(['+++ End - Processing - ', datestr(endtime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
