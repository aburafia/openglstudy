//
//  Shader.fsh
//  opengltest
//
//  Created by ryu on 2015/04/22.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

uniform lowp vec4 unif_color;
uniform sampler2D unif_texture;
varying mediump vec2 vary_uv;


void main()
{
    //gl_FragColor = unif_color;
    gl_FragColor = texture2D(unif_texture, vary_uv);

}
