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
    
    NSError* e;
    
    NSURL* imgurl = [[NSBundle mainBundle] URLForResource:_filename withExtension:@""];
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfURL:imgurl options:nil error:&e];

    _name = textureInfo.name;
    _width = textureInfo.width;
    _height = textureInfo.height;
    
    //パラメータ設定
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D , GL_TEXTURE_WRAP_S , GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D , GL_TEXTURE_WRAP_T , GL_CLAMP_TO_EDGE);
    
    //glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    
    return;
}

//つかってない。GLKTextureInfoをつかわない方法でロードするやりかた
//http://stackoverflow.com/questions/10661807/glktextureloader-fails-when-calling-from-update
-(void)load_rawway{
    
    bool lPowerOfTwo  = false;
    
    UIImage *image = [UIImage imageNamed:_filename];
    
    GLuint width = (GLuint)CGImageGetWidth(image.CGImage);
    GLuint height = (GLuint)CGImageGetHeight(image.CGImage);
    
    _width = (int)width;
    _height = (int)height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGColorSpaceRelease( colorSpace );
    
    CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
    CGRect bounds=CGRectMake( 0, 0, width, height );
    CGContextScaleCTM(context, 1, -1);
    bounds.size.height = bounds.size.height*-1;
    CGContextDrawImage(context, bounds, image.CGImage);
    
    GLuint lTextId;
    glGenTextures(1, &lTextId);
    glBindTexture(GL_TEXTURE_2D, lTextId);
    
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    if(!lPowerOfTwo)
    {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
        glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
        
        glGenerateMipmap(GL_TEXTURE_2D);
    }else
    {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        
        glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
        glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    }
    
    CGContextRelease(context);
    
    free(imageData);

}

-(void)bind{    
    glBindTexture(GL_TEXTURE_2D, _name);
}

-(id)init:(NSString*)filename{
    
    _filename = filename;
    
    [self load];
    
    return self;
}

-(void)free{
    glDeleteTextures(1, &_name);
}

@end
