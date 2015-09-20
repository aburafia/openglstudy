//
//  texture.h
//  opengltest
//
//  Created by ryu on 2015/09/12.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "texture.h"

@interface textures : NSObject{
    @public
    texture* texturelist[8];
    int texture_count;
}

-(void)add:(GLenum)textureUniteId filename:(NSString*)filename;
-(void)free;

@end
