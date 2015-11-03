//
//  vec3obj.m
//  opengltest
//
//  Created by ryu on 2015/07/13.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "vec3.h"
#import "mat4.h"

@implementation vec3

-(vec3*) init{
    
    x = 0;
    y = 0;
    z = 0;
    
    return self;
}

-(vec3*) init:(vec3raw)pv{
    
    x = pv.x;
    y = pv.y;
    z = pv.z;
    
    return self;
}


-(vec3*) init:(GLfloat)_x y:(GLfloat)_y z:(GLfloat)_z {
    
    x = _x;
    y = _y;
    z = _z;
    
    return self;
}

- (id)copyWithZone:(NSZone*)zone
{
    // 複製を保存するためのインスタンスを生成します。
    vec3* result = [[[self class] allocWithZone:zone] init];
    
    if (result)
    {
        result->x = x;
        result->y = y;
        result->z = z;
    }
    
    return result;
}

-(GLfloat) length{
    
    GLfloat l = sqrtf(
                      powf(x, 2) +
                      powf(y, 2) +
                      powf(z, 2)
                      );
    
    return l;
}

-(void) setLength:(GLfloat)len{
    
    GLfloat vlen = [self length];
    
    x = x * len / vlen;
    y = y * len / vlen;
    z = z * len / vlen;
}

-(void)normalize{
    
    GLfloat len = [self length];
    
    x = len==0 ? 0 : x / len;
    y = len==0 ? 0 : y / len;
    z = len==0 ? 0 : z / len;    
}

-(void)exportArray:(GLfloat[3])a{
    a[0] = x;
    a[1] = y;
    a[2] = z;
}

-(vec3raw) exportRaw{
    return (vec3raw){x, y, z};
}

+(vec3*) cross:(vec3*)v0 v1:(vec3*)v1{
    vec3raw r;
    
    r.x = (v0->y * v1->z) - (v0->z * v1->y);
    r.y = (v0->z * v1->x) - (v0->x * v1->z);
    r.z = (v0->x * v1->y) - (v0->y * v1->x);
    
    return [[vec3 alloc] init:r];
}

+(GLfloat) dot:(vec3*)v0 v1:(vec3*)v1{
    
    vec3raw r;
    
    r.x = v0->x * v1->x;
    r.y = v0->y * v1->y;
    r.z = v0->z * v1->z;
    
    return r.x + r.y + r.z;
}


+(vec3*) diff:(vec3*)v0 v1:(vec3*)v1{
    vec3raw r;

    r.x = v0->x - v1->x;
    r.y = v0->y - v1->y;
    r.z = v0->z - v1->z;
    
    return [[vec3 alloc] init:r];
}


@end
