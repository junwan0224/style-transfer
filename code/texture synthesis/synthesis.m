% 6.869 Advances in Computer Vision

close all

img = imread('img.jpg');
img = imresize(img, [200, 200]);
img = 256 * im2double(img);
[height, width, ~] = size(img);

blockSize = 50;
times = 20;
nh = height - blockSize + 1;
nw = width - blockSize + 1;

% use kmean to initialize the cluster
[tnh, tnw, cSize, cx, cluster] = imageKMeans(img, blockSize, blockSize);
% randomly generate initial blocks
zi = ceil(rand(times, times) * nh);
zj = ceil(rand(times, times) * nw);

newimg = zeros((times + 1) * blockSize / 2, (times + 1) * blockSize / 2, 3);
change = true;
iternum = 0;

while change
    nnimg = zeros(times * blockSize, times * blockSize, 3);
    for i = 1 : times
        for j = 1 : times
            ih = 1 + (i - 1) * blockSize;
            jw = 1 + (j - 1) * blockSize;
            nnimg(ih : ih + blockSize - 1, jw : jw + blockSize - 1, :) = ...
                img(zi(i, j) : zi(i, j) + blockSize - 1, zj(i, j) : zj(i, j) + blockSize - 1, :);
        end
    end
    figure;
    imshow(nnimg / 256); title('newimg');
    
    iternum = iternum + 1;
    change = false;
    % find the optimal x
    for i = 1 : times + 1
        for j = 1 : times + 1
            counter = 1;
            ih = 1 + (i - 1) * blockSize / 2;
            jw = 1 + (j - 1) * blockSize / 2;
            geoImg = zeros(4, blockSize * blockSize * 2.25 * 3);
            if i ~= 1 && j ~= 1
                temp = zeros(blockSize * 3 / 2, blockSize * 3 / 2, 3);
                temp(1 : blockSize, 1 : blockSize, :) = ...
                    img(zi(i - 1, j - 1): zi(i - 1, j - 1) + blockSize - 1, zj(i - 1, j - 1) : zj(i - 1, j - 1) + blockSize - 1, :);
                geoImg(counter, :) = temp(:);
                counter = counter + 1;
            end
            if i ~= 1 && j ~= times + 1
                temp = zeros(blockSize * 3 / 2, blockSize * 3 / 2, 3);
                temp(1 : blockSize, blockSize / 2 + 1 : blockSize * 1.5, :) = ...
                    img(zi(i - 1, j) : zi(i - 1, j) + blockSize - 1, zj(i - 1, j) : zj(i - 1, j) + blockSize - 1, :);
                geoImg(counter, :) = temp(:);
                counter = counter + 1;
            end
            if i ~= times + 1 && j ~= 1
                temp = zeros(blockSize * 3 / 2, blockSize * 3 / 2, 3);
                temp(blockSize / 2 + 1 : blockSize * 1.5, 1 : blockSize, :) = ...
                    img(zi(i, j - 1) : zi(i, j - 1) + blockSize - 1, zj(i, j - 1) : zj(i, j - 1) + blockSize - 1, :);
                geoImg(counter, :) = temp(:);
                counter = counter + 1;
            end
            if i ~= times + 1 && j ~= times + 1
                temp = zeros(blockSize * 3 / 2, blockSize * 3 / 2, 3);
                temp(blockSize / 2 + 1 : blockSize * 1.5, blockSize / 2 + 1 : blockSize * 1.5, :) = ...
                    img(zi(i, j) : zi(i, j) + blockSize - 1, zj(i, j) : zj(i, j) + blockSize - 1, :);
                geoImg(counter, :) = temp(:);
            end
            if counter ~= 1
                geoMean = reshape(geomean(geoImg(1:counter, :)), [blockSize * 3 / 2, blockSize * 3 / 2, 3]);
                newimg(ih : ih + blockSize / 2 - 1, jw : jw + blockSize / 2 - 1, :) = ...
                    geoMean(blockSize / 2 + 1 : blockSize, blockSize / 2 + 1 : blockSize, :);
            else
                temp = reshape(geoImg(1, :), [blockSize * 3 / 2, blockSize * 3 / 2, 3]);
                newimg(ih : ih + blockSize / 2 - 1, jw : jw + blockSize / 2 - 1, :) = ...
                    temp(blockSize / 2 + 1 : blockSize, blockSize / 2 + 1 : blockSize, :);
            end
        end
    end
    %{
    superImg = zeros(times * times, (times + 1) * blockSize / 2 * (times + 1) * blockSize / 2 * 3);
    for i = 1 : times
        for j = 1 : times
            ih = 1 + (i - 1) * blockSize / 2;
            jw = 1 + (j - 1) * blockSize / 2;
            temp = zeros((times + 1) * blockSize / 2, (times + 1) * blockSize / 2, 3);
            temp(ih : ih + blockSize - 1, jw : jw + blockSize - 1, :) = ...
                img(zi(i, j) : zi(i, j) + blockSize - 1, zj(i, j) : zj(i, j) + blockSize - 1, :);
            superImg((i - 1) * times + j, :) = temp(:);
        end
    end
    newimg = reshape(geomean(superImg), [(times + 1) * blockSize / 2, (times + 1) * blockSize / 2, 3]);
    %}
    
    figure;
    imshow(newimg / 256); title('newimg');
    
    % find the optimal z
    for i = 1 : times
        for j = 1 : times
            ih = 1 + (i - 1) * blockSize / 2;
            jw = 1 + (j - 1) * blockSize / 2;
            searchImg = newimg(ih : ih + blockSize - 1, jw : jw + blockSize - 1, :);
            [mini, minj] = findClosest(blockSize, blockSize, tnh, tnw, cSize, cx, cluster, searchImg, img);
            change = change || (mini ~= zi(i, j) && minj ~= zj(i, j));
            zi(i, j) = mini;
            zj(i, j) = minj;
        end
    end
    if change
        close all;
    end
end
% 

figure;
imshow(newimg / 256); title('newimg');







