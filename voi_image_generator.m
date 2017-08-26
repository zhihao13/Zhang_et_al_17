% This script converts a VOI definition (in .nii) to a Matlab .mat file for
% later stages of RSA analysis
% author: DE (with minor modifications from ZZ)



% Import VOI definition file (.nii format)
voi = MRIread('C:\Users\zz84\Documents\RewardPunishment\mri\RSA\Searchlight\RSA_searchlight_whole_brain_saliency_PPC_ROI_VOI.nii');

%Separate VOI into 2 separate variables

v = voi.vol;

uni = unique(v);
n_uni = nnz(uni);

for i = 1:n_uni
    vim(i).voi = v; vim(i).voi(vim(i).voi~=i*100)= 0; vim(i).voi(vim(i).voi==i*100)= 1; 
end

vimall.voi = v; vimall.voi(vimall.voi>1)=1;


%Reorient VOIs

for i = 1:n_uni
    vim(i).vimp = flip(permute(flip(vim(i).voi,1),[1 3 2]),1);
end

vimall.vimp = flip(permute(flip(vimall.voi,1),[1 3 2]),1);

%Smooth VOIs

[x,y,z] = ind2sub(size(vimall.vimp),find(vimall.vimp>0));

min = min([x y z]);
max = max([x y z]);

for i = 1:n_uni
    vim(i).vimps = zeros(size(vim(i).vimp));


    for a = min(1)-5:max(1)+5;
        for b = min(2)-5:max(2)+5; 
            for c= min(3)-5:max(3)+5;
                vim(i).vimps(a,b,c) = mean(mean(mean(vim(i).vimp(a-1:a+1,b-1:b+1,c-1:c+1))));
            end;
        end;
    end
    
end

vimall.vimps = zeros(size(vimall.vimp));

for a = min(1)-5:max(1)+5;
    for b = min(2)-5:max(2)+5; 
        for c= min(3)-5:max(3)+5;
            vimall.vimps(a,b,c) = mean(mean(mean(vimall.vimp(a-1:a+1,b-1:b+1,c-1:c+1))));
        end;
    end;
end

%Truncate VOIs

for i = 1:n_uni
    vim(i).vimpst = vim(i).vimps(57:230,52:171,59:196);
end

vimall.vimpst = vimall.vimps(57:230,52:171,59:196);


%Downsample VOIs

for i = 1:n_uni
    vim(i).vimpsts = vim(i).vimpst(1:3:174,1:3:120,1:3:138);
end

vimall.vimpsts = vimall.vimpst(1:3:174,1:3:120,1:3:138);

%Binarize

for i = 1:n_uni
    vim(i).vimpsts(vim(i).vimpsts>0) = 1;
end

vimall.vimpsts(vimall.vimpsts>0) = 1;

% ZZ: save the reduced VOI only in the current folder
vim = rmfield(vim, 'voi')
vim = rmfield(vim, 'vimp')
vim = rmfield(vim, 'vimps')
vim = rmfield(vim, 'vimpst')

save('XXX_ROI.mat', 'reduced_vim');
