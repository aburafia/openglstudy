//
//  Shader.vsh
//  opengltest
//
//  Created by ryu on 2015/04/22.
//  Copyright (c) 2015年 ryu. All rights reserved.
//



attribute mediump vec4 attr_pos;

//移動分
uniform mediump vec2 uni_move_pos;

//
attribute lowp vec4 attr_color;
varying lowp vec4 vary_color;

void main()
{
    
    gl_Position = attr_pos;
    gl_Position.xy += uni_move_pos;
    
    vary_color = attr_color;

}
