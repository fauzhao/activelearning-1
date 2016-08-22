classdef actMH
    properties        
    end
    
    properties (Access=private)
    end
    
    methods (Access=public)
        function obj = actMH
        end
        
        function est_p = posterior(obj,data)
            %Uses metroplis hastings MCMC
            %TODO: Proposal dist for lapse rate is asymmetric!! needs to
            %fix?
            numIter = 2000;
            
            w_prev = [0 0 0];            
            est_p = nan(numIter,3);
            
%             figure;
            for iter = 1:numIter   
                w_next = [0 0 0];
                w_next(1:2) = mvnrnd(w_prev(1:2),eye(2)*10);
                w_next(3) = betarnd(1/(2-w_prev(3)),2);
                
                alpha = obj.likelihood(w_next,data)*obj.prior(w_next) / ...
                        (obj.likelihood(w_prev,data)*obj.prior(w_prev));

                if alpha >= 1 || binornd(1,alpha)==1
                    w_prev = w_next;
                end
                
                est_p(iter,:) = w_prev;
                
            end
            
        end
        
        function p = prior(~,w)
            p = mvnpdf(w(1:2),[0 0],eye(2)*10);
            %uniform prior on lapse rate so doesn't modify the probability
%             p = p*betapdf(w(3),1,1); 
        end
        
        function l = likelihood(~,w,data)
            stim = data.stim; %must be column vector
            resp = data.resp; %must be column vector
            
            numTrials = length(stim);
            l = nan(numTrials,1);
            for t = 1:numTrials
                pGO = 0.5*w(3) + (1 - 0.5*w(3))./(1+exp(-(w(1) + w(2)*stim(t))));
                l(t,1) = pGO*resp(t) + (1-pGO)*(1-resp(t));
            end
            l = prod(l);
        end
        
    end
    
    
end