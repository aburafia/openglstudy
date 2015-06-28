//
//  Shader.fsh
//  opengltest
//
//  Created by ryu on 2015/04/22.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

uniform sampler2D unif_texture;
varying mediump vec2 vary_uv;

void main()
{
    gl_FragColor = texture2D(unif_texture, vary_uv);
}
