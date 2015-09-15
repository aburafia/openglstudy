//
//  texture.m
//  opengltest
//
//  Created by ryu on 2015/09/12.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "textures.h"

@implementation textures

-(id)init{
    
    texturelist[0].textureUniteId = GL_TEXTURE0;
    texturelist[1].textureUniteId = GL_TEXTURE1;
    texturelist[2].textureUniteId = GL_TEXTURE2;
    texturelist[3].textureUniteId = GL_TEXTURE3;
    texturelist[4].textureUniteId = GL_TEXTURE4;
    texturelist[5].textureUniteId = GL_TEXTURE5;
    texturelist[6].textureUniteId = GL_TEXTURE6;
    texturelist[7].textureUniteId = GL_TEXTURE7;

    return self;
}

//テクスチャを読み込みんでテクスチャユニットにBINDまで終わらせておく。
//Bindを実行時に変えたい場合は対応してない。
-(void)load:(NSString*)filename textureUniteId:(GLenum)textureUniteId{
    
    int i = (int)(textureUniteId - GL_TEXTURE0);
    if(i < 0 || i > 7){
        NSLog(@"テクスチャは８こまで");
        return;
    }
    
    //GLKTextureLoader内部でOpenGLの何かがされてるっぽい。
    //まずはactiveを切り替えないといけないみたい
    glActiveTexture(textureUniteId);
    
    NSURL* imgurl = [[NSBundle mainBundle] URLForResource:filename withExtension:@""];
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfURL:imgurl options:nil error:NULL];
    
    //パラメータ設定
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D , GL_TEXTURE_WRAP_S , GL_MIRRORED_REPEAT);
    glTexParameterf(GL_TEXTURE_2D , GL_TEXTURE_WRAP_T , GL_REPEAT);
    
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    
    [self addlist:textureInfo.width height:textureInfo.height textureUniteId:textureUniteId name:textureInfo.name];
    
    return;
}

-(void)addlist:(int)width height:(int)height textureUniteId:(GLenum)textureUniteId name:(GLuint)name{
    int i = (int)(textureUniteId - GL_TEXTURE0);
    
    texturelist[i].width = width;
    texturelist[i].height = height;
    texturelist[i].name = name;
}

@end
