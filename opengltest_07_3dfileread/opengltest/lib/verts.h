//
//  indexBuffer.h
//  opengltest
//
//  Created by ryu on 2015/09/02.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "vert.h"

typedef struct indexTriangle{
    int a, b, c;
}indexTriangle;

@interface verts : NSObject{
    GLint _attr_pos;
    GLint _attr_uv;
    NSMutableArray* vert_array;
    NSMutableArray* index_array;
}

-(verts*)init;

-(void)addVert:(vert*)v;
-(void)addVert:(GLfloat)x y:(GLfloat)y z:(GLfloat)z u:(GLfloat)u v:(GLfloat)v;
-(void)addTriangle:(int)a b:(int)b c:(int)c;

-(void)indexExportToArray:(indexTriangle*)_array;
-(void)vertExportToArray:(vertraw*)_array vertcount:(int)vertcount;

-(void)draw;


@end
