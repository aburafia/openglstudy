//
//  vertObj.m
//  opengltest
//
//  Created by ryu on 2015/08/04.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "vert.h"

@implementation vert

-(id) init:(vec4*)p uv:(vec2*)u{

    pos = p;
    uv = u;
    
    return self;
}

-(vertraw) exportRaw{
    return (vertraw){[pos exportRaw], [uv exportRaw]};
}

@end
