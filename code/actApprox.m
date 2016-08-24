classdef actApprox
    properties
        metHastIter=5000;
    end
    
    properties (Access=private)
    end
    
    methods (Access=public)
        function obj = actApprox
        end
        
        function est_p = posterior(obj,data)
            %Uses metroplis hastings MCMC            
            w_prev = [0 0];
            est_p = nan(obj.metHastIter,2);
            
            for iter = 1:obj.metHastIter
                w_next = mvnrnd(w_prev,eye(2));
                
                alpha = obj.likelihood(w_next,data)*obj.prior(w_next) / ...
                    (obj.likelihood(w_prev,data)*obj.prior(w_prev));
                
                if alpha >= 1 || binornd(1,alpha)==1
                    w_prev = w_next;
                end
                
                est_p(iter,:) = w_prev;
            end
            
            est_p(1:round(obj.metHastIter/10),:) = []; %remove burn-in
        end
        
        function p = prior(~,w)
            p = mvnpdf(w(1:2),[0 0],eye(2)*50);
        end
        
        function l = likelihood(~,w,data)
            stim = data.stim; %must be column vector
            resp = data.resp; %must be column vector
            
            numTrials = length(stim);
            l = nan(numTrials,1);
            for t = 1:numTrials
                pGO = 1./(1+exp(-(w(1) + w(2)*stim(t))));
                l(t,1) = pGO*resp(t) + (1-pGO)*(1-resp(t));
            end
            l = prod(l);
        end
        
        function simulate(obj,trueW0,trueW1,numtrials)
            d1.stim = -1 + 2*rand(numtrials,1);
            d1.resp = binornd(1,1./(1+exp(-(trueW0 + trueW1*d1.stim))));
            
            post = obj.posterior(d1);
            
            obj.plotPsych(d1);
        end
        
        
        
        function py = predict(~,newX,post)
            py=nan(length(newX),1);
            for xn = 1:length(newX)
                w = mean(post,1);
                phat = 1./(1 + exp(-(w(1) + w(2)*newX(xn))));
                py(xn) = nanmean(phat);
            end
        end
        
        function [py,ci] = predict_ci(~,newX,post)
            py=nan(length(newX),1);
            ci=nan(length(newX),2);
            for xn = 1:length(newX)
                w = mean(post,1);
                phat = 1./(1 + exp(-(w(1) + w(2)*newX(xn))));
                py(xn) = phat;
                
                phat = 1./(1 + exp(-(post(:,1) + post(:,2)*newX(xn))));
                ci(xn,:) = quantile(phat,[0.025 0.975]);
            end
        end
        
        function plotPsych(obj,data)
            post = obj.posterior(data);
            cvals = -5:0.05:5;
            [p,ci]=obj.predict_ci(cvals,post);
%             p=obj.predict(cvals,post);

            figure; axes; hold on;
            fill([cvals'; flipud(cvals')],[ci(:,1); flipud(ci(:,2))],[1 1 1]*0.95)
            plot(cvals,p); ylim([0 1]);
            plot(data.stim,data.resp,'ko');
        end
        
        function ent = diffent_approx(obj,xn1_list,data)
            %for a given x, sample from # of parameter values
            ent = nan(length(xn1_list),1); %initialize entrop
            est_w = posterior(obj,data);
            
            for xn1 = 1:length(xn1_list) %for each possible query calculate entropy reduction
                ent_ex_pred = nan(size(est_w,1),1); % calculate explicitly using (? also from the sampling) 
                ex_pred_ent = nan(size(est_w,1),1); % MCMC sampling over possible w to estimate
                
                for ind_w = 1:size(est_w,1)
                    py = obj.predict(xn1_list(xn1),est_w(ind_w,:));
                    ent_ex_pred(ind_w) = py;
                    ex_pred_ent(ind_w) = -( py*log(py) + (1-py)*log(1-py) ); 
                end   
                ex_pred_ent = mean(ex_pred_ent);
                ent_ex_pred = mean(ent_ex_pred); 
                ent_ex_pred =  -( ent_ex_pred*log(ent_ex_pred) + (1-ent_ex_pred)*log(1-ent_ex_pred) );
                
                ent(xn1) = ent_ex_pred - ex_pred_ent;
            end
            
%             plot(xn1_list,ent);
        end
        
        function best_xn1 = getnext(obj,method,xn1_test,old_stim,old_resp)
            switch(method)
                case 'activelearning' %Uses active learning to select xn+1
                    d1.stim = old_stim;
                    d1.resp = old_resp;
                    
                    %Function takes the current dataset (can be empty struct)
                    diffE = obj.diffent_approx(xn1_test,d1);
                    [~,idx] = max(diffE);
                    best_xn1 = xn1_test(idx);
                case 'random' %Just selects at random from the candidates
                    best_xn1 = randsample(xn1_test,1);
            end
        end
        
        
     function runactive(obj)
            %Start with initially small data-set and keep adding new
            %stimuli, checking that the entropy is decreasing over this
            %process
            warning('Only works up to about 1000 trials due to numerical instability');
            
            true_w0 = 0;
            true_w1 = 10;
            
            f = figure;
            s(1) = subplot(3,2,1);
            s(2) = subplot(3,2,2);
            s2 = subplot(3,1,2);
            s3(1) = subplot(3,2,5);
            s3(2) = subplot(3,2,6);
                        
            postEnt = []; 
            
            methods = {'random','activelearning'};
            
            stim = cell(1,length(methods));
            resp = cell(1,length(methods));
            
%             xn1_test = linspace(-1,1,10);
            xn1_test = linspace(-1,1,40);
            for i = 1:1200
                
                newPost=[];
                for m = 1:length(methods)
                    xn1 = obj.getnext(methods{m},xn1_test,stim{m},resp{m});
                    
                    stim{m} = [stim{m}; xn1];
                    resp{m} = [resp{m}; binornd(1,1./(1+exp(-(true_w0 + true_w1*xn1))))];
                    
                    %Measure differential entropy of the new posterior
                    newPost = obj.posterior(struct('stim',stim{m},'resp',resp{m}));

%                     newPostEntVal = -nansum(nansum(newPost(:,:,m).*log(newPost(:,:,m))))*obj.dw^2;
%                     postEnt(i,m) = std(newPost(:,1));
%                     [v,d] = eig(cov(newPost));
%                     postEnt(i,m) = d(end,end);
                      postEnt(i,m) = log(det(cov(newPost)));
%                     
%                     imagesc(s(m),obj.w0,obj.w1,newPost(:,:,m)); 
                    plot(s(m),newPost(:,1),newPost(:,2),'.','markersize',20);
%                     xlabel('w0','w1');
%                     hist3(s(m),newPost,[1 1]*30);
%                     hold(s(m),'on'); plot(s(m),true_w0,true_w1,'k+'); 
%                     hold(s(m),'off');
                    hist(s3(m),stim{m},40);
                end
                
                set(s,'xlim',[-1 1]*15,'ylim',[-1 1]*15);

                plot(s2,postEnt); xlabel('Iter');
                drawnow;
             
                
            end
        end
        
    end
    
    
end