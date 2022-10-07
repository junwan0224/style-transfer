function [ tnh, tnw, cSize, cx, cluster ] = imageKMeans (img, hbSize, wbSize)
    [height, width, t] = size(img);
    assert (height > hbSize && width > wbSize);
    nh = height - hbSize + 1;
    nw = width - wbSize + 1;
    interval = floor(min(hbSize, wbSize) / 10); % don't sample all the subblocks, waste of time
    tnh = 1 + floor((nh - 1) / interval); % number of subblock sampled per line
    tnw = 1 + floor((nw - 1) / interval); % number of subblock sampled per column
    num = tnh * tnw;
    cSize = floor(sqrt(num));
    cluster = zeros(cSize, hbSize, wbSize, t);
    
    for i = 1 : cSize
        first = 1 + floor(rand() * tnh) * interval;
        second = 1 + floor(rand() * tnw) * interval;
        cluster(i, :, :, :) = img(first : first + hbSize - 1, second : second + wbSize - 1, :);
    end
    
    iternum = 0;
    l = zeros(tnh, tnw, cSize);
    cx = zeros(tnh, tnw);
    u = zeros(tnh, tnw);
    r = false(tnh, tnw);
    
    change = 10000;
    while change > 5
        change = 0;
        
        %% calculate the distance matrix between every center
        cDist = zeros(cSize, cSize);
        for i = 1 : cSize
            for j = i + 1 : cSize 
                diffImg = cluster(i, :, :, :) - cluster(j, :, :, :);
                diffVal = sqrt( sum( sum( sum(diffImg.^2) ) ) );
                cDist(i, j) = diffVal;
                cDist(j, i) = diffVal;
            end
            cDist(i, i) = 3 * max(cDist(i, :)); %% this is technically zero, but we set it large for convenience of future code
        end
        
        if iternum == 0
            %% if this is the first round, we will assign nodes to centers using triangel equality
            for i = 1 : tnh
                ih = (i - 1) * interval + 1;
                for j = 1 : tnw
                    jw = (j - 1) * interval + 1;
                    left = 1 : cSize;
                    [~, sl] = size(left);
                    minDist = inf;
                    while sl ~= 0
                        k = left(1);
                        diffImg = reshape(cluster(k, :, :, :), [hbSize, wbSize, t]) - img(ih : ih + hbSize - 1, jw : jw + wbSize - 1, :);
                        l(i, j, k) = sqrt( sum( sum( sum(diffImg.^2) ) ) );
                        
                        if l(i, j, k) < minDist
                            minDist = l(i, j, k);
                            cx(i, j) = k;
                            left = left(cDist(left, k) < 2 * l(i, j, k));
                            change = change + 1;
                        else
                            left = left(2 : end); %% get rid of the first element which is k
                        end
                        [~, sl] = size(left);
                    end
                    u(i, j) = minDist;
                end
            end
        else
            %% otherwise, we can apply some other smart trick
            s = min(cDist) * 0.5;
            for i = 1 : tnh
                ih = (i - 1) * interval + 1;
                for j = 1 : tnw
                    jw = (j - 1) * interval + 1;
                    
                    if u(i, j) > s(cx(i, j))
                        dist = 0;
                        for c = 1 : cSize
                            if (c ~= cx(i, j) && u(i, j) > l(i, j, c) && u(i, j) > 0.5 * cDist(cx(i, j), c))
                                if r(i, j)
                                    diffImg = reshape(cluster(cx(i, j), :, :, :), [hbSize, wbSize, t]) - img(ih : ih + hbSize - 1, jw : jw + wbSize - 1, :);
                                    l(i, j, cx(i, j)) = sqrt( sum( sum( sum(diffImg.^2) ) ) );
                                    dist = l(i, j, cx(i, j));
                                    u(i, j) = dist;
                                    r(i, j) = false;
                                else
                                    dist = u(i, j);
                                end
                                if dist > l(i, j, c) || dist > 0.5 * cDist(cx(i, j), c)
                                    %compute d x c
                                    diffImg = reshape(cluster(c, :, :, :), [hbSize, wbSize, t]) - img(ih : ih + hbSize - 1, jw : jw + wbSize - 1, :);
                                    l(i, j, c) = sqrt( sum( sum( sum(diffImg.^2) ) ) );
                                    if l(i, j, c) < dist
                                        cx(i, j) = c;
                                        change = change + 1;
                                    end
                                end
                            end
                        end
                    end
                    
                end
            end
        end
        
        meanc = zeros(cSize, hbSize, wbSize, t);
        dmean = zeros(1, cSize);
        cTimes = zeros(1, cSize);
        for i = 1 : tnh
            ih = (i - 1) * interval + 1;
            for j = 1 : tnw
                jw = (j - 1) * interval + 1;
                meanc(cx(i, j), :, :, :) = meanc(cx(i, j), :, :, :) + reshape(img(ih : ih + hbSize - 1, jw : jw + wbSize - 1, :), [1, hbSize, wbSize, t]);
                cTimes(cx(i, j)) = cTimes(cx(i, j)) + 1;
            end
        end
        for c = 1 : cSize
            meanc(c, :, :, :) = meanc(c, :, :, :) / cTimes(c);
            diffImg = reshape(meanc(c, :, :, :) - cluster(c, :, :, :), [hbSize, wbSize, t]);
            dmean(c) = sqrt( sum( sum( sum(diffImg.^2) ) ) );
            l(:, :, c) = max(l(:, :, c) - dmean(c), 0);
        end
        
        u = u + dmean(cx);
        r = true(nh, nw);
        cluster = meanc;
        
        iternum = iternum + 1;
    end
end