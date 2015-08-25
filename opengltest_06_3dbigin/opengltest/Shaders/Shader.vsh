//
//  Shader.vsh
//  opengltest
//
//  Created by ryu on 2015/04/22.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

attribute mediump vec4 attr_pos;
uniform mediump mat4 unif_lookat;
uniform mediump mat4 unif_projection;
uniform mediump mat4 unif_lookat_x_projection;

void main()
{
    //gl_Position = unif_lookat * attr_pos  * unif_projection ;
    gl_Position = unif_lookat_x_projection * attr_pos ;
    //gl_Position = attr_pos;
}
