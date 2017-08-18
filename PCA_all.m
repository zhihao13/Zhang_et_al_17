% This script performs the PCA in the Zhang et al., 2017 paper on value,
% saliency, and category encoding in the human brain

% Related Figures: Figure 7, Supplementary Figure 6




%Load VOI and GLM files

% load VOI file (as .mat files)
load C:\XXX
voi = reduced_vim.vimpsts;
voi(voi==0)=NaN;

% load GLM file (generated with NeuroElf or BrainVoyager)
glm = BVQXfile('C:\XXX.glm');


%Extract BetaMaps; Extract VOI voxels; Run Principal Componenet Analysis;
count = 1;
for ii = [1:9,11:18]

    sub=(glm.GLMData.Subject(ii).BetaMaps);


    subpfc = zeros(size(sub)); 
    for jj = 1:size(sub,4)
        subpfc(:,:,:,jj) = sub(:,:,:,jj).*voi;
    end
    
    %Extract voi voxels and vectorize
    
    for kk = 1:16 
        subpfc_temp = subpfc(:,:,:,kk);
        vecPFC(:,kk)=subpfc_temp(~isnan(subpfc_temp(:)));
    end
    
    %Run PCA (features = total # of voxels/betas; measures = 16 conditions)
    
    [coeff, score, latent, tsquared, explained] = pca(vecPFC');
    
    %Reconstruct components
    
    expl(:,count) = explained;
    pri1(count,:) = coeff(:,1)'*vecPFC;
    pri2(count,:) = coeff(:,2)'*vecPFC;
    pri3(count,:) = coeff(:,3)'*vecPFC;
    
    coeffAll(:,:,count) = coeff(:,1:3);

    count = count+1;
end

% calcualte average frequencies (across subjects) in each bin of loading coefficients
bin_range = -0.25:0.01:0.25;
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

% save average distribution of loading coefficients
PC1_loadings_means = [-0.25:0.01:0.25;mean(PC1_loadings_hist);std(PC1_loadings_hist)/sqrt(17)]';
save PC1_loadings_means
PC2_loadings_means = [-0.25:0.01:0.25;mean(PC2_loadings_hist);std(PC2_loadings_hist)/sqrt(17)]';
save PC2_loadings_means
PC3_loadings_means = [-0.25:0.01:0.25;mean(PC3_loadings_hist);std(PC3_loadings_hist)/sqrt(17)]';
save PC3_loadings_means

% generate average histograms for PCs 1, 2, and 3
subplot(3,1,1)
bar(-0.25:0.01:0.25,mean(PC1_loadings_hist),0.98)
ylim([0,0.25])
hold on;
errorbar(-0.25:0.01:0.25,mean(PC1_loadings_hist),std(PC1_loadings_hist)/sqrt(17),'.')
hold off
title('PC 1')

subplot(3,1,2)
bar(-0.25:0.01:0.25,mean(PC2_loadings_hist),0.98)
ylim([0,0.25])
hold on;
errorbar(-0.25:0.01:0.25,mean(PC2_loadings_hist),std(PC2_loadings_hist)/sqrt(17),'.')
hold off
title('PC 2')

subplot(3,1,3)
bar(-0.25:0.01:0.25,mean(PC3_loadings_hist),0.98)
ylim([0,0.25])
hold on;
errorbar(-0.25:0.01:0.25,mean(PC3_loadings_hist),std(PC3_loadings_hist)/sqrt(17),'.')
hold off
title('PC 3')



% load (pre-processed) behavioral data of mean ratings for each condition 
% (category * magnitude)
load Beh_preprocessed.mat

% perform regressions of the PCs on value, saliency, and category

% regressors for value and for saliency (mean value and mean saliency for 
% each condition from each subject)
val = condition_average(1:16,:);
sal = condition_salient(1:16,:);
% dummy variables coding for category identity (the 4th category - electric
% shock as the reference category)
c = ones(4,1); o = zeros(4,1);
cat = [c o o;o c o;o o c;o o o];

for i = 1:17 
    
    lm1= fitlm([val(:,i), sal(:,i), cat],pri1(i,:)'); 
    est1(i,:)=lm1.Coefficients.Estimate';

    
    lm2= fitlm([val(:,i), sal(:,i), cat],pri2(i,:)'); 
    est2(i,:)=lm2.Coefficients.Estimate';


    lm3= fitlm([val(:,i), sal(:,i), cat],pri3(i,:)'); 
    est3(i,:)=lm3.Coefficients.Estimate';
    
end

%plm = p-value of t-tests of each of the regression coefficients against
%zero

[~, plm(1,:)] = ttest(est1);
[~, plm(2,:)] = ttest(est2);
[~, plm(3,:)] = ttest(est3);

