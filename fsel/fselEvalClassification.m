function [acc] = fselEvalClassification(veLabel, veClass)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 20070419 Holger Harms, Wearable Computing Lab., ETH Zurich
%
% evalClassifier computes different metrics to compare classification 
% results.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% truePos = class labeled and classified
truePos = 0;
% falsePos = class not labeled but classified 
falsePos = 0;
% falseNeg = class labeled but not classified
falseNeg = 0;
% trueNeg = no class labeled and classified
trueNeg = 0;


for i=1:length(veLabel)
  if ( veLabel(i) == veClass(i) )
    % any class detected
    truePos = truePos + 1;
    tureNeg = trueNeg + 1;
  else
    % wrong classification or no result  
    falseNeg = falseNeg + 1;
    falsePos = falsePos + 1;
  end
end

% Die Sensitivität ist die Wahrscheinlichkeit, dass eine Krankheit erkannt wird.
% Die Spezifität ist die Wahrscheinlichkeit, dass es keinen Fehlalarm gibt.
% Die Relevanz ist die Wahrscheinlichkeit, dass die Person bei einer positiven Diagnose wirklich krank ist.
% Die Segreganz ist die Wahrscheinlichkeit, dass die Person gesund ist, wenn keine Krankheit erkannt wurde.
% Die Korrektklassifikationsrate ist die Wahrscheinlichkeit für eine richtige Diagnose.
% Die Falschklassifikationsrate  ist die Wahrscheinlichkeit für eine falsche Diagnose.


% sensitivity is the prob for detecting a class    
% sens = truePos / (truePos + falseNeg);
% specificity is th prob. for a 'false alarm'
% spec = trueNeg / (falsePos + trueNeg);

%fprintf('TruePos = %d\n', truePos );
%fprintf('TrueNeg = %d\n', trueNeg );
%fprintf('FalsePos = %d\n', falsePos );
%fprintf('FalseNeg = %d\n\n', falseNeg );

%fprintf('Sensitivity = %3.2f percent\n', sens*100 );
%fprintf('Specificity = %3.2f percent\n', spec*100 );

% sensitivität is the prob for detecting a class

acc = (truePos + trueNeg) / (truePos+trueNeg+falsePos+falseNeg);