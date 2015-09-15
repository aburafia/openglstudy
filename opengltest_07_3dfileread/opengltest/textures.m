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
    TextureList = [NSMutableArray array];
    return self;
}

//テクスチャを読み込みんでテクスチャユニットにBINDまで終わらせておく。
//Bindを実行時に変えたい場合は対応してない。
-(void)load:(NSString*)filename textureUniteId:(GLenum)textureUniteId{
    
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
    
    [self addlist:(texture){
        textureInfo.width,
        textureInfo.height,
        textureUniteId}];
    
}

-(void)addlist:(texture)tex{
    NSValue* obj = [NSValue value:&tex withObjCType:@encode(texture)];
    [TextureList addObject:obj];
}

@end
