% function [REC SPEC C] = fselEvalClassification(veLabel, veClass, nullClass )
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % (c) 20070419 Holger Harms, Wearable Computing Lab., ETH Zurich
% %
% % evalClassifier computes different metrics to compare classification 
% % results.
% %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % truePos = class labeled and classified
% truePos = 0;
% % falsePos = class not labeled but classified 
% falsePos = 0;
% % falseNeg = class labeled but not classified
% falseNeg = 0;
% % trueNeg = no class labeled and classified
% trueNeg = 0;
% 
% 
% for i=1:length(veLabel)
%   % test for no null class ('classified')
%   if ( veLabel(i) ~= nullClass )
%     if ( veLabel(i) == veClass(i) )
%       % any class detected
%       truePos = truePos + 1;
%     else
%       % wrong classification or no result  
%       falseNeg = falsePos + 1;
%     end
%   else % else veLabel(i) ~= nullClass
%     if ( veLabel(i) == veClass(i) )
%       % null class detected  
%       trueNeg = trueNeg + 1;
%     else
%       % class wrongly detected  
%       falsePos = falsePos + 1;
%     end
%   end
% end
% 
% 
% % Die Sensitivität ist die Wahrscheinlichkeit, dass eine Krankheit erkannt wird.
% % Die Spezifität ist die Wahrscheinlichkeit, dass es keinen Fehlalarm gibt.
% % Die Relevanz ist die Wahrscheinlichkeit, dass die Person bei einer positiven Diagnose wirklich krank ist.
% % Die Segreganz ist die Wahrscheinlichkeit, dass die Person gesund ist, wenn keine Krankheit erkannt wurde.
% % Die Korrektklassifikationsrate ist die Wahrscheinlichkeit für eine richtige Diagnose.
% % Die Falschklassifikationsrate  ist die Wahrscheinlichkeit für eine falsche Diagnose.
% 
% 
% % sensitivity is the prob for detecting a class RECALL   
% REC = truePos / (truePos + falseNeg);
% % specificity is th prob. for a 'false alarm'
% SPEC = trueNeg / (falsePos + trueNeg);
% 
% C=1
% %fprintf('TruePos = %d\n', truePos );
% %fprintf('TrueNeg = %d\n', trueNeg );
% %fprintf('FalsePos = %d\n', falsePos );
% %fprintf('FalseNeg = %d\n\n', falseNeg );
% 
% %fprintf('Sensitivity = %3.2f percent\n', sens*100 );
% %fprintf('Specificity = %3.2f percent\n', spec*100 );
% 
% % sensitivität is the prob for detecting a class
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %            Mutual Information between veLabel and veClass
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % X: veLabel
% % Y:veClass
% 
% % X=veLabel;
% % Y=veClass';
% % 
% % % joint probability
% % 
% % XY=[X Y];
% % [UniqueXY Last]=unique(sortrows(XY),'rows');
% % AnzUniqueXY=Last-[0;Last(1:(length(Last)-1))];
% % 
% % PXY=AnzUniqueXY/length(XY);
% % 
% % % Probability of veLabel and veClass
% % 
% % [UniqueX Last]=unique(sort(X),'last');
% % AnzUniqueX=Last-[0;Last(1:(length(Last)-1))];
% % PX=AnzUniqueX/length(X);
% % 
% % [UniqueY Last]=unique(sort(Y),'last');
% % AnzUniqueY=Last-[0;Last(1:(length(Last)-1))];
% % PY=AnzUniqueY/length(Y);
% % 
% % 
% % for i=1:length(UniqueXY)
% %         C=PXY(i)*log2(PXY(i)/PX(UniqueX==UniqueXY(i,1))/PY(UniqueY==UniqueXY(i,2)));
% % end
% 















