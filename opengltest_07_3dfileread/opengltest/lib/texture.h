//
//  texture.h
//  opengltest
//
//  Created by ryu on 2015/09/20.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface texture : NSObject{
    @public
    int _width;
    int _height;
    GLuint _name;
    NSString* _filename;
}

-(void)load;
-(id)init:(NSString*)filename;
-(void)free;
-(void)bind;

@end
