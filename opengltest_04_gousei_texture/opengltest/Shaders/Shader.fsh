//
//  Shader.fsh
//  opengltest
//
//  Created by ryu on 2015/04/22.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

uniform sampler2D unif_texture;
uniform sampler2D unif_mask;
uniform mediump float unif_threshold;

varying mediump vec2 vary_uv;

void main()
{
    if(texture2D(unif_mask,vary_uv).g < unif_threshold){
        discard;
    }    
    
    gl_FragColor = texture2D(unif_texture, vary_uv);
}
