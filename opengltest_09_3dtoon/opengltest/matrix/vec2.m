//
//  vec2obj.m
//  opengltest
//
//  Created by ryu on 2015/08/04.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "vec2.h"

@implementation vec2


-(vec2*) init{
    
    x = 0;
    y = 0;
    
    return self;
}

-(vec2*) init:(GLfloat)_x y:(GLfloat)_y{

    x = _x;
    y = _y;
    
    return self;
}

- (id)copyWithZone:(NSZone*)zone
{
    // 複製を保存するためのインスタンスを生成します。
    vec2* result = [[[self class] allocWithZone:zone] init];
    
    if (result)
    {
        result->x = x;
        result->y = y;
    }
    
    return result;
}


-(GLfloat) length{
    
    GLfloat l = sqrtf(
                      powf(x, 2) +
                      powf(y, 2)
                      );
    
    return l;
}

-(void)normalize{
    
    GLfloat len = [self length];
    
    x = len==0 ? 0 : x / len;
    y = len==0 ? 0 : y / len;
}

-(void)exportArray:(GLfloat[2])a{
    a[0] = x;
    a[1] = y;
}

-(vec2raw) exportRaw{
    return (vec2raw){x, y};
}



@end
