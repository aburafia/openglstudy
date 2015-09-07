//
//  vec3obj.h
//  opengltest
//
//  Created by ryu on 2015/07/13.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface vec3 : NSObject<NSCopying>{
    @public
    GLfloat x, y, z;
}

typedef struct vec3raw{
    GLfloat x, y, z;
}vec3raw;

-(vec3*) init;
-(vec3*) init:(vec3raw)pv;
-(vec3*) init:(GLfloat)x y:(GLfloat)y z:(GLfloat)z;
-(void) normalize;
-(GLfloat) length;
-(void) setLength:(GLfloat)len;
-(void) exportArray:(GLfloat[3])a;
-(vec3raw) exportRaw;

+(vec3*) cross:(vec3*)v0 v1:(vec3*)v1;
+(GLfloat) dot:(vec3*)v0 v1:(vec3*)v1;
+(vec3*) diff:(vec3*)v0 v1:(vec3*)v1;

@end
