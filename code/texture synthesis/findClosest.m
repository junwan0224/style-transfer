function [mini, minj] = findClosest (hbSize, wbSize, tnh, tnw, cSize, cx, cluster, searchImg, img)
    interval = floor(min(hbSize, wbSize) / 10);
    minDist = inf;
    minc = 0;
    for c = 1 : cSize
        diffImg = reshape(cluster(c, :, :, :), [hbSize, wbSize, 3]) - searchImg;
        diffVal = sum( sum( sum(diffImg.^2) ) );
        if diffVal < minDist
            minDist = diffVal;
            minc = c;
        end
    end
    minDist = inf;
    mini = 0;
    minj = 0;
    for i = 1 : tnh
        ih = (i - 1) * interval + 1;
        for j = 1 : tnw
            if cx(i, j) == minc
                jw = (j - 1) * interval + 1;
                diffImg = searchImg - img(ih : ih + hbSize - 1, jw : jw + wbSize - 1, :);
                diffVal = sum( sum( sum(diffImg.^2) ) );
                if diffVal < minDist
                    minDist = diffVal;
                    mini = ih;
                    minj = jw;
                end
            end
        end
    end
end