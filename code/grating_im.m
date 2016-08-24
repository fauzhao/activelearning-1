sensor = 'bayes';
global keypress
game_over = 0;
troubleshooting = 1;
intro = 1;
a=act;
imSize = 1200;
num_trials = 100;
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
trial = 0;

while game_over==0;
    trial = trial+1;
    if trial<num_trials
        full_im = zeros(imSize,2*imSize);
        full_im = add_plus(full_im);
        figure(h);
        imagesc(full_im, [-1 1]);
        
        if intro==1
            figure(h);
            imagesc( full_im, [-1 1]);                        % display
            axis off; axis image;                    % use gray colormap
            axis image; axis off; colormap gray(256);
            set(gca,'pos', [0 0 1 1]);               % display nicely without borders
            set(gcf, 'menu', 'none', 'Color',[.5 .5 .5]); % without background
            
            
            game_text('intro',full_im,h)
            
            % pass = practice_run(h); %give 5 easy trials
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
                full_im = zeros(imSize,2*imSize);
                full_im = add_plus(full_im);
                figure(h);
                imagesc(full_im, [-1 1]);
                drawnow
                
            else
                game_text('practice error',full_im,h)
                
                pass = practice_run(h); %give 5 more easy trials
                
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
            intro = 0;
        end
        figure(h);
        imagesc( full_im, [-1 1]);
        
        % %     pause(rand*.5+.5);
        
        switch sensor
            case 'bayes'
                tic
                best_xn1 = getnext(a,'activelearning',-.5:.05:.5,contrast(1:trial-1),right_arrow_push(1:trial-1));
                disp(toc)
                contrast(trial) = best_xn1;
            case 'human'
                d1.stim=contrast(1:trial-1);
                d1.resp=right_arrow_push(1:trial-1);
                post=a.posterior(d1);
                [~, i] = max(post(:));
                [row,col]=ind2sub([size(post,1) size(post,2)],i);
                w_set = a.w_range(1):a.dw:a.w_range(2);
                w0 = w_set(row);
                w1 = w_set(col);
                
                x_set2 = -3:.05:3;
                pd = 1./(1+exp(-(w0 + w1*x_set2)));
                figure(side);
                hold off
                plot(x_set2,pd)
                hold on
                plot(d1.stim,d1.resp,'ok')
                set(gca,'xtick',[])
                ylim([-.1 1.1])
                
                [xn1,~] = ginput(1);
                contrast(trial) = xn1;
            case 'random'
                alc = (rand-.5);
                contrast(trial) = alc/2;
        end
        
        full_im = generate_stim(contrast(trial));
        figure(h);
        imagesc( full_im, [-1 1]);
        drawnow
        abort=0;
        keypress = [];
        set(h,'KeyPressFcn',@getkeypress)
        pause(1);
        
        if isempty(keypress)
            abort = 0;
        else
            abort = 1;
        end
        
        if abort==0
            
            full_im = zeros(imSize,2*imSize);
            full_im = add_plus(full_im);
            imagesc( full_im, [-1 1]);
            hold on
            plot(imSize,imSize/2,'og','MarkerFaceColor','g','MarkerSize',10)
            drawnow
            tic;
            
            waitforbuttonpress;
            reaction_time(trial) = toc;
            
            if strcmp('leftarrow',keypress) || strcmp('rightarrow',keypress)
                arrow_key_error(trial) = 0;
                if strcmp('rightarrow',keypress)
                    right_arrow_push(trial) = 1;
            full_im = zeros(imSize,2*imSize);
            full_im = add_plus(full_im);
            imagesc( full_im, [-1 1]);
                    drawnow
                else
                    right_arrow_push(trial) = 0;
                    hold on
            full_im = zeros(imSize,2*imSize);
            full_im = add_plus(full_im);
            imagesc( full_im, [-1 1]);
                    drawnow
                end
            else
                arrow_key_error(trial) = 1;
                abort = 1;
            trial = trial-1;
            hold on
            plot(imSize,imSize/2,'or','MarkerFaceColor','r','MarkerSize',10)
            drawnow
            pause(.5)
            text(begin_text(1),begin_text(2),['Please use arrow keys :('],...
                'Color','red','FontSize',2*font_size)
            text(button_text(1),button_text(2),'Press any key to continue.','Color','white','FontSize',font_size)
            waitforbuttonpress;
            
            full_im = zeros(imSize,2*imSize);
            full_im = add_plus(full_im);
            imagesc( full_im, [-1 1]);
            drawnow
            
            end
            
            if troubleshooting==1
                d1.stim=contrast(1:trial-1);
                d1.resp=right_arrow_push(1:trial-1);
                post=a.posterior(d1);
                x_set = -.7:.05:.7;
                diffE = a.diffentropy(x_set,d1);
                
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
            end
            
        elseif abort==1
            trial = trial-1;
            hold on
            plot(imSize,imSize/2,'or','MarkerFaceColor','r','MarkerSize',10)
            drawnow
            pause(.5)
            text(begin_text(1),begin_text(2),['Wait for stimulus to disappear before response :('],...
                'Color','red','FontSize',2*font_size)
            text(button_text(1),button_text(2),'Press any key to continue.','Color','white','FontSize',font_size)
            waitforbuttonpress;
            
            full_im = zeros(imSize,2*imSize);
            full_im = add_plus(full_im);
            imagesc( full_im, [-1 1]);
            drawnow
        end
        
            if abort==0
            save(fullfile(full_file_dir{1},['data_temp' num2str(numf+1)]),...
                'contrast','right_arrow_push','arrow_key_error','reaction_time')
            end
    else
        
        full_im = zeros(imSize,2*imSize);
        figure(h);
        imagesc(full_im, [-1 1]);
        
        game_text('game over',full_im,h)
        
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
        game_over = 1;
    end
end