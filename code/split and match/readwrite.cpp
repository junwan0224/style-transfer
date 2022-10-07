//
//  main.cpp
//  Cimgread
//
//  Created by wanmichael on 09/12/2016.
//  Copyright © 2016 wanmichael. All rights reserved.
//

#include <iostream>
#include <stdio.h>
#include <fstream>
#include <vector>
#include <queue>
#include <cassert>
#include <cmath>
#include "CImg.h"
using namespace std;
using namespace cimg_library;

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

void cimgwrite (string storepath){
    CImg<unsigned char> img ("/Users/andywan/Desktop/style_transfer/pic.jpg");
    ofstream saveimg (storepath);
    saveimg.clear ();
    saveimg << img.width() << " " << img.height() << endl;
    cimg_forX(img, x){
        cimg_forY(img, y){
            saveimg << (int)img(x, y, 0, 0) << " " << (int)img(x, y, 0, 1) << " " << (int)img(x, y, 0, 2) << " ";
        }
    }
    saveimg.close();
}

void imgtxtread (string readpath, vector<vector<RGBColor>> & pic){
    FILE *fp;
    const char * c = readpath.c_str();
    fp = fopen (c, "r");
    int sizex(0), sizey(0);
    fscanf (fp, "%d %d\n", &sizex, &sizey);
    pic = vector<vector<RGBColor>> ( sizex, vector<RGBColor>(sizey, RGBColor(0,0,0)) );
    for (int i = 0; i < sizex; ++ i){
        for (int j = 0; j < sizey; ++ j){
            unsigned char r(0), g(0), b(0);
            fscanf(fp, "%hhu %hhu %hhu ", &r, &g, &b);
            pic[i][j] = RGBColor(r, g, b);
        }
    }
    fclose(fp);
}

void vectorwrite (string storepath, vector<vector<RGBColor>> & pic){
    ofstream saveimg (storepath);
    saveimg.clear ();
    saveimg << pic.size() << " " << pic[0].size() << endl;
    for (int i = 0; i < pic.size(); ++ i)
        for (int j = 0; j < pic[0].size(); ++ j)
            saveimg << (int)pic[i][j].r << " " << (int)pic[i][j].g << " " << (int)pic[i][j].b << " ";
    saveimg.close();
}

void vectortocimg (vector<vector<RGBColor>> & pic){
    CImg<unsigned char> img (pic.size(), pic[0].size(), 1, 3);
    cimg_forXY(img, x, y){
        img(x, y, 0, 0) = pic[x][y].r;
        img(x, y, 0, 1) = pic[x][y].g;
        img(x, y, 0, 2) = pic[x][y].b;
    }
    img.save("/Users/andywan/Desktop/style_transfer/save.jpg");;
}

int main(int argc, const char * argv[]) {
    //cimgwrite("/Users/andywan/Desktop/pic.txt");
    vector<vector<RGBColor>> pic (0);
    imgtxtread("/Users/andywan/Desktop/style_transfer/save.txt", pic);
    vectortocimg(pic);
    return 0;
}
