%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.2r0/2017.09.16
%_application: CTGF Features mapping

function Metrics = CTGFmap_CalcMetrics (ConfMtx)
% confusion matrix ConfMtx: first class = -1 = N, second class = 1 = P,
% then fields of Metrics are filled according Metrics fields rules 
% that presents first class Positive, and second class Negative.

total = sum(sum(ConfMtx));
truePos = ConfMtx(end, end);
falseNeg = ConfMtx(end, 1);
trueNeg = ConfMtx(1, 1);
falsePos = ConfMtx(1, end);

truePosPerc = truePos / total;
falseNegPerc = falseNeg / total;
trueNegPerc = trueNeg / total;
falsePosPerc = falsePos / total;

realPos = truePos + falseNeg;
realNeg = trueNeg + falsePos;

predPos = truePos + falsePos;
predNeg = trueNeg + falseNeg;

if realPos > 0
    recall = truePos / realPos;         % tpr, recall, true positive rate
else
    recall = 0;
end
    
if realNeg > 0
    specificity = trueNeg / realNeg;    % tnr, specificity, true negative rate
else
    specificity = 0;
end

if predPos > 0
    precision = truePos / predPos;      % ppv, precision, positive predictive value
else
    precision = 0;
end

if predNeg > 0
    negpredval = trueNeg / predNeg;      % npv, negative predictive value
else
    negpredval = 0;
end

if (precision + recall) > 0
    f1score = 2 * ((precision * recall) / (precision + recall));
else
    f1score = 0;
end

if (specificity + negpredval) > 0
    f1neg = 2 * ((specificity * negpredval) / (specificity + negpredval));
else
    f1neg = 0;
end

accuracy = (recall + specificity) / 2; % normalized accuracy
Metrics = [realPos, realNeg, predPos, predNeg, ...
    truePos, falseNeg, falsePos, trueNeg, ...
    truePosPerc, falseNegPerc, falsePosPerc, trueNegPerc, ...
    accuracy, recall, specificity, precision, negpredval, ...
    f1score, f1neg];

end

