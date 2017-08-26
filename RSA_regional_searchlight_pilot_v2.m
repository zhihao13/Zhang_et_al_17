% a pilot script running regional searlight RSA in the whole brain
% key modifications from v1:
% 1. utilizing the 'mask' for effective voxels (those with valid 3*3*3
% voxels surrounding them)
% 2. using fastcorr.c instead of the built-in corr implementation for the
% computation of Pearson correlation coefficients
%
% fast correlation: https://www.mathworks.com/matlabcentral/fileexchange/22358-fast-correlation-between-two-vectors

path = '...';
subList = [];

% load model RDMs to be tested
load('...\model_RDMs.mat')

% load GLM beta maps (3D matrix)
glm = BVQXfile('...\....glm');

% boundaries of the search area
xLowerBound = 1;
xUpperBound = 58;
yLowerBound = 1;
yUpperBound = 40;
zLowerBound = 1;
zUpperBound = 46;

totalIter = (xUpperBound-xLowerBound-1)*(yUpperBound-yLowerBound-1)*(zUpperBound-zLowerBound-1);

% load subject-specific masks
validCubes_all = {};
counter = 1;
for i = 1:length(subList)
    if (i==10)
        continue;
    else
        % load pre-processed matrix containing locations of valid
        % 3-by-3-by-3 cubes
        load([path 'RSA\Searchlight\ValidCubes\s' num2str(subList(i)) '\s' num2str(subList(i)) '_valid_3by3by3vox_cubes_location.mat']);
        validCubes_all{counter} = validCubes;
    end
    counter = counter+1;
end

% load 3D matrix of number of subjects with effective 3*3*3vox cubes
load('...\ValidCubes\Number_of_subs_valid_3by3by3vox_cubes.mat');
numSubEffectiveCubes = a;

% storage of results output
a = nan(58,40,46,4);   % the 4th dimension is the number of different models being considered
for i = 1:17
    searchLight_r{i} = a;  % the 4-D matric of RSA r's for each subject
end
searchLight_p = nan(58,40,46,4);

% searchlight within the area
IterNum = 1;   % track the number of finished iterations
for xCenter = (xLowerBound+1):(xUpperBound-1)
    for yCenter = (yLowerBound+1):(yUpperBound-1)
        for zCenter = (zLowerBound+1):(zUpperBound-1)
            
            if (numSubEffectiveCubes(xCenter,yCenter,zCenter)>=12)
                           
                tic
                
                slVoxelIndices = zeros(27,3);   % indices of voxels in the current 3-by-3-by-3 cube
                voxelCount = 1;
                % find out all the voxels in the cube centered at (xCenter,
                % yCenter, zCenter)
                for x = (xCenter-1):(xCenter+1)
                    for y = (yCenter-1):(yCenter+1)
                        for z = (zCenter-1):(zCenter+1)
                            slVoxelIndices(voxelCount,1) = x;
                            slVoxelIndices(voxelCount,2) = y;
                            slVoxelIndices(voxelCount,3) = z;
                            voxelCount = voxelCount + 1;
                        end
                    end
                end             
                
                subListEffective = 1:17;
                subCount = 1;
                subCountEffective = 1;   % subject counter used for those with effective cubes at the current location
                for i = 1:length(subList)
                    
                    % construct neural RDMs based on Pearson distance
                    if (i==10)  % skip s2066 (did not experience all conditions)
                        continue;
                    else
                        if (validCubes_all{subCount}(xCenter, yCenter, zCenter) == 0)
                            subListEffective(subCount) = NaN;
                        elseif (validCubes_all{subCount}(xCenter, yCenter, zCenter) == 1)
                            
                            subBeta = glm.GLMData.Subject(i).BetaMaps;
                            voxBetasVOIAllConds = zeros(32,size(slVoxelIndices,1));
                            
                            for k = 1:size(slVoxelIndices,1)
                                voxBetasVOIAllConds(:,k) = squeeze(subBeta(slVoxelIndices(k,1),slVoxelIndices(k,2),slVoxelIndices(k,3),1:32));
                            end
                            
                            subVOIRDM = zeros(16,16);
                            for ii = 1:16
                                for jj = 1:16
                                    subVOIRDM(ii,jj) = 1-fastcorr(voxBetasVOIAllConds(ii,:)',voxBetasVOIAllConds(jj,:)');
                                end
                            end
                            
                            refRDM(subCountEffective).RDM = subVOIRDM(1:16,1:16);
                            refRDM(subCountEffective).name = ['searchlight Pearson d | sub ' int2str(subCount)];
                            refRDM(subCountEffective).color = [0 255 0];
                            
                            subCountEffective = subCountEffective + 1;
                        end
                        
                        subCount = subCount + 1; % counter that counts everybody except s2066
                    end
                    
                end
                
                
                stats_p_r = compareRefRDM2candRDMs_ZZ(refRDM, candRDMs, []);
                
                subListEffective(isnan(subListEffective)==1) = [];
                
                for i = 1:length(subListEffective)
                    searchLight_r{subListEffective(i)}(xCenter,yCenter,zCenter,:) =  stats_p_r.candRelatedness_r(i,:)';
                end
                searchLight_p(xCenter,yCenter,zCenter,:) = stats_p_r.candRelatedness_p';
                
                
                clear refRDM
               
                
                t=toc
                
            end
            
            fprintf('finished %d out of %d iterations\n', IterNum, totalIter)
            disp([num2str(round(IterNum/totalIter*100)) '%  '])
            
            IterNum = IterNum+1;
        end
    end
end

