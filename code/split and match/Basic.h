//
//  Basic.h
//  cvtest
//
//  Created by wanmichael on 10/12/2016.
//  Copyright © 2016 wanmichael. All rights reserved.
//

#ifndef Basic_h
#define Basic_h

#include <cassert>

#define squareError 18
#define minSquareSize 8
#define maxSquareSize 128

struct RGBColor{
    unsigned char r, g, b;
    RGBColor (unsigned char r = 0, unsigned char g = 0, unsigned char b = 0){
        this -> r = r;
        this -> g = g;
        this -> b = b;
    }
    unsigned operator - (const RGBColor minus) const{
        int dr = (int) this -> r - (int) minus.r;
        int dg = (int) this -> g - (int) minus.g;
        int db = (int) this -> b - (int) minus.b;
        return (dr * dr + dg * dg + db * db);
    }
    void operator = (const RGBColor equ) {
        this -> r = equ.r;
        this -> g = equ.g;
        this -> b = equ.b;
    }
};

struct square {
public:
    unsigned startx;
    unsigned starty;
    unsigned endx;
    unsigned endy;
    square (unsigned x, unsigned y, unsigned xx, unsigned yy):
    startx(x), starty(y), endx(xx), endy(yy){
        assert (startx < endx);
        assert (starty < endy);
    };
    void set (unsigned x, unsigned y, unsigned xx, unsigned yy){
        startx = x;
        starty = y;
        endx = xx;
        endy = yy;
        assert (startx < endx);
        assert (starty < endy);
    }
};

#endif /* Basic_h */
