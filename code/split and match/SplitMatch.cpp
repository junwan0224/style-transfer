//
//  SplitMatch.cpp
//  cvtest
//
//  Created by wanmichael on 10/12/2016.
//  Copyright © 2016 wanmichael. All rights reserved.
//

#include "SplitMatch.h"
#include <cassert>
#include <cmath>
#include <queue>
using std::queue;

double SplitMatch::picVar (square range){
    assert (range.endx <= pic -> size());
    assert (range.endy <= (*pic)[0].size());
    
    unsigned long long sumr(0), sumg(0), sumb(0);
    unsigned long long squaresumr(0), squaresumg(0), squaresumb(0);
    int size = (range.endx - range.startx) * (range.endy - range.starty);
    for (int i = range.startx; i < range.endx; ++ i){
        for (int j = range.starty; j < range.endy; ++ j){
            sumr += (*pic)[i][j].r;
            squaresumr += (unsigned) (*pic)[i][j].r * (unsigned) (*pic)[i][j].r;
            sumg += (*pic)[i][j].g;
            squaresumg += (unsigned) (*pic)[i][j].g * (unsigned) (*pic)[i][j].g;
            sumb += (*pic)[i][j].b;
            squaresumb += (unsigned) (*pic)[i][j].b * (unsigned) (*pic)[i][j].b;
        }
    }
    double averager = sumr / (double) size;
    double averageg = sumg / (double) size;
    double averageb = sumb / (double) size;
    return ( squaresumr + squaresumg + squaresumb ) / (double) size  - averager * averager
    - averageg * averageg - averageb * averageb;
}

double SplitMatch::match (square area, square & opt) {
    int areax = area.endx - area.startx;
    int areay = area.endy - area.starty;
    int isize = (int)style -> size() - areax + 1;
    int jsize = (int)(*style)[0].size() - areay + 1;
    
    int dividei = isize / 10;
    int dividej = jsize / 10;
    dividei = (dividei > 0 ? dividei : 1);
    dividej = (dividej > 0 ? dividej : 1);
    assert (isize > 0 && jsize > 0);
    
    double min = LONG_LONG_MAX;
    bool setFlag = false;
    for (unsigned i = 0; i < isize; i += dividei){
        for (unsigned j  = 0; j < jsize; j += dividej){
            double temp = 0;
            for (unsigned ii = 0; ii < areax; ++ ii)
                for (unsigned jj = 0; jj < areay; ++ jj)
                    temp += (*style)[i + ii][j + jj] - (*pic)[area.startx + ii][area.starty + jj];
            if (temp < min){
                min = temp;
                opt.set(i, j, i + areax, j + areay);
                setFlag = true;
            }
            
        }
    }
    
    assert (setFlag);
    return min / ( areax * areay );
}

void SplitMatch::stylematch (vector<vector<RGBColor>> & output){
    // vector<vector<RGBColor>> output (pic.size(), vector<RGBColor>(pic[0].size(), RGBColor(0,0,0)) );
    // the size of output is undefined here, need to restrain from the calling parents
    queue<square> R;
    int xsize = (int) pic -> size();
    assert (xsize != 0);
    int ysize = (int) (*pic)[0].size();
    assert (ysize != 0);
    R.push( square(0, 0, xsize, ysize) );
    
    // preprocessing
    
    while ( !R.empty() ){
        square range = R.front();
        unsigned sizex = range.endx - range.startx;
        unsigned sizey = range.endy - range.starty;
        unsigned size = (sizex > sizey ? sizex : sizey);
        square opt (range.startx, range.starty, range.endx, range.endy);
        double v (0), mrd (0);
        if (size <= maxSquareSize){
            v = sqrt(picVar(range));
            mrd = sqrt(match(range, opt));
        }
        
        if ( ((v + mrd) > squareError && size > minSquareSize) || size > maxSquareSize ){
            if (1.5 * sizex > size && 1.5 * sizey > size){
                R.push( square(range.startx, range.starty, range.startx + size/2, range.starty + size/2) );
                R.push( square(range.startx + size/2, range.starty, range.endx, range.starty + size/2) );
                R.push( square(range.startx, range.starty + size/2, range.startx + size/2, range.endy) );
                R.push( square(range.startx + size/2, range.starty + size/2, range.endx, range.endy) );
            }
            else if (sizex > sizey){
                R.push( square(range.startx, range.starty, range.startx + sizex/2, range.endy) );
                R.push( square(range.startx + sizex/2, range.starty, range.endx, range.endy) );
            }
            else {
                R.push( square(range.startx, range.starty, range.endx, range.starty + sizey/2) );
                R.push( square(range.startx, range.starty + sizey/2, range.endx, range.endy) );
            }
        }
        else {
            for (int i = 0; i < sizex; ++ i)
                for (int j = 0; j < sizey; ++ j)
                    output[range.startx + i][range.starty + j] = (*style)[opt.startx + i][opt.starty + j];
        }
        R.pop();
    }
}

