//
//  texture.h
//  opengltest
//
//  Created by ryu on 2015/09/12.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct texture {
    int width;
    int height;
    GLenum textureUniteId;
    GLuint name;
    GLchar* filename;
} texture;

@interface textures : NSObject{
    @public
    texture texturelist[8];
    int texture_count;
}

-(id)init;
-(void)load:(NSString*)filename textureUniteId:(GLenum)textureUniteId;
-(void)addlist:(int)width height:(int)height textureUniteId:(GLenum)textureUniteId name:(GLuint)name filename:(GLchar*)filename;
-(void)free;

@end
