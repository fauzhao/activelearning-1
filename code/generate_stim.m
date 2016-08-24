function full_im = generate_stim(contrast)

%% parameter settings
imSize = 1200;                 % image size: n X n - has to be even number
freq = 10;                     % cycles
sigma = 1/10;                  % phase (0 -> 1)
trim = .005;                   % trim off gaussian values smaller than this
X = 1:imSize;
null_stim = .3;

%% orientation gratings
X0 = (X / imSize) - .5;
[Xm, Ym] = meshgrid(X0, X0);

thetaRad = rand * 2*pi;                 % convert theta (orientation) to radians
Xt = Xm * cos(thetaRad);                % compute proportion of Xm for given orientation
Yt = Ym * sin(thetaRad);                % compute proportion of Ym for given orientation
XYt = [ Xt + Yt ];                      % sum X and Y components
XYf = XYt * freq * 2*pi;                % convert to radians and scale by frequency

%% generate real stimulus
grating = (.3+abs(contrast))*sin( XYf + pi);

gauss = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* sigma^2)) ); % formula for 2D gaussian
gauss(gauss < trim) = 0;                 % trim around edges (for 8-bit colour displays)
gabor = grating .* gauss;

%% generate null stimulus
null_grating = .3*sin( XYf + pi);

null_gauss = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* sigma^2)) ); % formula for 2D gaussian
null_gauss(null_gauss < trim) = 0;                 % trim around edges (for 8-bit colour displays)
null_gabor = null_grating .* null_gauss;

%% combine
if contrast>0
    full_im = cat(2,null_gabor,gabor);
else
    full_im = cat(2,gabor,null_gabor);
end
full_im = add_plus(full_im);
end