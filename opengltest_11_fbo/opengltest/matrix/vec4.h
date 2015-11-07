//
//  vec4.h
//  opengltest
//
//  Created by ryu on 2015/07/13.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface vec4 : NSObject <NSCopying>{
    @public
    GLfloat x, y, z, w;
}

typedef struct vec4raw{
    GLfloat x, y, z, w;
}vec4raw;

-(vec4*) init;
-(vec4*) init:(vec4raw)pv;
-(vec4*) init:(GLfloat)x y:(GLfloat)y z:(GLfloat)z w:(GLfloat)w;
-(void) normalize;
-(GLfloat) length;
-(void)exportArray:(GLfloat[4])a;
-(vec4raw) exportRaw;

@end
