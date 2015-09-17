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
    
    texture_count = 8;
    
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
    
    [self addlist:textureInfo.width height:textureInfo.height textureUniteId:textureUniteId name:textureInfo.name filename:(GLchar*)[filename UTF8String]];
    
    return;
}

-(void)addlist:(int)width height:(int)height textureUniteId:(GLenum)textureUniteId name:(GLuint)name filename:(GLchar*)filename{
    
    int i = (int)(textureUniteId - GL_TEXTURE0);
    
    texturelist[i].textureUniteId = textureUniteId;
    texturelist[i].width = width;
    texturelist[i].height = height;
    texturelist[i].name = name;
    texturelist[i].filename = filename;
}

-(void)free{
    
//    // 各々のテクスチャを解放する
//    int i = 0;
//    
//    for (i = 0; i < texture_count; ++i) {
//        
//        free(texturelist[i].filename);
//        
//        free(texList->texture_names[i]);
//        Texture_free(texList->textures[i]);
//    }
//        
//    // 配列をクリアする
//    free(texList->texture_names);
//    free(texList->textures);

}

@end
