//
//  Shader.fsh
//  opengltest
//
//  Created by ryu on 2015/04/22.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

uniform lowp vec4 unif_color;

void main()
{
    gl_FragColor = unif_color;
}
