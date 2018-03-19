%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.0ro/2017.09.09
%_application: CTGF Features mapping

clear
clc
ChartColors = [
    1,      0,      0;      % 1.  Red
    1,      0.5,    0;      % 2.  Orange
    1,      1,      0;      % 3.  Yellow
    0,      1,      0;      % 4.  Green
    0.75,   0.75,   0.75;	% 5.  Ligth Gray
    0,      1,      1;      % 6.  Cyan
    0,      0,      1;      % 7.  Blue
    0.5,    0,      1;      % 8.  Blue Violet
    1,      0,      1;      % 9.  Magenta
    0,      0,      0];     % 10. Black
ChartLeg = {
    'B4070';
    'C1150';
    'C3240';
    'C4370';
    'H1518';
    'H225A';
    'H225B';
    'LE260';
    'OC330';
    'SC315'};

CTGFmap_IncludeConstants;

selmtd = input('Select Method (0 = SVM, 1 = RndFor): ');
if selmtd == 0
    mtd = METHOD_SVM_SMO;
else
    mtd = METHOD_TREE_ENSAMBLE;
end
rnk_type = input('Rank type (0 to 7): ');
[rnk_str, feat_type] = CTGFmap_Rank_Type(rnk_type);
cls_num = input('Class (0 means all): ');
exp_num = input('Experiment (0 means all): ');
x_var = 0;
while x_var ~= C_TIMEXVAR_FVLEN && x_var ~= C_TIMEXVAR_NUMFVS
    x_var = input(...
        'X axis (1 = Feature Vector Length, 2 = Number of vectors): ');
end
n_poly = input('Include polynomial on train (0 = No, >0 = polyn. degree): ');

fsuffix = strcat('_R', num2str(rnk_type), '_M', num2str(mtd));
if cls_num ~= 0
    fsuffix = strcat(fsuffix, '_C', num2str(cls_num));
    ChartColors = [0, 0, 0]; % Black
    ChartLeg = ChartLeg{cls_num};
end
if exp_num ~= 0
    fsuffix = strcat(fsuffix, '_E', num2str(exp_num));
end

diaryfile = strcat('elapsedtimechart', fsuffix, '_log_', ...
    strrep(strrep(datestr(now), ':', '_'), ' ', '-'), '.txt');
diary(diaryfile);

initime = datetime('now');
disp(['+++ Begin - Processing - ', datestr(initime), ' +++']);
disp('+++ Elapsed Time Charts +++')
disp('');

eltfname = strcat('AllElapsedTime.csv');
disp(['    Reading all elapsed time metrics file: ', eltfname]);
ElapsedTime = csvread(eltfname);

SelData = ElapsedTime(:, C_ELAPSED_RANK) == rnk_type & ...
    ElapsedTime(:, C_ELAPSED_METHOD) == mtd ;
if cls_num ~= 0
    SelData = SelData & (ElapsedTime(:, C_ELAPSED_CLASS) == cls_num);
end
if exp_num ~= 0
    SelData = SelData & (ElapsedTime(:, C_ELAPSED_EXPNUM) == exp_num);
end
if cls_num == 0
    EltClass = ElapsedTime(SelData, C_ELAPSED_CLASS);
else
    EltClass = ones(sum(SelData), 1);
end
EltTstId  = ElapsedTime(SelData, C_ELAPSED_TSTID);
EltFVlen  = ElapsedTime(SelData, C_ELAPSED_FVLENGTH);
EltNumFVs = ElapsedTime(SelData, C_ELAPSED_NUMFVS);
EltTperFV = ElapsedTime(SelData, C_ELAPSED_TIMEPFV) * 1000;
clearvars ElapsedTime

if x_var == C_TIMEXVAR_FVLEN
    chartit = 'Feature Vector Length';
    ChartAxis = {
        'Feature Vector Length';
        'Elapsed Time per Vector (ms)'};
elseif x_var == C_TIMEXVAR_NUMFVS
    chartit = strcat ('Number of vectors of length', {' '}, ...
        num2str(EltFVlen(1)));
    ChartAxis = {
        'Number of Vectors';
        'Elapsed Time per Vector (ms)'};
else
    disp('!!!!! Error: Invalid X axix!');
end

SelTrain   = EltTstId == C_EXP_TRAINING;
if sum(SelTrain) > 0
    TrainClass = EltClass(SelTrain);
    if x_var == C_TIMEXVAR_FVLEN
        TrainData  = horzcat(EltFVlen(SelTrain), EltTperFV(SelTrain));
    elseif x_var == C_TIMEXVAR_NUMFVS
        TrainData  = horzcat(EltNumFVs(SelTrain), EltTperFV(SelTrain));
    else
        disp('!!!!! Error: Invalid X axix!');
    end
    if n_poly ~= 0
        trainfname = strcat('TrainElapsedTime', fsuffix, '_P', num2str(n_poly));
    else
        trainfname = strcat('TrainElapsedTime', fsuffix);
    end
    CTGFmap_Classes_Scatter_Chart(TrainData, TrainClass, 2, 0, 0, ...
        [strcat('Training Elapset Time', {' x '}, chartit), ' '], ...
        ChartAxis, ChartColors, ChartLeg, ...
        trainfname, n_poly);
end

SelVald   = EltTstId == C_EXP_VALIDATION;
if sum(SelVald) > 0
    ValdClass = EltClass(SelVald);
    if x_var == C_TIMEXVAR_FVLEN
        ValdData  = horzcat(EltFVlen(SelVald), EltTperFV(SelVald));
    elseif x_var == C_TIMEXVAR_NUMFVS
        ValdData  = horzcat(EltNumFVs(SelVald), EltTperFV(SelVald));
    else
        disp('!!!!! Error: Invalid X axix!');
    end
    valdfname = strcat('ValidElapsedTime', fsuffix);
    CTGFmap_Classes_Scatter_Chart(ValdData, ValdClass, 2, 0, 0, ...
        [strcat('Validation Elapset Time', {' x '}, chartit), ' '], ...
        ChartAxis, ChartColors, ChartLeg, ...
        valdfname, 1);
end

SelTest   = EltTstId == C_EXP_TEST;
if sum(SelTest) > 0
    TestClass = EltClass(SelTest);
    TestData  = horzcat(EltFVlen(SelTest), EltTperFV(SelTest));
    if x_var == C_TIMEXVAR_FVLEN
        TestData  = horzcat(EltFVlen(SelTest), EltTperFV(SelTest));
    elseif x_var == C_TIMEXVAR_NUMFVS
        TestData  = horzcat(EltNumFVs(SelTest), EltTperFV(SelTest));
    else
        disp('!!!!! Error: Invalid X axix!');
    end
    testfname = strcat('FinalTestElapsedTime', fsuffix, '_P1');
    CTGFmap_Classes_Scatter_Chart(TestData, TestClass, 2, 0, 0, ...
        [strcat('Final Test Elapset Time', {' x '}, chartit), ' '], ...
        ChartAxis, ChartColors, ChartLeg, ...
        testfname, 1);
end

SelTstVal   = EltTstId == C_EXP_TEST | EltTstId == C_EXP_VALIDATION;
if sum(SelTstVal) > 0
    TstValClass = EltClass(SelTstVal);
    TstValData  = horzcat(EltFVlen(SelTstVal), EltTperFV(SelTstVal));
    if x_var == C_TIMEXVAR_FVLEN
        TstValData  = horzcat(EltFVlen(SelTstVal), EltTperFV(SelTstVal));
    elseif x_var == C_TIMEXVAR_NUMFVS
        TstValData  = horzcat(EltNumFVs(SelTstVal), EltTperFV(SelTstVal));
    else
        disp('!!!!! Error: Invalid X axix!');
    end
    tstvalfname = strcat('TestsElapsedTime', fsuffix, '_P1');
    CTGFmap_Classes_Scatter_Chart(TstValData, TstValClass, 2, 0, 0, ...
        [strcat('Tests Elapset Time', {' x '}, chartit), ' '], ...
        ChartAxis, ChartColors, ChartLeg, ...
        tstvalfname, 1);
end

endtime = datetime('now');
disp(['+++ End - Processing - ', datestr(initime), ' +++']);
disp(['    Initial time: ', datestr(initime)]);
disp(['    End time ...: ', datestr(endtime)]);

diary('off')
