
%Load in VOI and GLM

% load VOI (needs to be converted from .voi file to a .mat file with the
% voxel locations first
load XXX
voi = reduced_vim.vimpsts;
voi(voi==0)=NaN;

% load GLM
glm = BVQXfile('C:\...glm');

%Extract BetaMaps; Extract VOI voxels; Run Principal Componenet Analysis;

count = 1;
for ii = [1:9,11:18]

    sub=(glm.GLMData.Subject(ii).BetaMaps);


    subpfc = zeros(size(sub)); 
    for jj = 1:size(sub,4) 
        subpfc(:,:,:,jj) = sub(:,:,:,jj).*voi;
    end
    
    %Extract voi voxels and vectorize
    
    for kk = 1:32 
        subpfc_temp = subpfc(:,:,:,kk);
        vecPFC(:,kk)=subpfc_temp(~isnan(subpfc_temp(:)));
    end
    
    %Run PCA (features = [# of voxels in the ROI] vox/betas; measures = 16 conditions)
    
    [coeff, score, latent, tsquared, explained] = pca(vecPFC');
    
    %Reconstruct components
    
    expl(:,count) = explained;
    pri1(count,:) = coeff(:,1)'*vecPFC;
    pri2(count,:) = coeff(:,2)'*vecPFC;
    pri3(count,:) = coeff(:,3)'*vecPFC;
    
    coeffAll(:,:,count) = coeff(:,1:3);

    count = count+1;
end

% generate average frequencies (across all subjects) within each bin
bin_range = -0.2:0.01:0.2;
PC1_loadings_hist = zeros(17,length(bin_range));
PC2_loadings_hist = zeros(17,length(bin_range));
PC3_loadings_hist = zeros(17,length(bin_range));
for i = 1:17
   
    hist1 = hist(coeffAll(:,1,i),bin_range);
    hist1 = hist1/sum(hist1);
    PC1_loadings_hist(i,:) = hist1;
    
    hist2 = hist(coeffAll(:,2,i),bin_range);
    hist2 = hist2/sum(hist2);
    PC2_loadings_hist(i,:) = hist2;
    
    hist3 = hist(coeffAll(:,3,i),bin_range);
    hist3 = hist3/sum(hist3);
    PC3_loadings_hist(i,:) = hist3;
    
end

% generate preliminary histograms of average distributions of loadings
subplot(3,1,1)
bar(-0.2:0.01:0.2,mean(PC1_loadings_hist),0.98)
ylim([0,0.25])
hold on;
errorbar(-0.2:0.01:0.2,mean(PC1_loadings_hist),std(PC1_loadings_hist)/sqrt(17),'.')
hold off
title('PC 1');

subplot(3,1,2)
bar(-0.2:0.01:0.2,mean(PC2_loadings_hist),0.98)
ylim([0,0.25])
hold on;
errorbar(-0.2:0.01:0.2,mean(PC2_loadings_hist),std(PC2_loadings_hist)/sqrt(17),'.')
hold off
title('PC 2');

subplot(3,1,3)
bar(-0.2:0.01:0.2,mean(PC3_loadings_hist),0.98)
ylim([0,0.25])
hold on;
errorbar(-0.2:0.01:0.2,mean(PC3_loadings_hist),std(PC3_loadings_hist)/sqrt(17),'.')
hold off
title('PC 3');


