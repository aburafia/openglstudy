//
//  mat4obj.m
//  opengltest
//
//  Created by ryu on 2015/07/13.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "mat4.h"

@implementation mat4

+(mat4raw)tani{
    
    mat4raw tani_matrix;
    tani_matrix.row[0] = (vec4raw){1,0,0,0};
    tani_matrix.row[1] = (vec4raw){0,1,0,0};
    tani_matrix.row[2] = (vec4raw){0,0,1,0};
    tani_matrix.row[3] = (vec4raw){0,0,0,1};
    
    return tani_matrix;
}

-(mat4*)init{
    m = [mat4 tani];
    return self;
}

-(mat4*) init:(mat4raw)_m{
    m = _m;
    return self;
}

- (id)copyWithZone:(NSZone*)zone
{
    // 複製を保存するためのインスタンスを生成します。
    mat4* result = [[[self class] allocWithZone:zone] init];
    
    if (result)
    {
        result->m = m;
    }
    
    return result;
}

-(vec3*)Vec3xMat4:(vec3*)v{

    vec4* tmp = [[vec4 alloc] init:v->x y:v->y z:v->z w:1];
    vec4* r = [self Vec4xMat4:tmp];
    
    return [[vec3 alloc] init:r->x y:r->y z:r->z];
}

-(vec4*)Vec4xMat4:(vec4*)v{
    
    mat4raw tmp = [mat4 tani];
    
    tmp.row[0].x = m.row[0].x * v->x;
    tmp.row[0].y = m.row[0].y * v->y;
    tmp.row[0].z = m.row[0].z * v->z;
    tmp.row[0].w = m.row[0].w * v->w;
    
    tmp.row[1].x = m.row[1].x * v->x;
    tmp.row[1].y = m.row[1].y * v->y;
    tmp.row[1].z = m.row[1].z * v->z;
    tmp.row[1].w = m.row[1].w * v->w;

    tmp.row[2].x = m.row[2].x * v->x;
    tmp.row[2].y = m.row[2].y * v->y;
    tmp.row[2].z = m.row[2].z * v->z;
    tmp.row[2].w = m.row[2].w * v->w;

    tmp.row[3].x = m.row[3].x * v->x;
    tmp.row[3].y = m.row[3].y * v->y;
    tmp.row[3].z = m.row[3].z * v->z;
    tmp.row[3].w = m.row[3].w * v->w;

    vec4raw r;
    r.x = tmp.row[0].x + tmp.row[0].y + tmp.row[0].z + tmp.row[0].w;
    r.y = tmp.row[1].x + tmp.row[1].y + tmp.row[1].z + tmp.row[1].w;
    r.z = tmp.row[2].x + tmp.row[2].y + tmp.row[2].z + tmp.row[2].w;
    r.w = tmp.row[3].x + tmp.row[3].y + tmp.row[3].z + tmp.row[3].w;
    
    return [[vec4 alloc] init:r];
}

-(mat4*)multiplyMat4:(mat4*)_m{
    
    GLfloat m0a[4][4];
    [self exportArray:m0a];

    GLfloat m1a[4][4];
    [_m exportArray:m1a];
    
    GLfloat ra[4][4];
    
    for(int i = 0; i < 4; i++){
        for(int j = 0; j < 4; j++){
            
            ra[i][j] =
            (m0a[i][0] * m1a[0][j]) +
            (m0a[i][1] * m1a[1][j]) +
            (m0a[i][2] * m1a[2][j]) +
            (m0a[i][3] * m1a[3][j]);
        }
    }
    
    mat4raw r = [mat4 tani];
    
    r.row[0].x = ra[0][0];
    r.row[0].y = ra[0][1];
    r.row[0].z = ra[0][2];
    r.row[0].w = ra[0][3];
    
    r.row[1].x = ra[1][0];
    r.row[1].y = ra[1][1];
    r.row[1].z = ra[1][2];
    r.row[1].w = ra[1][3];

    r.row[2].x = ra[2][0];
    r.row[2].y = ra[2][1];
    r.row[2].z = ra[2][2];
    r.row[2].w = ra[2][3];

    r.row[3].x = ra[3][0];
    r.row[3].y = ra[3][1];
    r.row[3].z = ra[3][2];
    r.row[3].w = ra[3][3];

    return [[mat4 alloc] init:r];
}


-(void)exportArray:(GLfloat[4][4])a{
    a[0][0] = m.row[0].x; a[0][1] = m.row[0].y; a[0][2] = m.row[0].z; a[0][3] = m.row[0].w;
    a[1][0] = m.row[1].x; a[1][1] = m.row[1].y; a[1][2] = m.row[1].z; a[1][3] = m.row[1].w;
    a[2][0] = m.row[2].x; a[2][1] = m.row[2].y; a[2][2] = m.row[2].z; a[2][3] = m.row[2].w;
    a[3][0] = m.row[3].x; a[3][1] = m.row[3].y; a[3][2] = m.row[3].z; a[3][3] = m.row[3].w;
}

-(void)exportToArrayGLType:(GLfloat[4][4])a{
    a[0][0] = m.row[0].x; a[1][0] = m.row[0].y; a[2][0] = m.row[0].z; a[3][0] = m.row[0].w;
    a[0][1] = m.row[1].x; a[1][1] = m.row[1].y; a[2][1] = m.row[1].z; a[3][1] = m.row[1].w;
    a[0][2] = m.row[2].x; a[1][2] = m.row[2].y; a[2][2] = m.row[2].z; a[3][2] = m.row[2].w;
    a[0][3] = m.row[3].x; a[1][3] = m.row[3].y; a[2][3] = m.row[3].z; a[3][3] = m.row[3].w;
}

+(mat4*)translate:(vec3*)vec{
    
    mat4raw r = [mat4 tani];
    r.row[0].w = vec->x;
    r.row[1].w = vec->y;
    r.row[2].w = vec->z;
    
    return [[mat4 alloc] init:r];
}

+(mat4*)inverseTranslate:(vec3*)vec{
    
    mat4raw r = [mat4 tani];
    r.row[0].w = -vec->x;
    r.row[1].w = -vec->y;
    r.row[2].w = -vec->z;
    
    return [[mat4 alloc] init:r];
}

+(mat4*)scale:(vec3*)size{
    
    mat4raw r = [mat4 tani];
    r.row[0].x = size->x;
    r.row[1].y = size->y;
    r.row[2].z = size->z;
    
    return [[mat4 alloc] init:r];
}

+(mat4*)inverseScale:(vec3*)size{
    
    mat4raw r = [mat4 tani];

    r.row[0].x = 1/size->x;
    r.row[1].y = 1/size->y;
    r.row[2].z = 1/size->z;
    
    return [[mat4 alloc] init:r];
}


+(mat4*)rotate:(vec3*)_axis radian:(GLfloat)radian {
    
    //一応非破壊的に動く
    vec3* axis = [_axis copy];
    [axis normalize];
    
    GLfloat sin = sinf(radian);
    GLfloat cos = cosf(radian);
    
    mat4raw r = [mat4 tani];
    r.row[0].x = (axis->x * axis->x * (1 - cos)) + cos;
    r.row[0].y = (axis->x * axis->y * (1 - cos)) - (axis->z * sin);
    r.row[0].z = (axis->x * axis->z * (1 - cos)) + (axis->y * sin);
    r.row[0].w = 0;
    
    r.row[1].x = (axis->y * axis->x * (1 - cos)) + (axis->z * sin);
    r.row[1].y = (axis->y * axis->y * (1 - cos)) + cos;
    r.row[1].z = (axis->y * axis->z * (1 - cos)) - (axis->x * sin);
    r.row[1].w = 0;
    
    r.row[2].x = (axis->z * axis->x * (1 - cos)) - (axis->y * sin);
    r.row[2].y = (axis->z * axis->y * (1 - cos)) + (axis->x * sin);
    r.row[2].z = (axis->z * axis->z * (1 - cos)) + cos;
    r.row[2].w = 0;
    
    r.row[3].x = 0;
    r.row[3].y = 0;
    r.row[3].z = 0;
    r.row[3].w = 1;
    
    return [[mat4 alloc] init:r];
    
}


-(mat4*)inverseRotate:(vec3*)_axis radian:(GLfloat)radian {
    
    vec3* axis = [_axis copy];
    [axis normalize];
    
    GLfloat sin = sinf(radian);
    GLfloat cos = cosf(radian);
    
    mat4raw r = [mat4 tani];
    r.row[0].x = (axis->x * axis->x * (1 - cos)) + cos;
    r.row[0].y = (axis->x * axis->y * (1 - cos)) - (axis->z * sin);
    r.row[0].z = (axis->x * axis->z * (1 - cos)) + (axis->y * sin);
    r.row[0].w = 0;
    
    r.row[1].x = (axis->y * axis->x * (1 - cos)) + (axis->z * sin);
    r.row[1].y = (axis->y * axis->y * (1 - cos)) + cos;
    r.row[1].z = (axis->y * axis->z * (1 - cos)) - (axis->x * sin);
    r.row[1].w = 0;
    
    r.row[2].x = (axis->z * axis->x * (1 - cos)) - (axis->y * sin);
    r.row[2].y = (axis->z * axis->y * (1 - cos)) + (axis->x * sin);
    r.row[2].z = (axis->z * axis->z * (1 - cos)) + cos;
    r.row[2].w = 0;
    
    r.row[3].x = 0;
    r.row[3].y = 0;
    r.row[3].z = 0;
    r.row[3].w = 1;
    
    return [[mat4 alloc] init:r];
}


@end
