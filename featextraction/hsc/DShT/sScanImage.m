img = imread('test_v.pgm');

% scanning window size
baseW = 128;
baseH = 128;

% type of blocks to use
% 'ZA' for Zhuo and Avidan's way, which generates 2748 blocks
% 'DT' for Dalal and Triggs' way, which generates 105 blocks
blksType = 'DT'; % 'ZA' or 'DT';

switch blksType
    case 'ZA'
        blocks = mCreateAllBlocksZA(baseW, baseH, 12, 12, 4);
    case 'DT'
        blocks = mCreateAllBlocksDT(baseW, baseH, 128, 128);
end

step = 4; % scanning stide

ptSize = 0; % point size 
numOrientBins = 9;
halfBW = floor(baseW / 2);
halfBH = floor(baseH / 2);
[imgH, imgW, nCh] = size(img);
integBins = mCreateIntegOrientBins(img, numOrientBins);

map = zeros(imgH, imgW);

for r = 1:step:(imgH - baseH + 1),
    for c = 1:step:(imgW - baseW + 1),
        patch = integBins(r:(r + baseH), c:(c + baseW), :);
        features = computeHoGFeatures4Window(patch, blocks);%, 'L2');
        % ......... compute prob value here
        prob=1;
        centerX = c + halfBW;
        centerY = r + halfBH;
        map((centerY - ptSize):(centerY + ptSize), ...
            (centerX - ptSize):(centerX + ptSize)) = prob;
    end
end
