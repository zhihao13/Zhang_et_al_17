% This script generates the neural RDM (as defined by the Pearson distance
% between neural patterns of each possible pair of all the conditions in a GLM)
% based on a GLM (3-D beta matrix) and a VOI (defining which voxels in the
% beta matrix should be included in computing the neural RDM)

path = '...';
subList = [];

load('...\VOI.mat');


voi = reduced_vim.vimpsts;
voiVoxelIndices = zeros(size(find(voi==1),1),3);
counter = 0;   % keeps track of how many voxels already have their indices filled in
for i = 1:size(voi,1)
    slice = squeeze(voi(i,:,:));
    [y,z] = find(slice==1);
    if ~isempty(y)
        x = i*ones(length(y),1);
        voiVoxelIndices((counter+1):(counter+length(y)),:,:) = [x y z];
        counter = counter+length(y);
    end
end

voi(voi==0)=NaN;
glm = BVQXfile('...\....glm');

subCount = 1;
for i = 1:length(subList)
    
    subList(i)
    
    
    % construct neural RDMs based on Pearson distance
    
    subBeta = glm.GLMData.Subject(i).BetaMaps;
    voxBetasVOIAllConds = zeros(32,size(voiVoxelIndices,1));
    
    for k = 1:size(voiVoxelIndices,1)
        voxBetasVOIAllConds(:,k) = squeeze(subBeta(voiVoxelIndices(k,1),voiVoxelIndices(k,2),voiVoxelIndices(k,3),1:32));
    end
    
    subVOIRDM = zeros(32,32);
    for ii = 1:32
        for jj = 1:32
            subVOIRDM(ii,jj) = 1-corr(voxBetasVOIAllConds(ii,:)',voxBetasVOIAllConds(jj,:)');
        end
    end
    
    refRDM(subCount).RDM = subVOIRDM(1:16,1:16);
    refRDM(subCount).name = ['left OFC Pearson d | sub ' int2str(subCount)];
    refRDM(subCount).color = [0 255 0];
    
    
    subCount = subCount + 1;
end

% visualize the mean RDM
meanRDM = zeros(16,16,17);
for i=1:17
    meanRDM(:,:,i) = refRDM(i).RDM;
end
imagesc(mean(meanRDM,3))