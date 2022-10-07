% 6.869 Advances in Computer Vision

close all
clear all


%% Load image
multi = 4;
times = 100;
blockRatio = 0.5;
overlapRatio = 0.25;

img = imread('img.jpg');
%img = imresize(img, [600, 800]);
img = im2double(img);
[height, width, ~] = size(img);
blockSize = ceil( blockRatio * min([height, width]) );
overlapSize = ceil( overlapRatio * blockSize );

newimgSize = multi * blockSize - (multi - 1) * overlapSize;
newimg = zeros(newimgSize, newimgSize,3);

for i = 1 : multi
    for j = 1 : multi
        minh = 1;
        minw = 1;
        minscore = inf;
        if i == 1 && j == 1
            h = ceil(rand() * (height - blockSize + 1));
            w = ceil(rand() * (width - blockSize + 1));
            newimg(1 : blockSize, 1 : blockSize, :) = img(h : h + blockSize - 1, w : w + blockSize - 1, :);
        else
            minh = 1;
            minw = 1;
            minerror = inf;
            oh = 1 + (i - 1) * (blockSize - overlapSize);
            ow = 1 + (j - 1) * (blockSize - overlapSize);
            for t = 1 : times
                nh = ceil(rand() * (height - blockSize + 1));
                nw = ceil(rand() * (width - blockSize + 1));
                error = 0;
                if i ~= 1
                    overlapImg = img(nh : nh + overlapSize - 1, nw : nw + blockSize - 1, :) - newimg(oh : oh + overlapSize - 1, ow : ow + blockSize - 1, :);
                    overlapVal = overlapImg(:,:,1).^2 + overlapImg(:,:,2).^2 + overlapImg(:,:,3).^2;
                    overlapVal = arrayfun(@sqrt, overlapVal);
                    error = error + sum(overlapVal(:));
                end
                if j ~= 1
                    overlapImg = img(nh : nh + blockSize - 1, nw : nw + overlapSize - 1, :) - newimg(oh : oh + blockSize - 1, ow : ow + overlapSize - 1, :);
                    overlapVal = overlapImg(:,:,1).^2 + overlapImg(:,:,2).^2 + overlapImg(:,:,3).^2;
                    overlapVal = arrayfun(@sqrt, overlapVal);
                    error = error + sum(overlapVal(:));
                end
                if error < minerror
                    minh = nh;
                    minnw = nw;
                    minerror = error;
                end
            end
            
            block = img(nh : nh + blockSize - 1, nw : nw + blockSize - 1, :);
            newimg(oh + overlapSize: oh + blockSize - 1, ow + overlapSize: ow + blockSize - 1, :) = block(overlapSize + 1 : blockSize, overlapSize + 1 : blockSize, :);
            
            if i == 1 %% which means that j ~= 1
                img1 = newimg(oh : oh + blockSize - 1, ow : ow + overlapSize - 1, :);
                img2 = img(nh : nh + blockSize - 1, nw : nw + overlapSize - 1, :);
                overlapImg = photoMerge(img1, img2);
                newimg(oh : oh + blockSize - 1, ow : ow + overlapSize - 1, :) = overlapImg;
                newimg(oh : oh + overlapSize - 1, ow + overlapSize : ow + blockSize - 1, :) = img(nh : nh + overlapSize - 1, nw + overlapSize : nw + blockSize - 1, :);
            
            elseif j == 1 %% which menas that i ~= 1
                img1 = newimg(oh : oh + overlapSize - 1, ow : ow + blockSize - 1, :);
                img2 = img(nh : nh + overlapSize - 1, nw : nw + blockSize - 1, :);
                overlapImg = photoMerge(permute(img1, [2,1,3]), permute(img2, [2,1,3]));
                overlapImg = permute(overlapImg, [2,1,3]);
                newimg(oh : oh + overlapSize - 1, ow : ow + blockSize - 1, :) = overlapImg;
                newimg(oh + overlapSize : oh + blockSize - 1, ow : ow + overlapSize - 1, :) = img(nh + overlapSize : nh + blockSize - 1, nw : nw + overlapSize - 1, :);
            
            else %% where i ~= 1 and j ~= 1
                img1 = newimg(oh : oh + overlapSize - 1, ow + overlapSize : ow + blockSize - 1, :);
                img2 = img(nh : nh + overlapSize - 1, nw + overlapSize : nw + blockSize - 1, :);
                overlapImgH = photoMerge(permute(img1, [2,1,3]), permute(img2, [2,1,3]));
                overlapImgH = permute(overlapImgH, [2,1,3]);
                newimg(oh : oh + overlapSize - 1, ow + overlapSize : ow + blockSize - 1, :) = overlapImgH;
                
                img1 = newimg(oh + overlapSize : oh + blockSize - 1, ow : ow + overlapSize - 1, :);
                img2 = img(nh + overlapSize : nh + blockSize - 1, nw : nw + overlapSize - 1, :);
                overlapImgV = photoMerge(img1, img2);
                newimg(oh + overlapSize : oh + blockSize - 1, ow : ow + overlapSize - 1, :) = overlapImgV;
                
                img1 = newimg(oh : oh + overlapSize - 1, ow : ow + overlapSize - 1, :);
                img2 = img(nh : nh + overlapSize - 1, nw : nw + overlapSize - 1, :);
                overlapImgC = photoMerge(img1, img2);
                overlapImgC = photoMerge(permute(img1, [2,1,3]), permute(overlapImgC, [2,1,3]));
                overlapImgC = permute(overlapImgC, [2,1,3]);
                newimg(oh : oh + overlapSize - 1, ow : ow + overlapSize - 1, :) = overlapImgC;
            end
        end
    end
end


%figure
%imshow(uint8(img1))
imwrite(uint8(newimg * 256), 'newimg.jpg', 'jpg')


function[ newoverlap ] = photoMerge( img1, img2 )
    [height, width, ~] = size(img1);
    overlapImg = img1 - img2;
    overlapVal = overlapImg(:,:,1).^2 + overlapImg(:,:,2).^2 + overlapImg(:,:,3).^2;
    overlapVal = arrayfun(@sqrt, overlapVal);
    spVal = overlapVal;
    pathPointer = zeros(height, width);
    pathPointer(height, :) = 1:width;
    
    % deciding the minipath matrix
    for i = 1 : height - 1
        minAlready = zeros(width, 1);
        for j = 1 : width
            [minv,minpos] = min(spVal(i,:));
            assert (minAlready(minpos) == 0);
            minAlready(minpos) = 1;
            if minpos ~= 1 && minAlready(minpos - 1) == 0 && overlapVal(i, minpos - 1) + minv < spVal(i, minpos - 1)
                spVal(i, minpos - 1) = overlapVal(i, minpos - 1) + minv;
                pathPointer(i, minpos - 1) = 1;
            end
            if minpos ~= width && minAlready(minpos + 1) == 0 && overlapVal(i, minpos + 1) + minv < spVal(i, minpos + 1)
                spVal(i, minpos + 1) = overlapVal(i, minpos + 1) + minv;
                pathPointer(i, minpos + 1) = 3;
            end
            if i ~= height
                spVal(i + 1, minpos) = overlapVal(i + 1, minpos) + minv;
                pathPointer(i + 1, minpos) = 2;
            end
            spVal(i, minpos) = inf;
        end
    end
    
    % deciding the path
    pathStart = zeros(height, 1);
    pathEnd = zeros(height, 1);
    [~, pos] = min(spVal(height, :));
    for i = 0 : height - 2
        h = height - i;
        pathStart(h) = pos;
        pathEnd(h) = pos;
        while pathPointer(h, pos) ~= 2
            if pathPointer(h, pos) == 1
                pos = pos + 1;
                pathEnd(h) = pathEnd(h) + 1;
            elseif pathPointer(h, pos) == 3
                pos = pos - 1;
                pathStart(h) = pathStart(h) - 1;
            else
                assert (false);
            end
        end
    end
    pathStart(1) = pos;
    pathEnd(1) = pos;
    
    newoverlap = img1;
    for i = 1 : height
        if pathStart(i) == pathEnd(i)
            newoverlap(i, pathStart(i), :) = (img1(i, pathStart(i), :) + img2(i, pathStart(i), :)) / 2;
        else
            for j = pathStart(i) : pathEnd(i)
                ratio = (j - pathStart(i)) / (pathEnd(i) - pathStart(i));
                newoverlap(i, pathStart(i), :) = (1 - ratio) * img1(i, pathStart(i), :) + ratio * img2(i, pathStart(i), :);
            end
        end
        newoverlap(i, pathEnd(i) : width, :) = img2(i, pathEnd(i) : width, :);
    end
end




