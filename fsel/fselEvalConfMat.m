function fselEvalConfMat(veLabel, veClass , N)

%  
% fselEvalConfMat(veLabel, veClass ,N)
% 
% plots 3-dimensional confusion matrix
%
% Input:    veLabel : real label 
%           veClass : classified label
%           N       : number of figure (default 1)
%
% Output:   grapical plot.
%
% (c) 20070510 Holger Harms, Wearable Computing Lab., ETH Zurich
%

classes = max(unique(veLabel));

% confusion matrix (rows are inputs, colums are outputs)
maCon = zeros(classes,classes);
for i = 1:length(veLabel)
  maCon(veClass(i),veLabel(i))  = maCon(veClass(i),veLabel(i)) + 1/sum(veLabel==veLabel(i));
end

% print matrix
figure(N)
bar3(1:classes,maCon)

title('Confusion matrix after feature selection')
xlabel('Real Label')
ylabel('Classified Label') 

