% This scripts loads and examines each individual-subject GLM and find out
% voxels where there was no signal.
% Based on the above, it then records the locations of valid 3-by-3-by-3
% cubes for each subject (with the requirement of all the 27 voxels within
% a voxel containing valid neural signal)

% This is in preparation for the whole-brain RSA searchlight analysis

glm = BVQXfile('...\....glm');
subList = [];
outPath = '...\...\';

% boundaries of the entire 58*40*46 cube
xLowerBound = 1;
xUpperBound = 58;
yLowerBound = 1;
yUpperBound = 40;
zLowerBound = 1;
zUpperBound = 46;

for i = 1:numel(glm.GLMData.Subject)
    if (i == 10)
        continue;
    else
        fprintf('Working on s%d\n\n', subList(i))
        
        IterNum = 1;   % track the number of finished iterations
        totalIter = (xUpperBound-xLowerBound-1)*(yUpperBound-yLowerBound-1)*(zUpperBound-zLowerBound-1);
        
        validCubes = zeros(58,40,46); 
        for xCenter = (xLowerBound+1):(xUpperBound-1)
            for yCenter = (yLowerBound+1):(yUpperBound-1)
                for zCenter = (zLowerBound+1):(zUpperBound-1)
                    
                    slVoxelIndices = zeros(27,3);   % indices of voxels in the current 3-by-3-by-3 cube
                    voxelCount = 1;
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
                    
                    subBeta = glm.GLMData.Subject(i).BetaMaps;
                    slVoxelBetas = nan(27,1);
                    for k = 1:size(slVoxelIndices,1)
                        slVoxelBetas(k) = subBeta(slVoxelIndices(k,1),slVoxelIndices(k,2),slVoxelIndices(k,3),1);
                    end
                    
                    if any(slVoxelBetas == 0)
                        validCubes(xCenter, yCenter, zCenter) = 0;
                    else
                        validCubes(xCenter, yCenter, zCenter) = 1;
                    end
                    
                    
                    if (floor((IterNum-1)/totalIter*100) < floor(IterNum/totalIter*100))
                        fprintf('%d%%\n', floor(IterNum/totalIter*100));                        
                    end
                    IterNum = IterNum+1;
                end
            end
        end
        fprintf('\n');
        
        % save the 3D matric validCubes for this subject and also images
        save([outPath 's' num2str(subList(i)) '\s' num2str(subList(i)) '_valid_3by3by3vox_cubes_location'], 'validCubes');
        for z = 1:46
           imagesc(validCubes(:,:,z))
           saveas(gcf, [outPath 's' num2str(subList(i)) '\s' num2str(subList(i)) '_valid_3by3by3vox_cubes_location_z_' num2str(z) '.jpg'])
           close
        end
    end
end
                    
                    

