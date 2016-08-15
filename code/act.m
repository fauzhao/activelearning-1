classdef act
    properties
        data;
        dw = 0.1;
        w_real = [2 1];
        w_range = [-1 1]*4;
    end
    
    properties (Access=private)
        w0;
        w1;
    end
    
    methods
        function obj = act
            %generate fake behavioural data
            obj.data.stim = randn(100,1);
%             obj.data.stim = [ones(10,1)*-3; ones(10,1)*3];

            obj.data.resp = binornd(1,1./(1+exp(-(obj.w_real(1) + obj.w_real(2) *obj.data.stim))));
            plot(obj.data.stim,obj.data.resp,'o');
            
            obj.w0 = obj.w_range(1) : obj.dw : obj.w_range(2);
            obj.w1 = obj.w_range(1) : obj.dw : obj.w_range(2);
        end
       
        function l = likelihood(obj,data)
            stim = data.stim;
            resp = data.resp;
            
            l = nan(numel(obj.w0),numel(obj.w1));
            for w0idx = 1:numel(obj.w0)
                for w1idx = 1:numel(obj.w1)
                    w = [obj.w0(w0idx) obj.w1(w1idx)];
                    z = w(1) + w(2)*stim;
                    pGO = 1./(1+exp(-z));
                    lik = pGO.*(resp==1) + (1-pGO).*(resp==0);
                    l(w0idx,w1idx) = prod(lik);
                end
            end
        end
        
        function p = prior(obj)
            %prior on w is a 2D normal dist with mean 0 and spherical
            %covariance 
            p = nan(numel(obj.w0),numel(obj.w1));
            for w0idx = 1:numel(obj.w0)
                for w1idx = 1:numel(obj.w1)
                    w = [obj.w0(w0idx) obj.w1(w1idx)];
                    p(w0idx,w1idx) = mvnpdf(w,[0 0],eye(2)*0.5);
                end
            end
        end
        
        function p = posterior(obj,data)
            
            if isempty(data.stim)
                p = obj.prior;
            else
                pr = obj.prior;
                lik = obj.likelihood(data);      
                prlik = pr.*lik;
                p = prlik/sum(prlik(:)*obj.dw^2);
            end
            
        end
                        
        function plotfcn(obj,which,data)
            
            switch(which)
                case 'prior'
                    dist = obj.prior;
                case 'likelihood'
                    dist = obj.likelihood(data);
                case 'posterior'
                    dist = obj.posterior(data);
            end
                        
            [~,i]=max(dist(:)); %index of maximum value of distribution
            [row,col]=ind2sub([numel(obj.w0) numel(obj.w1)],i);
            
            imagesc(obj.w0,obj.w1,dist); set(gca,'ydir','normal'); 
            xlabel('W1'); ylabel('W0');
            title([which ' w0_{max}=' num2str(obj.w0(row)) ' w1_{max}=' num2str(obj.w1(col)) ]);
        end
        
        function run(obj)
            figure;
            subplot(2,3,1);
            obj.plotfcn('prior',obj.data); 
            
            subplot(2,3,2);
            obj.plotfcn('likelihood',obj.data); 
            
            subplot(2,3,3);
            obj.plotfcn('posterior',obj.data);
            
            subplot(2,1,2);
            post = obj.posterior(obj.data);
            plot(-5:.1:5,obj.predict(-5:.1:5,post));
            hold on;
            plot(obj.data.stim,obj.data.resp,'o');
            set(gcf,'color','w');
        end
        
        function py = predict(obj,newX,posterior)
            %Integrate over all w in the posterior to calculate the
            %prediction
            [W0,W1] = meshgrid(obj.w0,obj.w1);
            
            py=[];
            for xn = 1:length(newX)
                phat = obj.dw * obj.dw * posterior./(1+exp(-(W0' + W1'*newX(xn))));
                py(xn) = sum(phat(:));
            end            
        end
        
        function h = diffentropy(obj,xn1_list,data)
            %Entropy contains yn+1 but we don't know the value so let's take
            %expectation of the entropy over all possible yn+1
            old_post = obj.posterior(data);
                        
            for xn1 = 1:length(xn1_list)
                %Calculate new posterior including extra datapoint
                
                ch = []; py = [];
                for yn1 = [1 0]
                    d2 = obj.data;
                    d2.stim = [d2.stim; xn1_list(xn1)];
                    d2.resp = [d2.resp; yn1];

                    %calculate new posterior
                    new_post = obj.posterior(d2);
                    
                    %calculate predictive dist
                    p = obj.predict(xn1_list(xn1),old_post);
                    if yn1==0
                        p = 1-p;
                    end
                    py = [py; p];
                    
                    ent = -new_post.*log(new_post)*obj.dw^2;
                    ch = [ch; nansum(ent(:))];
                end
                
                h(xn1) = ch'*py;
            end
        end
        
        function runactive(obj)
            %Start with initially small data-set and keep adding new
            %stimuli, checking that the entropy is decreasing over this
            %process
            
            d1.stim = [];
            d1.resp = [];
            
            postEnt = [];
            while true
%                 xn1_test = linspace(-5,5,11); 
                xn1_test = -5 + 10*rand(1,11);
                
                
                diffE = obj.diffentropy(xn1_test,d1);
                [~,idx] = min(diffE);
                xn1 = xn1_test(idx);
                disp(xn1);
                
                d1.stim = [d1.stim; xn1];
                d1.resp = [d1.resp; binornd(1,1./(1+exp(-(obj.w_real(1) + obj.w_real(2) *xn1))))];
                
                newPost = obj.posterior(d1);
                newPostEntVal = -nansum(nansum(newPost.*log(newPost)))*obj.dw^2;
%                 disp(newPostEnt);
                postEnt = [postEnt; newPostEntVal];
                
%                 plot(postEnt); drawnow;
%                 hist(d1.stim,11); drawnow; 
%                 plot(xn1_test,diffE); drawnow;
%                 disp(xn1);
                imagesc(obj.w0,obj.w1,newPost); drawnow;
%                 if mod(length(d1.stim),10)==0
%                     keyboard;
%                 end
            end
        end
        
        function best_xn1 = bestnext(obj,xn1_test,old_stim,old_resp)
            d1.stim = old_stim;
            d1.resp = old_resp;
            
            %Function takes the current dataset (can be empty struct)
            diffE = obj.diffentropy(xn1_test,d1);
            [~,idx] = min(diffE);
            best_xn1 = xn1_test(idx);
        end
    end
    
    
end