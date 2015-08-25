//
//  vec4.m
//  opengltest
//
//  Created by ryu on 2015/07/13.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "vec4.h"

@implementation vec4

-(vec4*) init{
    
    x = 0;
    y = 0;
    z = 0;
    w = 0;
    
    return self;
}

-(vec4*) init:(vec4raw)p{
    
    x = p.x;
    y = p.y;
    z = p.z;
    w = p.w;
    
    return self;
}

-(vec4*) init:(GLfloat)_x y:(GLfloat)_y z:(GLfloat)_z w:(GLfloat)_w{
    
    x = _x;
    y = _y;
    z = _z;
    w = _w;
    
    return self;
}

- (id)copyWithZone:(NSZone*)zone
{
    // 複製を保存するためのインスタンスを生成します。
    vec4* result = [[[self class] allocWithZone:zone] init];
    
    if (result)
    {
        result->x = x;
        result->y = y;
        result->z = z;
        result->w = w;
    }
    
    return result;
}


-(GLfloat) length{
    
    GLfloat l = sqrtf(
                    powf(x, 2) +
                    powf(y, 2) +
                    powf(z, 2) +
                    powf(w, 2)
                    );
    
    return l;
}

-(void)normalize{
    
    GLfloat len = [self length];
    
    x = len==0 ? 0 : x / len;
    y = len==0 ? 0 : y / len;
    z = len==0 ? 0 : z / len;
    w = len==0 ? 0 : w / len;
}

-(void)exportArray:(GLfloat[4])a{
    a[0] = x;
    a[1] = y;
    a[2] = z;
    a[3] = w;
}

-(vec4raw) exportRaw{
    return (vec4raw){x, y, z, w};
}



@end
