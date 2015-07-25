//
//  mat4obj.m
//  opengltest
//
//  Created by ryu on 2015/07/13.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "mat4obj.h"

@implementation mat4obj

+(mat4)init{
    
    mat4 r;
    
    r.m[0] = [vec4obj init:1 y:0 z:0 w:0];
    r.m[1] = [vec4obj init:0 y:1 z:0 w:0];
    r.m[2] = [vec4obj init:0 y:0 z:1 w:0];
    r.m[3] = [vec4obj init:0 y:0 z:0 w:1];
    
    return r;
}

+(vec3)multiplyVec3:(vec3)v m:(mat4)m{

    vec4 tmp;
    tmp.x = v.x;
    tmp.y = v.y;
    tmp.z = v.z;
    tmp.w = 1;
    
    vec4 result = [mat4obj multiplyVec4:tmp m:m];
    
    vec3 r;
    r.x = result.x;
    r.y = result.y;
    r.z = result.z;
    
    return r;
}

+(vec4)multiplyVec4:(vec4)v m:(mat4)m{
    
    vec4 r;
    mat4 tmp = [mat4obj init];
    
    tmp.m[0].x = m.m[0].x * v.x;
    tmp.m[0].y = m.m[0].y * v.y;
    tmp.m[0].z = m.m[0].z * v.z;
    tmp.m[0].w = m.m[0].w * v.w;
    
    tmp.m[1].x = m.m[1].x * v.x;
    tmp.m[1].y = m.m[1].y * v.y;
    tmp.m[1].z = m.m[1].z * v.z;
    tmp.m[1].w = m.m[1].w * v.w;

    tmp.m[2].x = m.m[2].x * v.x;
    tmp.m[2].y = m.m[2].y * v.y;
    tmp.m[2].z = m.m[2].z * v.z;
    tmp.m[2].w = m.m[2].w * v.w;

    tmp.m[3].x = m.m[3].x * v.x;
    tmp.m[3].y = m.m[3].y * v.y;
    tmp.m[3].z = m.m[3].z * v.z;
    tmp.m[3].w = m.m[3].w * v.w;

    r.x = tmp.m[0].x + tmp.m[0].y + tmp.m[0].z + tmp.m[0].w;
    r.y = tmp.m[1].x + tmp.m[1].y + tmp.m[1].z + tmp.m[1].w;
    r.z = tmp.m[2].x + tmp.m[2].y + tmp.m[2].z + tmp.m[2].w;
    r.w = tmp.m[3].x + tmp.m[3].y + tmp.m[3].z + tmp.m[3].w;

    
    return r;
}

+(mat4)multiplyMat4:(mat4)m0 m1:(mat4)m1{
    
    GLfloat m0a[4][4];
    [mat4obj copyToArray:m0 a:m0a];

    GLfloat m1a[4][4];
    [mat4obj copyToArray:m1 a:m1a];
    
    GLfloat ra[4][4];
    
    for(int i = 0; i < 4; i++){
        for(int j = 0; j < 4; j++){
            
            ra[i][j] =
            m0a[i][0] * m1a[0][j] +
            m0a[i][1] * m1a[1][j] +
            m0a[i][2] * m1a[2][j] +
            m0a[i][3] * m1a[3][j];
        }
    }
    
    mat4 r = [mat4obj init];
    r.m[0].x = ra[0][0];
    r.m[0].y = ra[0][1];
    r.m[0].z = ra[0][2];
    r.m[0].w = ra[0][3];
    
    r.m[1].x = ra[1][0];
    r.m[1].y = ra[1][1];
    r.m[1].z = ra[1][2];
    r.m[1].w = ra[1][3];

    r.m[2].x = ra[2][0];
    r.m[2].y = ra[2][1];
    r.m[2].z = ra[2][2];
    r.m[2].w = ra[2][3];

    r.m[3].x = ra[3][0];
    r.m[3].y = ra[3][1];
    r.m[3].z = ra[3][2];
    r.m[3].w = ra[3][3];

    return r;
}


+(void)copyToArray:(mat4)v a:(GLfloat[4][4])a{
    a[0][0] = v.m[0].x; a[0][1] = v.m[0].y; a[0][2] = v.m[0].z; a[0][3] = v.m[0].w;
    a[1][0] = v.m[1].x; a[1][1] = v.m[1].y; a[1][2] = v.m[1].z; a[1][3] = v.m[1].w;
    a[2][0] = v.m[2].x; a[2][1] = v.m[2].y; a[2][2] = v.m[2].z; a[2][3] = v.m[2].w;
    a[3][0] = v.m[3].x; a[3][1] = v.m[3].y; a[3][2] = v.m[3].z; a[3][3] = v.m[3].w;
}

+(mat4)translate:(vec3)vec{
    
    mat4 m = [mat4obj init];
    m.m[3].x = vec.x;
    m.m[3].y = vec.y;
    m.m[3].z = vec.z;
    
    return m;
}

+(mat4)inverseTranslate:(vec3)vec{
    
    mat4 m = [mat4obj init];
    m.m[3].x = -vec.x;
    m.m[3].y = -vec.y;
    m.m[3].z = -vec.z;
    
    return m;
}

+(mat4)scale:(vec3)size{
    
    mat4 m = [mat4obj init];
    m.m[0].x = size.x;
    m.m[1].y = size.y;
    m.m[2].z = size.z;
    
    return m;
}

+(mat4)inverseScale:(vec3)size{
    
    mat4 m = [mat4obj init];

    m.m[0].x = 1/size.x;
    m.m[1].y = 1/size.y;
    m.m[2].z = 1/size.z;
    
    return m;
}


+(mat4)rotate:(vec3)axis radian:(GLfloat)radian {
    
    axis = [vec3obj normalize:axis];
    
    GLfloat sin = sinf(radian);
    GLfloat cos = cosf(radian);
    
    mat4 m = [mat4obj init];
    m.m[0].x = (axis.x * axis.x * (1 - cos)) + cos;
    m.m[0].y = (axis.x * axis.y * (1 - cos)) - (axis.z * sin);
    m.m[0].z = (axis.x * axis.z * (1 - cos)) + (axis.y * sin);
    m.m[0].w = 0;
    
    m.m[1].x = (axis.y * axis.x * (1 - cos)) + (axis.z * sin);
    m.m[1].y = (axis.y * axis.y * (1 - cos)) + cos;
    m.m[1].z = (axis.y * axis.z * (1 - cos)) - (axis.x * sin);
    m.m[1].w = 0;
    
    m.m[2].x = (axis.z * axis.x * (1 - cos)) - (axis.y * sin);
    m.m[2].y = (axis.z * axis.y * (1 - cos)) + (axis.x * sin);
    m.m[2].z = (axis.z * axis.z * (1 - cos)) + cos;
    m.m[2].w = 0;
    
    m.m[3].x = 0;
    m.m[3].y = 0;
    m.m[3].z = 0;
    m.m[3].w = 1;
    
    return m;
    
}


+(mat4)inverseRotate:(vec3)axis radian:(GLfloat)radian {
    
    axis = [vec3obj normalize:axis];
    
    GLfloat sin = sinf(radian);
    GLfloat cos = cosf(radian);
    
    mat4 m = [mat4obj init];
    m.m[0].x = (axis.x * axis.x * (1 - cos)) + cos;
    m.m[0].y = (axis.x * axis.y * (1 - cos)) - (axis.z * sin);
    m.m[0].z = (axis.x * axis.z * (1 - cos)) + (axis.y * sin);
    m.m[0].w = 0;
    
    m.m[1].x = (axis.y * axis.x * (1 - cos)) + (axis.z * sin);
    m.m[1].y = (axis.y * axis.y * (1 - cos)) + cos;
    m.m[1].z = (axis.y * axis.z * (1 - cos)) - (axis.x * sin);
    m.m[1].w = 0;
    
    m.m[2].x = (axis.z * axis.x * (1 - cos)) - (axis.y * sin);
    m.m[2].y = (axis.z * axis.y * (1 - cos)) + (axis.x * sin);
    m.m[2].z = (axis.z * axis.z * (1 - cos)) + cos;
    m.m[2].w = 0;
    
    m.m[3].x = 0;
    m.m[3].y = 0;
    m.m[3].z = 0;
    m.m[3].w = 1;
    
    return m;
    
}


@end
