//
//  vec2obj.h
//  opengltest
//
//  Created by ryu on 2015/08/04.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface vec2 : NSObject<NSCopying>{
    @public
    GLfloat x, y;
}

typedef struct vec2raw{
    GLfloat x, y;
}vec2raw;

-(vec2*) init;
-(vec2*) init:(GLfloat)x y:(GLfloat)y;
-(void) normalize;
-(GLfloat) length;
-(vec2raw) exportRaw;

@end
