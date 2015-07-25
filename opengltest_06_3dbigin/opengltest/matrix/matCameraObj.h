//
//  matCamera.h
//  opengltest
//
//  Created by ryu on 2015/07/18.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mat4obj.h"


@interface matCameraObj : NSObject

typedef struct caminfo{
    vec3 campos;
    vec3 lookpos;
    vec3 up;
    
    GLfloat near;
    GLfloat far;
    GLfloat fovYradian;
    GLfloat aspect;
}caminfo;

+(void)setCamInfo:(int)camnum
           campos:(vec3)campos
          lookpos:(vec3)lookpos
               up:(vec3)up
             near:(GLfloat)near
              far:(GLfloat)far
       fovYradian:(GLfloat)fovYradian
           aspect:(GLfloat)aspect;

+(vec3)view:(int)camnum v:(vec3)v;
+(vec4)perspective:(int)camnum  v:(vec3)v;


@end
