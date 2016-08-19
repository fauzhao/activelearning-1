function pass = practice_run(h)
imSize = 1200;  
num_trials = 5;
contrast = 2*(rand(1,num_trials)-.5);
right_arrow_push = nan(1,num_trials);
arrow_key_error = nan(1,num_trials);

for t = 0:num_trials-1
full_im = zeros(imSize,2*imSize);
full_im = add_plus(full_im);
imagesc( full_im, [-1 1]);
axis off; axis image;                    % use gray colormap
axis image; axis off; colormap gray(256);
set(gca,'pos', [0 0 1 1]);               % display nicely without borders
set(gcf, 'menu', 'none', 'Color',[.5 .5 .5]); % without background

pause(rand*.5+.5);

trial = t+1;
full_im = generate_stim(contrast(:,trial));
imagesc( full_im, [-1 1]);

global keypress
set(h,'KeyPressFcn',@getkeypress)
waitforbuttonpress;

if strcmp('leftarrow',keypress) || strcmp('rightarrow',keypress)
    arrow_key_error(trial) = 0;
    if strcmp('rightarrow',keypress) 
    right_arrow_push(trial) = 1;
    else
    right_arrow_push(trial) = 0;
    end
else
    arrow_key_error(trial) = 1;
end
end

pass = sum(arrow_key_error)<=1 & sum(right_arrow_push ~= (contrast>0))<=1;
end