function features=getFeatures_hsc(img)

% Parameters
wblock=256;
hblock=256;
stepW=256;
stepH=256;
nlevels=3;
nangles=8;


img = double(img);
features = [];
expon = log2(nangles);

addpath('DShT');

blockIdx = [];
blockInfo = [];
levelIdx = [];
blockLoc = 1;
for y = 1 : stepH : size(img,1) - hblock + 1
    for x = 1 : stepW  : size(img, 2) - wblock + 1
        img2 = img(y:y+hblock-1, x:x+wblock-1);
        clear decomp;
        
        xlo = img2;
        for i = 1 : nlevels
            [xlo, decomp{i}] =  sdec(xlo, expon, nangles);
        end           

        histog = [];
        for j = 1 : nlevels
            histog{j} = zeros(1, nangles);
            for i = 1 : nangles
                histog{j}(i) = sum(sum(abs(decomp{j}(:,:,i))));
            end
        end

        histt = [];
        for i = 1 : nlevels
            levelIdx(i,1) = numel(histt) + 1;
            histt = [histt histog{i}];
            levelIdx(i,2) = numel(histt);
        end
        
        % features index inside the block
        blockIdx(blockLoc, 1) = numel(features) + 1;
        features = [features histt];
        blockIdx(blockLoc, 2) = numel(features);
        
        % block location information
        blockInfo(blockLoc, :) = [x, x + wblock - 1, y, y + hblock - 1];

        blockLoc = blockLoc + 1;
    end
end
