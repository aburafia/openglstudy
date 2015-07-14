//
//  vec3obj.m
//  opengltest
//
//  Created by ryu on 2015/07/13.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "vec3obj.h"
#import "mat4obj.h"

@implementation vec3obj

+(vec3) init{
    
    vec3 r;
    
    r.x = 0;
    r.y = 0;
    r.z = 0;
    
    return r;
}

+(vec3) init:(GLfloat)x y:(GLfloat)y z:(GLfloat)z {
    
    vec3 r;
    
    r.x = x;
    r.y = y;
    r.z = z;
    
    return r;
}

+(GLfloat) length:(vec3)v{
    
    GLfloat l = sqrtf(
                      powf(v.x, 2) +
                      powf(v.y, 2) +
                      powf(v.z, 2)
                      );
    
    return l;
}

+(vec3) setLength:(vec3)v len:(GLfloat)len{
    
    vec3 r;
    GLfloat vlen = [vec3obj length:v];
    
    r.x = v.x * len / vlen;
    r.y = v.y * len / vlen;
    r.z = v.z * len / vlen;
    
    return r;
}

+(vec3)normalize:(vec3)v{
    
    GLfloat len = [self length:v];
    
    vec3 r;
    
    r.x = v.x / len;
    r.y = v.y / len;
    r.z = v.z / len;
    
    return r;
}

+(vec3) cross:(vec3)v0 v1:(vec3)v1{
    vec3 r;
    
    r.x = (v0.y * v1.z) - (v0.z * v1.y);
    r.y = (v0.z * v1.x) - (v0.x * v1.z);
    r.z = (v0.x * v1.y) - (v0.y * v1.x);
    
    return r;
}

+(GLfloat) dot:(vec3)v0 v1:(vec3)v1{
    vec3 r;
    
    r.x = v0.x * v1.x;
    r.y = v0.y * v1.y;
    r.z = v0.z * v1.z;
    
    return r.x + r.y + r.z;
}

+(void)copyToArray:(vec3)v a:(GLfloat[3])a{
    a[0] = v.x;
    a[1] = v.y;
    a[2] = v.z;
}



@end
