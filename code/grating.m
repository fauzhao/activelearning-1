imSize = 100;                           % image size: n X n
lamda = 10;                             % wavelength (number of pixels per cycle)
theta = randi(90,2,1);                        % grating orientation2
sigma = 10;                         % phase (0 -> 1)
trim = .005;                             % trim off gaussian values smaller than this
X = 1:imSize;                           % X is a vector from 1 to imageSize
X0 = (X / imSize) - .5;
[Xm, Ym] = meshgrid(X0, X0);


figure;
gabor = cell(2,1);
for side = 1:2
thetaRad = (theta(side) / 360) * 2*pi;       % convert theta (orientation) to radians
Xt = Xm * cos(thetaRad);                % compute proportion of Xm for given orientation
Yt = Ym * sin(thetaRad);                % compute proportion of Ym for given orientation
XYt = [ Xt + Yt ];                      % sum X and Y components
XYf = XYt * freq * 2*pi;                % convert to radians and scale by frequency
grating = sin( XYf + phaseRad);                   % make 2D sinewave
imagesc( grating, [-1 1] );                     % display
axis off; axis image;

s = sigma / imSize;
gauss = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* s^2)) ); % formula for 2D gaussian
gauss(gauss < trim) = 0;                 % trim around edges (for 8-bit colour displays)
gabor{side} = grating .* gauss;
end
imagesc( cat(2,gabor{1},gabor{1}), [-1 1] );                        % display
axis off; axis image;                    % use gray colormap
axis image; axis off; colormap gray(256);
set(gca,'pos', [0 0 1 1]);               % display nicely without borders
set(gcf, 'menu', 'none', 'Color',[.5 .5 .5]); % without background