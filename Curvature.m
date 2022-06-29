function [Curv,Angle]=Curvature(BW,xOrigin,yOrigin,flag,img,lw)

color1=[0,0.5,0.8];
color2=[0.8,0.2,0];
% clear all
% close all
% clf
% clc
% load('BW.mat')
% flag=1;
% xOrigin=420;
% yOrigin=330;

Level_Max=2; % 2 ellipse;

% 
% [X Y] = EllipseToDraw(100,60,50,10,30,500);
% EllImage=zeros(size(BW));
% for i=1:length(X);
% EllImage(round(Y(i)),round(X(i)))=1;
% end
% BW=imfill(EllImage);
% if flag==1
%     figure(1)
%     imagesc(BW)
%     hold on
%     set(gca,'YDir','normal')
%     %[xOrigin,yOrigin] = ginput(1)
% end

[row,col,trash]=find(BW); % ! Colonne axe X et Ligne axe Y

X0=col;
Y0=row;
N0=length(trash);

% Compute Moments:
[m00,m10,m01,mu11,mu20,mu02] = ComputeMoment(X0,Y0,N0);

% Compute Ellipse Parameter:
[Center0,Theta0,Dir0,L0,l0] = ComputeEllipseParameter(m00,m10,m01,mu11,mu20,mu02);

Angle=Theta0;
if flag==1
    imagesc(img)
    colormap(gray)
    hold on
    [X_p Y_p] = EllipseToDraw(Center0(1),Center0(2),L0,l0,Theta0*180/pi,500); %(xc, yc, a, b, angle, steps)
    %plot(X_p,Y_p,'k','LineWidth',2)
end

Normal0=[cos(Theta0);sin(Theta0)]; % Vecteur grand axe

ApogeRostr=[Center0+L0*Normal0];
ApogeCaud=[Center0-L0*Normal0];

if norm(ApogeRostr-[xOrigin;yOrigin])>norm(ApogeCaud-[xOrigin;yOrigin])
    %disp('On tourne')
    Theta0=Theta0+pi;
    Normal0=[cos(Theta0);sin(Theta0)]; % Vecteur grand axe
    ApogeRostr=[Center0+L0*Normal0];
    ApogeCaud=[Center0-L0*Normal0];
end

V=[X0,Y0]-repmat([Center0(1),Center0(2)],numel(Y0),1);

Bissec=repmat(Normal0',numel(Y0),1);
D=dot(V',Bissec');
Ind=1:N0;

%% Head
[trash,ind]=find(D>0);
X1=X0(ind);
Y1=Y0(ind);
N1=numel(ind);
% Compute Moments:
[m00,m10,m01,mu11,mu20,mu02] = ComputeMoment(X1,Y1,N1);

% Compute Ellipse Parameter:
[Center1,Theta1,Dir1,L1,l1] = ComputeEllipseParameter(m00,m10,m01,mu11,mu20,mu02);

SmallAxes1=[-sin(Theta1);cos(Theta1)]; % Vecteur grand axe

if flag==1
    hold on
    [X_p Y_p] = EllipseToDraw(Center1(1),Center1(2),L1,l1,Theta1*180/pi,500);
    plot(X_p,Y_p,'Color',color2,'LineWidth',lw)
end

%% Tail
Ind(ind)=[];
ind=Ind;
X2=X0(ind);
Y2=Y0(ind);
N2=length(ind);
% Compute Moments:
[m00,m10,m01,mu11,mu20,mu02] = ComputeMoment(X2,Y2,N2);

% Compute Ellipse Parameter:
[Center2,Theta2,Dir2,L2,l2] = ComputeEllipseParameter(m00,m10,m01,mu11,mu20,mu02);

SmallAxes2=[-sin(Theta2);cos(Theta2)]; % Vecteur grand axe

if flag==1
    hold on
    [X_p Y_p] = EllipseToDraw(Center2(1),Center2(2),L2,l2,Theta2*180/pi,500);
    plot(X_p,Y_p,'Color',color1,'LineWidth',lw)
end

%% Compute Center of curvature

A=[SmallAxes1,-SmallAxes2];
b=Center2-Center1;

t=linsolve(A,b);

CenterCurv=Center1+t(1)*SmallAxes1;



if flag==1
plot(CenterCurv(1),CenterCurv(2),'*w','LineWidth',lw)
   
%line([CenterCurv(1),Center1(1)],[CenterCurv(2),Center1(2)],'Color',color2,'LineWidth',2)
%line([CenterCurv(1),Center2(1)],[CenterCurv(2),Center2(2)],'Color',color1,'LineWidth',2)
set(gca,'XTick',[],'YTick',[]);
set(gcf,'color','w');
set(gca,'DataAspectRatio',[1 1 1])
end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
Rmoy=mean(sqrt((X0-CenterCurv(1)).^2+(Y0-CenterCurv(2)).^2));

V=cross([Center1-CenterCurv;0],[Center2-CenterCurv;0]);

Sign=2*(V(3)>0)-1;
Curv=Sign*1/Rmoy;


if flag==1
    drawnow
end












