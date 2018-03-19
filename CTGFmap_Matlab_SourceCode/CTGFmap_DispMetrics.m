%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function CTGFmap_DispMetrics (dsname, Metrics)

CTGFmap_IncludeConstants;

disp (['Results of test with dataset: ', dsname]);
disp (['  Number of real elements of Class Positive ......... : ', ...
       num2str(Metrics(METRIC_REALPOS))]);
disp (['  Number of real elements of Class Negative ......... : ', ...
       num2str(Metrics(METRIC_REALNEG))]);
disp (['  Number of predicted elements of Class Positive .... : ', ...
       num2str(Metrics(METRIC_PREDPOS))]);
disp (['  Number of predicted elements of Class Negative .... : ', ...
       num2str(Metrics(METRIC_PREDNEG))]);
disp ('  Confusion Matrix:');
fprintf('\t\t\t\t\tPredict Classes\n');
fprintf('\tReal Classes\tPositive\tNegative\n');
fprintf(strcat('\tPositive\t\t', ...
               num2str(Metrics(METRIC_TRUEPOS)), '\t\t\t', ...
               num2str(Metrics(METRIC_FALSENEG)), '\n'));
fprintf(strcat('\tNegative\t\t', ...
               num2str(Metrics(METRIC_FALSEPOS)), '\t\t\t', ...
               num2str(Metrics(METRIC_TRUENEG)), '\n'));
disp ('  Metrics:');
disp (['    Accuracy .................................... = ', ...
       num2str(Metrics(METRIC_ACCURACY) * 100), '%']);
disp (['    Recall ...................................... = ', ...
       num2str(Metrics(METRIC_RECALL) * 100), '%']);
disp (['    Specificity ................................. = ', ...
       num2str(Metrics(METRIC_SPECIFICITY) * 100), '%']);
disp (['    Precision ................................... = ', ...
       num2str(Metrics(METRIC_PRECISION) * 100), '%']);
disp (['    Negative Predictive Value ................... = ', ...
       num2str(Metrics(METRIC_NEGPREDVAL) * 100), '%']);
disp (['    F1Score (F1measure of positive class) ....... = ', ...
       num2str(Metrics(METRIC_F1SCORE) * 100), '%']);
disp (['    F1Neg (F1measure of negative class) ......... = ', ...
       num2str(Metrics(METRIC_F1NEG) * 100), '%']);

end

