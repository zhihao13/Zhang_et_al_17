% This script creates theoretical (predictive) model RDM of the mean 
% category value model (encoding the mean subjective value of categories
% regardless of the exact level/magnitude of the cues)

% and then combine the category-mean-value model RDMs with the pre-existing
% model RDMs for some other models

% load pre-saved behavioral RDMs (category, gain-loss, value, saliency)
load('...\valueCandRDMs.mat');
load('...\saliencyCandRDMs.mat');
load('...\condIdentityCandRDMs.mat');  % the category model

% load behavioral data and create between-category value diff model (for
% now, cue conditions only)
load('....mat');   % this is a pre-precessed .mat file containing the mean pleasantness ratings for each of the 16 cue conditions in each subject

sub_ind = [1:9 11:18];
for z = 1:length(sub_ind)
    RDM = zeros(16,16);
    
    meanCategoryRating = mean(meanRateCueBySub(:,:,sub_ind(z)),2);
    RDM(5:8,1:4) = abs(meanCategoryRating(1)-meanCategoryRating(2));
    RDM(1:4,5:8) = abs(meanCategoryRating(1)-meanCategoryRating(2));
    RDM(9:12,1:4) = abs(meanCategoryRating(1)-meanCategoryRating(3));
    RDM(1:4,9:12) = abs(meanCategoryRating(1)-meanCategoryRating(3));
    RDM(13:16,1:4) = abs(meanCategoryRating(1)-meanCategoryRating(4));
    RDM(1:4,13:16) = abs(meanCategoryRating(1)-meanCategoryRating(4));
    RDM(9:12,5:8) = abs(meanCategoryRating(2)-meanCategoryRating(3));
    RDM(5:8,9:12) = abs(meanCategoryRating(2)-meanCategoryRating(3));
    RDM(13:16,9:12) = abs(meanCategoryRating(3)-meanCategoryRating(4));
    RDM(9:12,13:16) = abs(meanCategoryRating(3)-meanCategoryRating(4));
    RDM(13:16,5:8) = abs(meanCategoryRating(2)-meanCategoryRating(4));
    RDM(5:8,13:16) = abs(meanCategoryRating(2)-meanCategoryRating(4));
    
    CatValueDiffCandRDMs(z) = struct('RDM', RDM, 'name', ['category value diff model'], 'color', [1 0 1]);
end

candRDMs = {valueCandRDMs, saliencyCandRDMs, condIdentityCandRDMs, CatValueDiffCandRDMs};


