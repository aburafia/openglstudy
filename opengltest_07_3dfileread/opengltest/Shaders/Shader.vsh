//
//  Shader.vsh
//  opengltest
//
//  Created by ryu on 2015/04/22.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

attribute mediump vec4 attr_pos;

attribute mediump vec2 attr_uv;
varying mediump vec2 vary_uv;

uniform mediump mat4 unif_cammat4;

void main()
{
    gl_Position = unif_cammat4 * attr_pos ;
    vary_uv = attr_uv;

}
