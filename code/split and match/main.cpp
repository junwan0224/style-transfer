//
//  main.cpp
//  cvtest
//
//  Created by wanmichael on 10/28/16.
//  Copyright © 2016 wanmichael. All rights reserved.
//

#include <iostream>
#include <fstream>
#include "SplitMatch.h"
using namespace std;

/* adaptive quadtree
the input is a matrix representing the picture and the style
1. keep dividing the matrix until stop constraint is satisfied
2.
*/

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

void imgtxtwrite (string storepath, vector<vector<RGBColor>> & pic){
    ofstream saveimg (storepath);
    saveimg.clear ();
    saveimg << pic.size() << " " << pic[0].size() << endl;
    for (int i = 0; i < pic.size(); ++ i)
        for (int j = 0; j < pic[0].size(); ++ j)
            saveimg << (int)pic[i][j].r << " " << (int)pic[i][j].g << " " << (int)pic[i][j].b << " ";
    saveimg.close();
}
 
int main() {
    vector<vector<RGBColor>> pic(0), style(0);
    imgtxtread("/Users/andywan/Desktop/style_transfer/pic.txt", pic);
    imgtxtread("/Users/andywan/Desktop/style_transfer/style.txt", style);
    SplitMatch m (&pic, &style);
    
    vector<vector<RGBColor>> output (pic.size(), vector<RGBColor>(pic[0].size(), RGBColor(0,0,0)) );
    m.stylematch(output);
    imgtxtwrite("/Users/andywan/Desktop/style_transfer/save.txt", output);
}
