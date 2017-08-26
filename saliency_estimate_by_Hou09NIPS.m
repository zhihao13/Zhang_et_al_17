% This script utilizes the visual saliency prediction algorithm reported by
% Hou, X., & Zhang, L. (2009). Dynamic visual attention: Searching for coding length increments. 
% In Advances in neural information processing systems (pp. 681-688)
% and the Matlab implementations provided by Hou on his website
% (http://www.houxiaodi.com/assets/papers/nips08matlab.zip)
% to calculate estimated visual saliency of the cue stimuli in our study
% on the anticipation of reward and punishment (Zhang et al., 2017, in
% revision for Nature Communications)


% Must first download and unzip Hou's scripts from the link above and make
% sure they have been added to active Matlab paths before running the
% following scripts

clear
clc
load AW.mat;

cueImagePath = '...';
cueImageFiles = {'vmg1.jpg', 'vmg2.jpg', 'vmg3.jpg', 'vmg4.jpg', ...
    'vml1.jpg', 'vml2.jpg', 'vml3.jpg', 'vml4.jpg', ...
    'vpp1.jpg', 'vpp2.jpg', 'vpp3.jpg', 'vpp4.jpg', ...
    'vsh1.jpg', 'vsh2.jpg', 'vsh3.jpg', 'vsh4.jpg'};


% generate pixel-by-pixel visual saliency maps from the 1000 random collages 
% containing all 16 cue stimuli (with locations of each cue stimuli 
% randomized to cancel out potential location
% effects)
for i = 1:1000
    
    inImg = im2double(imread(strcat([cueImagePath 'random_collages/collage_' num2str(i) '.jpg'])));
    inImg = imresize(inImg, [360,480]);
    [imgH, imgW, imgDim] = size(inImg);
    myEnergy = im2Energy(inImg, W);
    mySMap = vector2Im(myEnergy, imgH, imgW);
    i
    save([cueImagePath 'random_collages/collage_' num2str(i) '_Hou08_resized_360by480_salMap.mat' ], 'mySMap');

end

load([cueImagePath 'random_collages/locationRecord_1_to_1000.mat'])
xRanges = [1 90; 1 90; 1 90; 1 90; 91 180; 91 180; 91 180; 91 180; ...
    181 270; 181 270; 181 270; 181 270; 271 360; 271 360; 271 360; 271 360;];
yRanges = [1 120; 121 240; 241 360; 361 480; 1 120; 121 240; 241 360; 361 480; ...
    1 120; 121 240; 241 360; 361 480; 1 120; 121 240; 241 360; 361 480];

% calculate mean visual saliency for the cues
cueSaliencies = zeros(1000,16);  % each row is one collage, each column is one cue
for j = 1:1000
    load([cueImagePath 'random_collages/collage_' num2str(j) '_Hou08_resized_360by480_salMap.mat' ])
    
    for location = 1:16
        cueID = locationRecord(j,location);
        salMapPart = mySMap(xRanges(location,1):xRanges(location,2), yRanges(location,1):yRanges(location,2));
        partSaliency = mean(salMapPart(:));
        cueSaliencies(j,cueID) = partSaliency;
    end
end

% plot mean estimated visual saliency for each cue stimulus
figure;bar(mean(cueSaliencies,1))
hold on
errorbar(1:16,mean(cueSaliencies,1),std(cueSaliencies,1),'.')
xticklabel_rotate([1:16],45,{'vmg1','vmg2','vmg3','vmg4','vml1','vml2','vml3','vml4','vpp1','vpp2','vpp3','vpp4','vsh1','vsh2','vsh3','vsh4'},'interpreter','none')




