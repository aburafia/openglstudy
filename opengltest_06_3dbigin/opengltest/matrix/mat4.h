//
//  mat4obj.h
//  opengltest
//
//  Created by ryu on 2015/07/13.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "vec3.h"
#import "vec4.h"

typedef struct mat4raw{
    vec4raw row[4];
}mat4raw;

@interface mat4 : NSObject<NSCopying>{
    @public
    mat4raw m;
}

-(mat4*) init;
-(mat4*) init:(mat4raw)m;
-(vec3*)Vec3xMat4:(vec3*)v;
-(vec4*)Vec4xMat4:(vec4*)v;
-(mat4*)multiplyMat4:(mat4*)m;
-(void)exportArray:(GLfloat[4][4])a;
-(void)exportToArrayGLType:(GLfloat[4][4])a;

+(mat4raw) tani;
+(mat4*) translate:(vec3*)vec;
+(mat4*) scale:(vec3*)size;
+(mat4*) rotate:(vec3*)axis radian:(GLfloat)radian;

@end
