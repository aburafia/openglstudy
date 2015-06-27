//
//  Shader.fsh
//  opengltest
//
//  Created by ryu on 2015/04/22.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

uniform lowp vec4 unif_color;
varying lowp vec4 vary_color;

void main()
{
    gl_FragColor = vary_color;
    
    //gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    
}
