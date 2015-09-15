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
    GLuint id;
} texture;

@interface textures : NSObject{
    NSMutableArray* TextureList;
}

-(id)init;
-(void)load:(NSString*)filename textureUniteId:(GLenum)textureUniteId;
-(void)addlist:(texture)tex;

@end
