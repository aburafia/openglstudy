//
//  texture.m
//  opengltest
//
//  Created by ryu on 2015/09/20.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "texture.h"

@implementation texture

//テクスチャを読み込みんでテクスチャユニットにBINDまで終わらせておく。
//Bindを実行時に変えたい場合は対応してない。
-(void)load{
    
    
    //GLKTextureLoader内部でOpenGLの何かがされてるっぽい。
    //まずはactiveを切り替えないといけないみたい
    glActiveTexture(_textureUniteId);
    
    NSURL* imgurl = [[NSBundle mainBundle] URLForResource:_filename withExtension:@""];
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfURL:imgurl options:nil error:NULL];

    _name = textureInfo.name;
    _width = textureInfo.width;
    _height = textureInfo.height;
    
    //パラメータ設定
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D , GL_TEXTURE_WRAP_S , GL_MIRRORED_REPEAT);
    glTexParameterf(GL_TEXTURE_2D , GL_TEXTURE_WRAP_T , GL_REPEAT);
    
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    
    return;
}

-(id)init:(GLenum)textureUniteId filename:(NSString*)filename{
    
    _textureUniteId = textureUniteId;
    _filename = filename;
    
    [self load];
    
    return self;
}

-(void)free{
    glDeleteTextures(1, &_textureUniteId);
}

@end
