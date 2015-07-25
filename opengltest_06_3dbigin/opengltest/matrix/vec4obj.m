//
//  vec4.m
//  opengltest
//
//  Created by ryu on 2015/07/13.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "vec4obj.h"

@implementation vec4obj

+(vec4) init{
    
    vec4 r;
    
    r.x = 0;
    r.y = 0;
    r.z = 0;
    r.w = 0;
    
    return r;
}

+(vec4) init:(GLfloat)x y:(GLfloat)y z:(GLfloat)z w:(GLfloat)w{
    
    vec4 r;
    
    r.x = x;
    r.y = y;
    r.z = z;
    r.w = w;
    
    return r;
}

+(GLfloat) length:(vec4)v{
    
    GLfloat l = sqrtf(
                    powf(v.x, 2) +
                    powf(v.y, 2) +
                    powf(v.z, 2) +
                    powf(v.w, 2)
                    );
    
    return l;
}


+(vec4)normalize:(vec4)v{
    
    GLfloat len = [self length:v];
    
    vec4 r;

    r.x = len==0 ? 0 : v.x / len;
    r.y = len==0 ? 0 : v.y / len;
    r.z = len==0 ? 0 : v.z / len;
    r.w = len==0 ? 0 : v.w / len;
    
    return r;
}

+(void)copyToArray:(vec4)v a:(GLfloat[4])a{
    a[0] = v.x;
    a[1] = v.y;
    a[2] = v.z;
    a[3] = v.w;
}




@end
