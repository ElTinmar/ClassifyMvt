function [Membership,Bias,Outlier] = ClassifyMvtkNN(TailMvt,LabeledMvt,kNN,exp)

TailMvt=TailMvt(1:30);

% Symetrize TailMvt:
t=TailMvt-TailMvt(1);
Bias=sum(t.^3);
if sum(t.^3)<0
    TailMvt=-TailMvt;
    t=-t;
end

% Test Outlier:
Small=max(abs(TailMvt)')<0.08;
NormTail=TailMvt./norm(TailMvt);
Diff=max(diff(NormTail))>0.35;

if (Diff || Small)
    Outlier=1;
else
    Outlier=0;
end

%% Compute DistTo LabeledMvt:

if isempty(LabeledMvt.DistToLabeled)
%     NShape=7.2237e+03;%norm(DistShape)
%     NEnergy=371;% norm(DistEnergy)
%     % Compute 'difference' in shape:
%     t=TailMvt/std(TailMvt);
%     DistShape= DTWFunc(t,bsxfun(@rdivide,LabeledMvt.Tail,std(LabeledMvt.Tail')'));
%     % Compute 'difference' in energy:
%     DistEnergy=EnergyContrast(TailMvt,LabeledMvt.Tail);
%     LabeledMvt.DistToLabeled=DistEnergy/NEnergy+DistShape/NShape;
    Dist=DTWFunc(t,LabeledMvt.Tail);
    LabeledMvt.DistToLabeled=Dist;
    
    
end

%% Initialize by computing Membership of Labeled Neuron:
% Ref:http://www.researchgate.net/profile/Huiling_Chen/publication/232957416_An_efficient_diagnosis_system_for_detection_of_Parkinson's_disease_using_fuzzy_k-nearest_neighbor_approach/links/0c96051ab09fd153e7000000.pdf

if isempty(LabeledMvt.MembershipLabeled)

% LabeledMvt.Cat=IndCatTot(IndLabeled);
% LabeledMvt.DistLabeled=DistTot(IndLabeled,IndLabeled);

MembershipLabeled=nan(numel(LabeledMvt.Cat),5);

for i=1:numel(LabeledMvt.Cat)
    
    Dist=LabeledMvt.DistLabeled(i,:);
    [d,id]=sort(Dist,'ascend');
    d=d(2:kNN+1);
    id=id(2:kNN+1);
    for c=1:5
        nc=numel(find(LabeledMvt.Cat(id)==c));
        
        if LabeledMvt.Cat(i)==c
        MembershipLabeled(i,c)=0.51+(nc/kNN)*0.49;
        else
        MembershipLabeled(i,c)=(nc/kNN)*0.49;
        end
    
    end
    
end

else
    MembershipLabeled=LabeledMvt.MembershipLabeled;
end

%% Compute Membership of TailMvt:

[d,id]=sort(LabeledMvt.DistToLabeled,'ascend');

d=d(1:kNN);
id=id(1:kNN);

for c=1:5
    Membership(c)=sum(MembershipLabeled(id,c)./d.^(2/(exp-1)));
end
Membership=Membership/sum(Membership);



