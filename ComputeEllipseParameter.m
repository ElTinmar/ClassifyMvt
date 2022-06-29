function [Center,Theta,Dir,L,l] = ComputeEllipseParameter(m00,m10,m01,mu11,mu20,mu02)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
I1=((mu20+mu02)+sqrt((mu20-mu02)^2+4*mu11^2))/2;
I2=((mu20+mu02)-sqrt((mu20-mu02)^2+4*mu11^2))/2;
Center=[m10/m00;m01/m00];
Theta=0.5*atan2(2*mu11,mu20-mu02);
Dir=[cos(Theta+pi/2),sin(Theta+pi/2)];

l=2*sqrt(I2/m00);
L=2*sqrt(I1/m00);
% On a aussi: L=m00/(pi*l); (calcul de l'aire)
end

