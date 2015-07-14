//
//  vec4.h
//  opengltest
//
//  Created by ryu on 2015/07/13.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>


@interface vec4obj : NSObject

typedef struct vec4{
    GLfloat x, y, z, w;
}vec4;

+(vec4) init;
+(vec4) init:(GLfloat)x y:(GLfloat)y z:(GLfloat)z w:(GLfloat)w;
+(vec4) normalize:(vec4)v;
+(GLfloat) length:(vec4)v;
+(void)copyToArray:(vec4)v a:(GLfloat[4])a;


@end
