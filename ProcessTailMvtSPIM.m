function [A,TailMvt,IndOnsetMvtCam,IndOffsetMvtCam,TimeCam,Tail,NumberOfMvt,ActivityTail,ActivityTailFinal] = ProcessTailMvtSPIM(TailOrigin,TimeCamOrigin,Thresh,DurationMvt,FusionMvt,MinStrength,Flag,Durmin)


Tail=TailOrigin;
TimeCam=TimeCamOrigin;

%% SUBSTRACTING BASELINE
Baseline=zeros(size(Tail));
for i=2:length(Tail)
    Baseline(i)=0.99*Baseline(i-1)+0.01*Tail(i);
end
Tail=Tail-Baseline;


%% THRESHOLDING ON TAIL MVT
a=diff(Tail);
% On calcule RDeltaP puis seuille sur ampl mvt
RDeltaP=zeros(size(Tail));
for i=7:length(Tail)-1
    RDeltaP(i)=0;
    for j=i-6:i
        RDeltaP(i)=RDeltaP(i)+abs(a(j))*exp(-(i-j)/2);
    end
end

TailActiveBrut=RDeltaP>Thresh;

Freq=sum(TailActiveBrut)/numel(TailActiveBrut);


%%  Grouping Mvt separated by less than 75ms:5ms*15

a=filter(ones(1,FusionMvt),1,TailActiveBrut)>0;
A=a;

IndOnset=find(diff(a)==1);
IndOffset=find(diff(a)==-1)-FusionMvt;

if IndOffset(1)<IndOnset(1)
    IndOnset=[1,IndOnset];
end

if IndOnset(end)>IndOffset(end)
    IndOffset=[IndOffset,numel(Tail)];
end

%% On ne retient le mvt que si duree >Durmin

TailActive=zeros(size(TailActiveBrut));
IndToRemove=[];

for i=1:numel(IndOffset)
    if IndOffset(i)-IndOnset(i)>Durmin
        TailActive(IndOnset(i):IndOffset(i))=1;
    else
        IndToRemove=[IndToRemove,i];
    end
end



IndOnset(IndToRemove)=[];
IndOffset(IndToRemove)=[];
numel(IndOffset);

clear TailMvt
TailMvt=[];

Tailabs=abs(Tail);


%% seuillage énergie
k=1;
ActivityTail=zeros(1,length(TailActive));

%RDeltaP//Tailabs ??

for i=1:length(IndOnset)
    if (sum(Tailabs(IndOnset(i):IndOffset(i)))./(length(IndOnset(i):IndOffset(i)))>MinStrength & (IndOnset(i)+DurationMvt)<numel(Tail))
        TailMvt(k,:)=Tail(IndOnset(i):IndOnset(i)+DurationMvt);
        ActivityTail(IndOnset(i):IndOffset(i))=5;
        IndOnsetMvtCam(k)=IndOnset(i);
        IndOffsetMvtCam(k)=IndOffset(i);
        k=k+1;
       % disp('Blablabla')
    end
end
NumberOfMvt=size(TailMvt,1);

%% TRACE DES SEUILLAGES SUCCESSIFS

L=length(Tail);

if Flag==1
    
    figure(1);
    
    p1=subplot(3,1,1);
%     compte=abs(RDeltaP-TailActiveBrut)>0;
%     N=sum(compte);
%     Prcnt=N/L;
%     disp(['Seuillage mouvement : ',num2str(N),' occurences éliminées, soit ', num2str(Prcnt), '%']);
    
    plot(TimeCam,RDeltaP,'b')
    hold on;
    plot(TimeCam,TailActiveBrut.*Tail,'r');
    title('seuillage RDeltaP');
    hold off
    
    
    
    p2=subplot(3,1,2);
    plot(TimeCam,Tail,'b')
    hold on;
    plot(TimeCam,TailActive.*Tail,'r');
    title('seuillage duree mvt');
    hold off
    
    
%     compte=abs(TailActiveBrut-TailActive)>0;
%     N=sum(compte);
%     Prcnt=N/L;
%     disp(['Seuillage durée mouvement : ',num2str(N),' occurences éliminées, soit ', num2str(Prcnt), '%']);
    
    p3=subplot(3,1,3);
    plot(TimeCam,RDeltaP,'b')
    hold on;
    plot(TimeCam,ActivityTail.*RDeltaP,'r');
    title('seuillage énergie');
    hold off
    
%     compte=abs(TailActive-ActivityTail)>0;
%     N=sum(compte);
%     Prcnt=N/L;
%     disp(['Seuillage énergie : ',num2str(N),' occurences éliminées, soit ', num2str(Prcnt), '%']);
    
    
    linkaxes([p1,p2,p3],'x')
    
end


%% TRACE DES PEIGNES D ACTIVITES


Onset=zeros(1,length(TailActive));
Onset(IndOnsetMvtCam)=5;
Offset=zeros(1,length(TailActive));
Offset(IndOffsetMvtCam)=5;

ActivityTailFinal=ActivityTail.*Tail./5;
seuilplus=ones(1,length(TailActive))*Thresh;
seuilmoins=-seuilplus;

if Flag==1
    figure;
    plot(TimeCam,Tail,'b');
    hold on
    %plot(TimeCam,ActivityTailFinal,'g');
    plot(TimeCam,ActivityTail,'r');
    hold off
    title('Final ActivityTail');
end

end
