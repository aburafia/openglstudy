//
//  matCamera.h
//  opengltest
//
//  Created by ryu on 2015/07/18.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mat4.h"

@interface camera : NSObject{
    @public
    int camnum;
    vec3* campos;
    vec3* lookpos;
    vec3* up;
    GLfloat near;
    GLfloat far;
    GLfloat fovYradian;
    GLfloat aspect;
}

-(camera*)initWithInfo:(int)camnum
                campos:(vec3*)campos
               lookpos:(vec3*)lookpos
                    up:(vec3*)up
                  near:(GLfloat)near
                   far:(GLfloat)far
            fovYradian:(GLfloat)fovYradian
                aspect:(GLfloat)aspect;

-(mat4*)viewMat4;
-(mat4*)perspectiveMat4;
-(vec4*)cameraCalc:(vec3*)vert;

@end
