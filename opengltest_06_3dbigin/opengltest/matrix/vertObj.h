//
//  vertObj.h
//  opengltest
//
//  Created by ryu on 2015/08/04.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vec2.h"
#import "vec4.h"

@interface vertObj : NSObject{
    
}

typedef struct vert{
    vec4raw pos;
    vec2raw uv;
}vert;

+(vert*) init;
+(vert*) init:(vec4*)pos uv:(vec2*)uv;




@end
