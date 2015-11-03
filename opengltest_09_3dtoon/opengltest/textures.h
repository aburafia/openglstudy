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
    NSMutableDictionary* texturelist;
    int texture_count;
}

-(void)add:(NSString*)filename;
-(texture*)get:(NSString*)filename;
-(void)bind:(NSString*)filename;
-(void)free;

@end
