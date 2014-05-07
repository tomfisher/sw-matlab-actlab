function newangle=repair_angle(original, threshold, warp)
% from Holger Junker
% OAM REVISIT: made some adaptations, ugly code

if ~exist('threshold', 'var'), threshold = 80; end;
if ~exist('warp', 'var'), warp = 180; end;


diffsig=[0 ;diff(original)];

negslopes=find(diffsig<-10);
posslopes=find(diffsig>10);
% negslopes=negslopes;
% posslopes=posslopes;

newangle=original;
%CHECK slopes:
newneg=[];
for i=1:length(negslopes)
    if original(negslopes(i)-1)> threshold & original(negslopes(i))<0
        newneg=[newneg negslopes(i)];
    end
end

newpos=[];
for i=1:length(posslopes)
    if original(posslopes(i))>0 & original(posslopes(i)-1)< -threshold
        newpos=[newpos posslopes(i)];
    end
end

if isempty(newpos) & isempty(newneg)
    newangle=original;
    return;
end

if isempty(newpos)
    newpos=length(original);
end

if isempty(newneg)
    newneg=length(original);
end


if newneg(1)<newpos(1)
    for i=1:length(newneg)
        posidx=newpos(find(newpos>newneg(i)));
        if isempty(posidx)
            posidx=length(original)+1;
            newangle(newneg(i): posidx-1)=newangle(newneg(i): posidx-1) + warp;
% figure;
% plot(diffsig);hold on;
% plot(newpos,0, 'rx');hold on;
% plot(newneg,0, 'gx');hold on;
% plot(original,'k');hold on;
% plot(newangle,'r');hold on;            
            return;
        end
        newangle(newneg(i): posidx-1)=newangle(newneg(i): posidx-1) + warp;
    end
else
    for i=1:length(newpos)
        negidx=newneg(find(newneg>newpos(i)));
        if isempty(negidx)
            negidx=length(original)+1;
            newangle(newpos(i): negidx-1)=newangle(newpos(i): negidx-1) - warp;
            return;
        end
        newangle(newpos(i): negidx-1)=newangle(newpos(i): negidx-1) - warp;
    end

    
end


% figure;
% %plot(diffsig);hold on;
% % plot(newpos,0, 'rx');hold on;
% % plot(newneg,0, 'gx');hold on;
% plot(original,'k');hold on;
% plot(newangle,'r');hold on;