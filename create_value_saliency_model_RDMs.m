% this script creates single-subject model (theoretical) RDMs of the value
% model and the saliency model

load('....mat')  
% This is a pre-processed .mat file containing the mean pleasantness
% ratings for each of the 32 conditions (16 cue conditions and 16 outcome
% conditions) from each subject

sub_ind = [1:9 11:18];


for z = 1:length(sub_ind)
    valueModelRDMs{z} = zeros(32,32);
    saliencyModelRDMs{z} = zeros(32,32);
    condIdentityModelRDMs{z} = zeros(32,32);
    gainLossModelRDMs{z} = zeros(32,32);
    
    % cue conditions
    for i = 1:16
        type1 = ceil(i/4);
        level1 = mod(i,4);
        if level1 == 0
            level1 = 4;
        end
        
        for ii = 1:16
            type2 = ceil(ii/4);
            level2 = mod(ii,4);
            if level2 == 0
                level2 = 4;
            end
            
            valueModelRDMs{z}(i,ii) = abs(meanRateCueBySub(type1,level1,sub_ind(z))-meanRateCueBySub(type2,level2,sub_ind(z)));
            saliencyModelRDMs{z}(i,ii) = abs((meanRateCueBySub(type1,level1,sub_ind(z))-5)^2 - (meanRateCueBySub(type2,level2,sub_ind(z))-5)^2);
            if (type1 == type2)
                condIdentityModelRDMs{z}(i,ii) = 0;
            else
                condIdentityModelRDMs{z}(i,ii) = 1;
            end
            if (mod(type1,2) == mod(type2,2))
                gainLossModelRDMs{z}(i,ii) = 0;
            else
                gainLossModelRDMs{z}(i,ii) = 1;
            end
        end
        
        for ii = 17:32   % cue vs. outcome
            type2 = ceil((ii-16)/4);
            level2 = mod((ii-16),4);
            if level2 == 0
                level2 = 4;
            end
            
            valueModelRDMs{z}(i,ii) = abs(meanRateCueBySub(type1,level1,sub_ind(z))-meanRateOutBySub(type2,level2,sub_ind(z)));
            saliencyModelRDMs{z}(i,ii) = abs((meanRateCueBySub(type1,level1,sub_ind(z))-5)^2 - (meanRateOutBySub(type2,level2,sub_ind(z))-5)^2);
            if (type1 == type2)
                condIdentityModelRDMs{z}(i,ii) = 0;
            else
                condIdentityModelRDMs{z}(i,ii) = 1;
            end
            if (mod(type1,2) == mod(type2,2))
                gainLossModelRDMs{z}(i,ii) = 0;
            else
                gainLossModelRDMs{z}(i,ii) = 1;
            end
        end
    end
    
    % outcome conditions
    for i = 17:32
        type1 = ceil((i-16)/4);
        level1 = mod((i-16),4);
        if level1 == 0
            level1 = 4;
        end
        
        for ii = 1:16   % outcome vs. cue
            type2 = ceil(ii/4);
            level2 = mod(ii,4);
            if level2 == 0
                level2 = 4;
            end
            
            valueModelRDMs{z}(i,ii) = abs(meanRateOutBySub(type1,level1,sub_ind(z))-meanRateCueBySub(type2,level2,sub_ind(z)));
            saliencyModelRDMs{z}(i,ii) = abs((meanRateOutBySub(type1,level1,sub_ind(z))-5)^2 - (meanRateCueBySub(type2,level2,sub_ind(z))-5)^2);
            if (type1 == type2)
                condIdentityModelRDMs{z}(i,ii) = 0;
            else
                condIdentityModelRDMs{z}(i,ii) = 1;
            end
            if (mod(type1,2) == mod(type2,2))
                gainLossModelRDMs{z}(i,ii) = 0;
            else
                gainLossModelRDMs{z}(i,ii) = 1;
            end
        end
        
        for ii = 17:32   
            type2 = ceil((ii-16)/4);
            level2 = mod((ii-16),4);
            if level2 == 0
                level2 = 4;
            end
            
            
            valueModelRDMs{z}(i,ii) = abs(meanRateOutBySub(type1,level1,sub_ind(z))-meanRateOutBySub(type2,level2,sub_ind(z)));
            saliencyModelRDMs{z}(i,ii) = abs((meanRateOutBySub(type1,level1,sub_ind(z))-5)^2 - (meanRateOutBySub(type2,level2,sub_ind(z))-5)^2);
            if (type1 == type2)
                condIdentityModelRDMs{z}(i,ii) = 0;
            else
                condIdentityModelRDMs{z}(i,ii) = 1;
            end
            if (mod(type1,2) == mod(type2,2))
                gainLossModelRDMs{z}(i,ii) = 0;
            else
                gainLossModelRDMs{z}(i,ii) = 1;
            end
        end
    end
      
end