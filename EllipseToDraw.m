function [X Y] = EllipseToDraw(xc, yc, a, b, angle, steps)
%# This functions returns points to draw an ellipse
%#
%#  @param x     X coordinate
%#  @param y     Y coordinate
%#  @param a     Semimajor axis
%#  @param b     Semiminor axis
%#  @param angle Angle of the ellipse (in degrees)
%#

error(nargchk(5, 6, nargin));
if nargin<6, steps = 36; end
%
%     beta = -angle * (pi / 180);
%     sinbeta = sin(beta);
%     cosbeta = cos(beta);
%
%     alpha = linspace(0, 360, steps)' .* (pi / 180);
%     sinalpha = sin(alpha);
%     cosalpha = cos(alpha);
%
%     X = x + (a * cosalpha * cosbeta - b * sinalpha * sinbeta);
%     Y = y + (a * cosalpha * sinbeta + b * sinalpha * cosbeta);
%
%     if nargout==1, X = [X Y]; end

phi = linspace(0,2*pi,steps);
cosphi = cos(phi);
sinphi = sin(phi);

xbar = xc;
ybar = yc;

theta = pi*angle/180;
R = [ cos(theta)   -sin(theta)
    sin(theta)   cos(theta)];

xy = [a*cosphi; b*sinphi];
xy = R*xy;
X = xy(1,:) + xbar;
Y = xy(2,:) + ybar;
end