//
//  SplitMatch.h
//  cvtest
//
//  Created by wanmichael on 10/12/2016.
//  Copyright © 2016 wanmichael. All rights reserved.
//

#ifndef SplitMatch_h
#define SplitMatch_h

#include "Basic.h"
#include <vector>
using std::vector;

class SplitMatch {
public:
    const vector<vector<RGBColor>>* pic;
    const vector<vector<RGBColor>>* style;
    SplitMatch (vector<vector<RGBColor>>* p, vector<vector<RGBColor>>* s): pic(p), style(s) {};
    void stylematch (vector<vector<RGBColor>> & output);
    double match (square area, square & opt);
    double picVar (square range);
};

#endif /* SplitMatch_h */
