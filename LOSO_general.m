% This is a general-purpose script for leave-one-subject-out ROI analysis



NrOfSub = 18;
NrOfCond = 9; 
NrOfVOI = 1;

% load the glm file (on all subjects)
glm = xff(['....glm']);

% C: a 1-by_NrOfConditions vector, specifying the particular contrast that
% you want to use to construct the map
C = zeros(NrOfCond,1);
% C(2) = 1;
C(6) = 1;

for i = 1:NrOfSub
    % Here in 'subsel', you specify which particular subject you would like to
    % leave out for this iteration of the loop
    % Compute a random-effects map for all but one subject
    vmp = glm.RFX_tMap(C, struct('subsel', setdiff(1:18, i)'));
    % Save the output vmp (optional). If you do save it, make sure to include
    % what ontrast this is and which subject is left out
    vmp.SaveAs(['..._leave_sub_' int2str(i) '_out.vmp']);
end
vmp.ClearObject;

% Then you need to open these vmp files one-by-one in NeuroElf GUI, and create a
% manually curated list of VOI indices you need for subsequent analysis
% you need to look through the clusters in the vo output object to find the closest/best match

% Alaternatively, you can skip this part and just do the thing manually
% (open leave_sub_X_out.vmp in GUI one-by-one, apply the threshold, and
% handpick the ROIs, then save them into .voi files - may not be slower
% then the following at all)
for i = 1:NrOfSub
    vmp = xff(['..._leave_sub_' int2str(i) '_out.vmp']);
    [c, t, v, vo] = vmp.ClusterTable(1, 0.005, struct('minsize', 25, 'tdclient', true, 'localmaxi', true, 'localmin', 25, 'localmax', 100, 'localmsz', true));
    
    t
    pause
   
end
% the above is for visual examination of the cluster table. If not clear,
% then open the corresponding .vmp in GUI

% optionally followed by (assuming only one cluster/region is left):
% vo.Combine(1, 'restrict', struct('rcenter', mean(vo.VOI.Voxels), 'rsize', 8)); % restrict to 8mm around center-of-gravity

% Example VOI list (by subject)
% VOIList = [4, 2, 7; 3, 6, 7; 4, 6, 8; 2, 5, 8; 2, 4, 6; 2, 5, 8; 2, 6, 7; 2, 3, 4;...
%     3, 7, 11; 2 5 0; 2 6 7; 2 5 9; 2 4 5; 5 8 0; 4 5 6; 3 5 6; 2 5 9; 3 5 4];


% generate clusters from the map
for i = 1:NrOfSub
    vmp = xff(['..._leave_sub_' int2str(i) '_out.vmp']);
    [c, t, v, vo] = vmp.ClusterTable(1, 0.005, struct('minsize', 25, 'tdclient', true, 'localmaxi', true, 'localmin', 25, 'localmax', 100, 'localmsz', true));
    
    voi = xff('new:voi');
    for j = 1:5
        if VOIList(i,j) ~= 0
            % use the center of gravity of the VOI and construct a
            % spherical VOI with 5mm radius
            voi.AddSphericalVOI(round(mean(vo.VOI(VOIList(i,j)).Voxels)), 5);
            
            % Alternatives:
            % Use the entire VOI (after restricting it to certain radius
            % around center-of-gravity
            
            % Use peak voxel and construct a sphere
            
            % Simply use the peak voxel
            
        else
            if i==2
                voi.AddSphericalVOI([10, 5, 0], 5);
            elseif i==10
                voi.AddSphericalVOI([12, 5, 1], 5);
            end
        end
    end
    voi.SaveAs(['..._LOSO_for_sub_' int2str(i) '.voi']);
end

% If you do the alternative route, then use this part for generating
% clusters instead
for i = 1:NrOfSub
    voi = xff('new:voi');
    vo = xff(['..._LOSO_for_sub_' int2str(i) '_ori.voi']);
    for j = 1:NrOfVOI
        voi.AddSphericalVOI(round(mean(vo.VOI(VOIList(i,j)).Voxels)), 5);
    end
    voi.SaveAs(['..._LOSO_for_sub_' int2str(i) '.voi']);
end
    

% Check the voxel coordinates of all VOIs to make sure that everything is
% right
ROI = zeros(18,3); 
for i = 1:NrOfSub

    ROI(i,:) = mean(voi.VOI(1).Voxels);

end

% Now loop through all subjects: for each subject, load his/her specific
% voi, and use glm.VOIBetas (which returns a NrOfSubjects*NrOfConditions*NrOfVOIs matrix) to retrieve beta values
% Note that this will get you beta values for all subjects - but you only
% need those of the particular object

% Load a new glm if you want to get betas for some other model instead


%%


betas_VOI = zeros(NrOfSub, NrOfCond, NrOfVOI); 
for i = 1:NrOfSub
    voi = xff(['..._LOSO_for_sub_' int2str(i) '.voi']);

    betas_temp = glm.VOIBetas(voi);
    for j = 1:NrOfVOI
       betas_VOI(i, :, j) = betas_temp(i, :, j); 
    end
    
end

% t-test of betas of interst against zero

VOINameList = {'ROI1', 'ROI2', 'ROI3'};
Labels = {'Value', 'Saliency'};
for j = 1:NrOfVOI
    j
    [h1,p1] = ttest(betas_VOI(:,2,j), 0)
    [h2,p2] = ttest(betas_VOI(:,3,j), 0)
    figure
    bar([nanmean(betas_VOI(:,2,j)) nanmean(betas_VOI(:,3,j))])
    hold on
    errorbar(1:2, [nanmean(betas_VOI(:,2,j)) nanmean(betas_VOI(:,3,j))], [nanstd(betas_VOI(:,2,j))/sqrt(NrOfSub) nanstd(betas_VOI(:,3,j))/sqrt(NrOfSub)], '.')
    set(gca, 'XTick', 1:2, 'XTickLabel', Labels);
    ylabel('Mean Beta');
    title(['Cue: ' VOINameList{j}])
    
end

% Beta bar plot (or dot plot) for ratings 1-9
glm1 = xff(['..._ratings_per_number_MC.glm']);
betas_VOI = zeros(NrOfSub, glm1.NrOfSubjectPredictors, NrOfVOI); 

for i = 1:NrOfSub
    voi = xff(['...\GLM..._LOSO_for_sub_' int2str(i) '.voi']);
    betas_temp = glm1.VOIBetas(voi);
    for j = 1:NrOfVOI
       betas_VOI(i, :, j) = betas_temp(i, :, j); 
    end 
end

for i=1:NrOfVOI
    figure
%     % for cue
    bar([nanmean(betas_VOI(:,1:9,i))])
    hold on
    % for cue
    errorbar(1:9,nanmean(betas_VOI(:,1:9,i)), nanstd(betas_VOI(:,1:9,i))./sqrt(18),'.')
    title(['Cue rating ' VOINameList{i}])
    
    
end

