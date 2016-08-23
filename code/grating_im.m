a=act;
imSize = 1200;
num_trials = 15;
font_size = 20;
begin_text = [imSize/3 imSize/4];
button_text = [2*imSize/3 3*imSize/4];

contrast = nan(num_trials,1);
right_arrow_push = nan(num_trials,1);
arrow_key_error = nan(num_trials,1);
reaction_time = nan(num_trials,1);

h = figure('units','normalized','outerposition',[0 0 1 1]);
side = figure;

prompt = {'Enter your name:'};
dlg_title = 'Input';
num_lines = 1;
nom = inputdlg(prompt,dlg_title,num_lines,{'Joe_Shmo'});

base_file_dir = '/Users/Laura/code/activelearning/data';
full_file_dir = fullfile(base_file_dir,nom);
if ~exist(full_file_dir{1},'dir')
    mkdir(full_file_dir{1})
end

numf = size(dir([full_file_dir{1} '/*.mat']),1);

for trial = 1:num_trials
    full_im = zeros(imSize,2*imSize);
    full_im = add_plus(full_im);
    figure(h);
    imagesc(full_im, [-1 1]);
    
    if trial==1
    figure(h);
        imagesc( full_im, [-1 1]);                        % display
        axis off; axis image;                    % use gray colormap
        axis image; axis off; colormap gray(256);
        set(gca,'pos', [0 0 1 1]);               % display nicely without borders
        set(gcf, 'menu', 'none', 'Color',[.5 .5 .5]); % without background
        
        
        text(begin_text(1),begin_text(2),['Welcome to our game! We are going to test your ability ' ...
            'to compare the contrast of two grating stimuli.'],'Color','white','FontSize',font_size)
        text(button_text(1),button_text(2),'Press any key to continue.','Color','white','FontSize',font_size)
        waitforbuttonpress;
        
    figure(h);
        imagesc( full_im, [-1 1]);
        message = sprintf(['Focus on the + at the center of the screen and ' ...
            'push the left or right arrows to indicate which stimulus has higher contrast.']);
        text(begin_text(1),begin_text(2),message,...
            'Color','white','FontSize',font_size)
        
        text(button_text(1),button_text(2),['Press any key to start with some easy ' ...
            'example trials to practice before we begin.'],'Color','white','FontSize',font_size)
        waitforbuttonpress;
        
%         pass = practice_run(h); %give 5 easy trials
        pass = 1;
        
        full_im = zeros(imSize,2*imSize);
        full_im = add_plus(full_im);
    figure(h);
        imagesc(full_im, [-1 1]);
        
        if pass==1
            message = sprintf(['Yay! Good job. Now lets get started for real.']);
            text(begin_text(1),begin_text(2),message,...
                'Color','white','FontSize',font_size)
            
            text(button_text(1),button_text(2),'Press any key to continue.','Color','white','FontSize',font_size)
            waitforbuttonpress;
            
        else
            message = sprintf('Uh oh... Lets have another practice run. Remember to push the arrow for the side with greater contrast');
            text(begin_text(1),begin_text(2),message,...
                'Color','white','FontSize',font_size)
            
            text(button_text(1),button_text(2),'Press any key to continue.','Color','white','FontSize',font_size)
            waitforbuttonpress;
            
            pass = practice_run(h); %give 5 easy trials
            
            
            full_im = zeros(imSize,2*imSize);
            full_im = add_plus(full_im);
    figure(h);
            imagesc(full_im, [-1 1]);
            
            message = sprintf('alright...good enough. lets get started');
            text(begin_text(1),begin_text(2),message,...
                'Color','white','FontSize',font_size)
            
            text(button_text(1),button_text(2),'Press any key to continue.','Color','white','FontSize',font_size)
            waitforbuttonpress;
        end
        
    end
    figure(h);
    imagesc( full_im, [-1 1]);
    
% %     pause(rand*.5+.5);
    
    best_xn1 = getnext(a,'activelearning',-5:.05:5,contrast(1:trial-1),right_arrow_push(1:trial-1));
    contrast(trial) = best_xn1
%     alc = (rand-.5);
%     contrast(trial) = alc/2;
%     
    full_im = generate_stim(contrast(trial));
    figure(h);
    imagesc( full_im, [-1 1]);
    tic;
    
    global keypress
    set(h,'KeyPressFcn',@getkeypress)
    waitforbuttonpress;
    reaction_time(trial) = toc;
    
    if strcmp('leftarrow',keypress) || strcmp('rightarrow',keypress)
        arrow_key_error(trial) = 0;
        if strcmp('rightarrow',keypress)
            right_arrow_push(trial) = 1;
        else
            right_arrow_push(trial) = 0;
        end
    else
        arrow_key_error(trial) = 1;
        right_arrow_push(trial) = 0;
    end
    d1.stim=contrast(1:trial);
    d1.resp=right_arrow_push(1:trial);
    post=a.posterior(d1);
    x_set = -.7:.05:.7;
    diffE = a.diffentropy(x_set,d1);
    newPostEntVal = -nansum(nansum(post.*log(post)))*a.dw^2
    
    [~, i] = max(post(:));
    [row,col]=ind2sub([size(post,1) size(post,2)],i);
    w_set = a.w_range(1):a.dw:a.w_range(2);
    w0 = w_set(row);
    w1 = w_set(col);
    
    x_set2 = -5:.05:5;
    pd = 1./(1+exp(-(w0 + w1*x_set2)));
    figure(side);
    subplot(1,2,1)
    hold on
    plot(x_set2,pd)
    subplot(1,2,2)
    hold on
    plot(x_set,diffE)
    
save(fullfile(full_file_dir{1},['data_temp' num2str(numf+1)]),...
    'contrast','right_arrow_push','arrow_key_error','reaction_time')
end

full_im = zeros(imSize,2*imSize);
    figure(h);
imagesc(full_im, [-1 1]);

message = sprintf('You are done! Thanks for contributing to science!!');
text(begin_text(1),begin_text(2),message,'Color','white','FontSize',font_size)

text(button_text(1),button_text(2),'Press any key to exit.','Color','white','FontSize',font_size)
waitforbuttonpress;

file_num = size(dir('/Users/Laura/code/activelearning/data/data_temp*'),1);
load(fullfile(base_file_dir,['data_temp' num2str(file_num)]),...
    'contrast_all','right_arrow_push_all','arrow_key_error_all','reaction_time_all');

close all
figure;
hold on
plot(contrast_all,right_arrow_push_all,'ok','lineWidth',2,'MarkerSize',10)
plot(contrast,right_arrow_push,'or','MarkerFaceColor','r','MarkerSize',10)
ylim([-.2 1.2])
xlim([-.8 .8])
ylabel('right choices')
xlabel('contrast difference (right - left)')
plot([0 0],[-.2 1.2],'--k')
legend('your peers','you','location','southeast')
large_text

contrast_all = cat(1,contrast_all,contrast);
right_arrow_push_all = cat(1,right_arrow_push_all,right_arrow_push);
arrow_key_error_all = cat(1,arrow_key_error_all,arrow_key_error);
reaction_time_all = cat(1,reaction_time_all,reaction_time);

numf = size(dir([base_file_dir '/*.mat']),1);
save(fullfile(base_file_dir,['data_temp' num2str(numf+1)]),...
    'contrast_all','right_arrow_push_all','arrow_key_error_all','reaction_time_all')