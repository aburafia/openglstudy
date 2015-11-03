//
//  vec4objTests.m
//  opengltest
//
//  Created by ryu on 2015/07/14.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "vec3.h"
#import "vec4.h"
#import "mat4.h"

@interface matrixTests : XCTestCase

@end

@implementation matrixTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void)testVec4Normlize{
    
    vec4* t = [[vec4 alloc] init:2 y:2 z:2 w:2];
    [t normalize];
    
    XCTAssertEqual([t length],1.0);
}

-(void)testVec3Normlize{
    
    vec3* t = [[vec3 alloc] init:1 y:1 z:1];
    [t normalize];
    
    //綺麗な1にはならないね
    XCTAssertEqual([t length] > 0.99 && [t length] < 1.01, YES);
}

-(void)testSetLength{
    
    vec3* t = [[vec3 alloc] init:1 y:1 z:1];
    [t normalize];
    XCTAssertEqual([t length] > 0.99 && [t length] < 1.01, YES);
    
    [t setLength:2];
    XCTAssertEqual([t length] > 1.99 && [t length] < 2.01, YES);
}

-(void)testVec3dot{

    float dot = 0;

    //http://marupeke296.com/COL_Basic_No1_InnerAndOuterProduct.html

    //t0から,単位ベクトルであるtnに正射影（cos）した値
    vec3* t0 = [[vec3 alloc] init:1 y:1 z:0];
    
    vec3* tn = [t0 copy];
    [tn normalize];
    
    dot = [vec3 dot:t0 v1:tn];
    XCTAssertEqual(dot > 1.414 && dot < 1.415, YES);
    
    //逆方向に-1
    vec3* t1 = [[vec3 alloc] init:-1 y:-1 z:0];
    [t1 normalize];
    
    dot = [vec3 dot:t1 v1:tn];
    XCTAssertEqual(dot < -0.999 && dot > -1.001, YES);
    
    //同じ方向に２倍の長さだから、２になる
    vec3* t2 = [tn copy];
    [t2 setLength:2];
    dot = [vec3 dot:t2 v1:tn];
    XCTAssertEqual(dot, 2);
    
    //単位ベクトルじゃない場合は？
    //量はあまり意味がないかも。
    //http://d.hatena.ne.jp/Zellij/20130216/p1
    //
    //多分下の意味合いで使えばいい感じ。
    //1,どちらかを単位ベクトルにして、影響量をしらべる
    //2,単純に向きの度合いをしる。両方単位ベクトルとして、θ=0は1、θ=πは-1、θ=π/2は0
    
    /*
    vec3 t4 = [vec3obj init:2 y:2 z:0];
    GLfloat t4len = [vec3obj length:t4];
    dot = [vec3obj dot:t4 v1:t4];
    XCTAssertEqual(dot, 2);
     */
    
}

-(void)testVec3cross{
    
    vec3* t0 = [[vec3 alloc] init:2 y:0 z:0];
    vec3* t1 = [[vec3 alloc] init:0 y:2 z:0];
    
    GLfloat len = [t0 length];
    XCTAssertEqual(len, 2);

    vec3* t2 = [vec3 cross:t0 v1:t1];
    GLfloat len2 = [t2 length];
    
    XCTAssertEqual(t2->x, 0);
    XCTAssertEqual(t2->y, 0);
    XCTAssertEqual(t2->z, 4);

    XCTAssertEqual(len2, 4);
}

-(void)testVec4xMat4{
    
    vec4* v = [[vec4 alloc] init];

    v->x = 1.1;
    v->y = 2.2;
    v->z = 3.3;
    v->w = 1;
    
    mat4* m4 = [[mat4 alloc] init];
    
    //Xに動かそう
    m4->m.row[0].w = 3;
    
    vec4* r = [m4 Vec4xMat4:v];
    
    XCTAssertEqual(r->x > 4.0999 && r->x < 5.0001, YES);
}

-(void)testMultiplyVec3{
    
    vec3* v = [[vec3 alloc] init];
    
    v->x = 1.1;
    v->y = 2.2;
    v->z = 3.3;
    
    mat4* m4 = [[mat4 alloc] init];
    
    //Xに動かそう
    m4->m.row[0].w = 3;
    
    vec3* r = [m4 Vec3xMat4:v];
    
    XCTAssertEqual(r->x > 4.0999 && r->x < 5.0001, YES);
}

-(void)testMultiplyMat4{
    
    mat4* m0 = [[mat4 alloc] init];
    mat4* m1 = [[mat4 alloc] init];
    
    m0->m.row[0].x = 1;
    m0->m.row[0].y = 2;
    m0->m.row[0].z = 3;
    m0->m.row[0].w = 4;
    
    m1->m.row[0].x = 1;
    m1->m.row[1].x = 2;
    m1->m.row[2].x = 3;
    m1->m.row[3].x = 4;
    
    mat4* r = [m0 multiplyMat4:m1];
    
    XCTAssertEqual(r->m.row[0].x, 30);
    XCTAssertEqual(r->m.row[0].y, 2);
}

-(void)testTranslate{
    
    vec3* pos = [[vec3 alloc] init:1 y:2 z:3];
    vec3* mov = [[vec3 alloc] init:0 y:12 z:1.7];
    
    mat4* m4 = [mat4 translate:mov];
    vec3* r = [m4 Vec3xMat4:pos];
    
    XCTAssertEqual(r->y > 13.999 && r->y < 14.0001, YES);
    XCTAssertEqual(r->z > 4.6999 && r->z < 4.70001, YES);
}

-(void)testScale{
    
    vec3* vec = [[vec3 alloc] init:1 y:2 z:3];
    vec3* size = [[vec3 alloc] init:2 y:2 z:5];
    
    mat4* m4 = [mat4 scale:size];
    vec3* r = [m4 Vec3xMat4:vec];
 
    XCTAssertEqual(r->x, 2);
    XCTAssertEqual(r->y, 4);
    XCTAssertEqual(r->z, 15);
}

-(void)testRotate{
    
    vec3* vec = [[vec3 alloc] init:1 y:0 z:0];
    vec3* axis = [[vec3 alloc] init:0 y:0 z:1];
    GLfloat radian = [self deg2rad:-90];
 
    mat4* m4 = [mat4 rotate:axis radian:radian];
    vec3* r = [m4 Vec3xMat4:vec];

    XCTAssertEqual(r->x < 0.0001 && r->x > -0.0001, YES);
    XCTAssertEqual(r->y, 1);
    XCTAssertEqual(r->z, 0);
}


-(GLfloat)deg2rad:(GLfloat)deg{
    return 3.14159263 / 180 * deg;
}

@end
