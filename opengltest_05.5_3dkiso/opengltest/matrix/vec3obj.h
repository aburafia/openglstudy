//
//  vec3obj.h
//  opengltest
//
//  Created by ryu on 2015/07/13.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface vec3obj : NSObject

typedef struct vec3{
    GLfloat x, y, z;
}vec3;

+(vec3) init;
+(vec3) init:(GLfloat)x y:(GLfloat)y z:(GLfloat)z;
+(vec3) normalize:(vec3)v;
+(GLfloat) length:(vec3)v;
+(vec3) setLength:(vec3)v len:(GLfloat)len;
+(vec3) cross:(vec3)v0 v1:(vec3)v1;
+(GLfloat) dot:(vec3)v0 v1:(vec3)v1;
+(vec3) diff:(vec3)v0 v1:(vec3)v1;
+(void)copyToArray:(vec3)v a:(GLfloat[3])a;


@end
