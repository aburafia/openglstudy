//
//  texture.m
//  opengltest
//
//  Created by ryu on 2015/09/12.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "textures.h"

@implementation textures

-(void)add:(GLenum)textureUniteId filename:(NSString*)filename{
    
    int i = (int)(textureUniteId - GL_TEXTURE0);
    
    if(i < 0 || i > 7){
        NSLog(@"テクスチャは８こまで");
        return;
    }
    
    texturelist[i] = [[texture alloc] init:textureUniteId filename:filename];
}

-(void)free{
    
    // 各々のテクスチャを解放する
    int i = 0;
    
    for (i = 0; i < texture_count; ++i) {
        [texturelist[i] free];
        texturelist[i] = nil;
    }
}

@end
