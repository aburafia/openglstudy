//
//  vertObj.h
//  opengltest
//
//  Created by ryu on 2015/08/04.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vec2.h"
#import "vec3.h"
#import "vec4.h"

@interface vert : NSObject{
    @public
    vec4 *pos;
    vec2 *uv;
}

typedef struct vertraw{
    vec4raw pos;
    vec2raw uv;
}vertraw;

-(id) init:(vec4*)pos uv:(vec2*)uv;
-(vertraw) exportRaw;




@end
