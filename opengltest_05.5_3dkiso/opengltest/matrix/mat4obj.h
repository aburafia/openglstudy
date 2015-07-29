//
//  mat4obj.h
//  opengltest
//
//  Created by ryu on 2015/07/13.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "vec3obj.h"
#import "vec4obj.h"

@interface mat4obj : NSObject

typedef struct mat4{
    vec4 m[4];
}mat4;

+(mat4) init;
+(vec3)multiplyVec3:(vec3)v m:(mat4)m;
+(vec4)multiplyVec4:(vec4)v m:(mat4)m;
+(mat4)multiplyMat4:(mat4)m0 m1:(mat4)m1;

+(void)copyToArray:(mat4)v a:(GLfloat[4][4])a;

+(mat4) translate:(vec3)vec;
+(mat4) scale:(vec3)size;
+(mat4) rotate:(vec3)axis radian:(GLfloat)radian;


@end
