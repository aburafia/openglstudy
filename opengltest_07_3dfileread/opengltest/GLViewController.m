//
//  GLViewController.m
//  opengltest
//
//  Created by ryu on 2015/04/22.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "GLViewController.h"

#define LOADER 1
#define PI 3.141592

@interface GLViewController (){
    GLKView *view;
    
    GLuint _program;
    
    GLint _attr_pos;
    GLint _attr_uv;

    GLint _unif_color;

    GLint _unif_texture;

    GLint _unif_cammat4; //カメラ行列
    

    camera* cam;
    textures* tex;
}


- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@property (strong, nonatomic) EAGLContext *context;

@end

@implementation GLViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
}

//引数の割り当て、テクスチャの読み込み
- (void)setupGL
{
    
    [EAGLContext setCurrentContext:self.context];
    [self loadShaders];

    //頂点引数を取得する
    _attr_pos = glGetAttribLocation(_program, "attr_pos");
    _attr_uv = glGetAttribLocation(_program, "attr_uv");
    
    //固定引数を取得する
    _unif_texture = glGetUniformLocation(_program, "unif_texture");
    _unif_color = glGetUniformLocation(_program, "unif_color");
    _unif_cammat4 = glGetUniformLocation(_program, "unif_cammat4");

    //頂点シェーダへの引数割り当てを有効にする
    glEnableVertexAttribArray(_attr_pos);
    glEnableVertexAttribArray(_attr_uv);

    //シェーダーの利用を開始
    glUseProgram(_program);
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //カメラの設定
    //カメラのプロパティ。位置、どこをみてるか、カメラの上の方向
    vec3* campos = [[vec3 alloc] init:3.0f y:3.0f z:-5.0f];
    vec3* lookpos = [[vec3 alloc] init:0.0f y:0.0f z:0.0f];
    vec3* up = [[vec3 alloc] init:0 y:1.0 z:0];
    
    GLfloat near = 1.0f;
    GLfloat far = 100.0f;
    GLfloat fovYradian = [self deg2rad:45.0f];
    
    float view_width = view.bounds.size.width;
    float view_height = view.bounds.size.height;
    GLfloat aspect = view_width/view_height;
    
    //カメラを作成
    cam = [[camera alloc] initWithInfo:0
                                campos:campos
                               lookpos:lookpos
                                    up:up
                                  near:near
                                   far:far
                            fovYradian:fovYradian
                                aspect:aspect];
    
    //テクスチャを読み込む
    tex = [[textures alloc] init];
    [tex load:@"texture_rgb_512x512.png" textureUniteId:GL_TEXTURE0];
}


float rrr = 0;
-(void) cameraRenderingGPU{
    
    //水色で背景塗りつぶす
    glClearColor(0.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //テクスチャの指定
    glUniform1i(_unif_texture, 0);

    //三角形の色指定
    //glUniform4f(_unif_color, 1.0f, 0.0f, 0.0f, 0.7f);
    
    //射影 x view
    mat4* view2 = [cam viewMat4];
    mat4* parspective = [cam perspectiveMat4];
    mat4* mat1 = [parspective multiplyMat4:view2];

    //(射影 x view) x ワールド加工系
    mat4* rotate = [mat4 rotate:[[vec3 alloc] init:1 y:1 z:0] radian:rrr];
    rrr += 0.01;
    mat4* mat2 = [mat1 multiplyMat4:rotate];

    GLfloat calc[4][4];
    [mat2 exportArrayGLType:calc];
    glUniformMatrix4fv(_unif_cammat4, 1, GL_FALSE, (GLfloat*)calc);

    //頂点リスト
    verts* vlist = [[verts alloc] init];
    
    GLfloat left = -0.5;
    GLfloat right = 0.5;
    GLfloat front = -0.5;
    GLfloat back = 0.5;
    GLfloat top = 0.5;
    GLfloat bottom = -0.5;
    
    [vlist addVert:left y:top z:front u:0 v:1];
    [vlist addVert:left y:top z:back u:0 v:0]; //1
    [vlist addVert:right y:top z:front u:1 v:1];
    [vlist addVert:right y:top z:back u:1 v:0]; //3
    [vlist addVert:left y:bottom z:front u:1 v:1];
    [vlist addVert:left y:bottom z:back u:1 v:0];  //5
    [vlist addVert:right y:bottom z:front u:0 v:1];
    [vlist addVert:right y:bottom z:back u:0 v:0];

    [vlist addTriangle:0 b:1 c:2];
    [vlist addTriangle:2 b:1 c:3];
    [vlist addTriangle:2 b:3 c:6];
    [vlist addTriangle:6 b:3 c:7];
    [vlist addTriangle:6 b:7 c:4];
    [vlist addTriangle:4 b:7 c:5];
    [vlist addTriangle:4 b:5 c:0];
    [vlist addTriangle:0 b:5 c:1];
    [vlist addTriangle:1 b:5 c:3];
    [vlist addTriangle:3 b:5 c:7];
    [vlist addTriangle:0 b:2 c:4];
    [vlist addTriangle:4 b:2 c:6];

    //三角形の頂点を作って転送
    int count = [vlist getVertCount];
    vertraw posTri[count];
    
    [vlist vertExportToArray:posTri vertcount:count];
    
    glVertexAttribPointer(_attr_pos, 4, GL_FLOAT, GL_FALSE, sizeof(vertraw), (GLvoid*)posTri);
    
    glVertexAttribPointer(_attr_uv, 2, GL_FLOAT, GL_FALSE, sizeof(vertraw), (GLvoid*)((GLubyte*)posTri + sizeof(vec4raw)));

    int vertcount = [vlist getTriangleCount] * 3;
    GLshort idxTri[vertcount];
    [vlist indexExportToArray:idxTri];
    
    glDrawElements(GL_TRIANGLES, vertcount, GL_UNSIGNED_SHORT, idxTri);

    //描画
    //glDrawArrays(GL_TRIANGLE_STRIP, 0, 8);

}


-(GLfloat)deg2rad:(GLfloat)deg{
    return PI / 180 * deg;
}


- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    
}

/*
//テクスチャを読み込みんでテクスチャユニットにBINDまで終わらせておく。
//Bindを実行時に変えたい場合は対応してない。
-(void)textureload:(NSString*)filename textureUniteId:(GLenum)textureUniteId{

    //GLKTextureLoader内部でOpenGLの何かがされてるっぽい。
    //まずはactiveを切り替えないといけないみたい
    glActiveTexture(textureUniteId);
    
    NSURL* imgurl = [[NSBundle mainBundle] URLForResource:filename withExtension:@""];
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfURL:imgurl options:nil error:NULL];
    
    //パラメータ設定
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D , GL_TEXTURE_WRAP_S , GL_MIRRORED_REPEAT);
    glTexParameterf(GL_TEXTURE_2D , GL_TEXTURE_WRAP_T , GL_REPEAT);
    
    //glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);

}
*/

float aa;
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    //カメラを回してみよう
    //aa += 0.1;
    //cam->campos->x = sinf(aa)*3;
    //cam->campos->z = cosf(aa)*3;
    //NSLog(@"aa=%f x=%f z=%f¥n",aa, cam->campos->x, cam->campos->z);
    
    
    [self cameraRenderingGPU];

}

/*
//三角形を描画。CPUでやったり、GPUでやったりしてみてる。まぁテスト
float aaa = 0;
-(void)testDrawTriangle{
    
    aaa += 0.1;
    
    //水色で背景塗りつぶす
    glClearColor(0.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //三角形の色指定
    glUniform4f(_unif_color, 1.0f, 1.0f, 1.0f, 0.5f);

    vec3* vert1 = [[vec3 alloc] init:0 y:0.5 z:0];
    vec3* vert2 = [[vec3 alloc] init:-0.5 y:0 z:0];
    vec3* vert3 = [[vec3 alloc] init:0.5 y:0 z:0];
    
    GLfloat posTri[9];

#ifdef usegpu
    
    //回転行列ー
    mat4 rot = [mat4obj rotate:[vec3obj init:0 y:0 z:1] radian: aaa];
    GLfloat rotArray[4][4];
    [mat4obj copyToArray:rot a:rotArray];
    glUniformMatrix4fv(_unif_loockat, 1, GL_FALSE, (GLfloat*)rotArray);

    [vec3obj copyToArray:vart1 a:&posTri[0]];
    [vec3obj copyToArray:vart2 a:&posTri[3]];
    [vec3obj copyToArray:vart3 a:&posTri[6]];
    
#else
    
    //回転行列を無効なやつ登録しておく。単位行列とか
    mat4* rot = [[mat4 alloc] init];
    GLfloat rotArray[4][4];
    [rot exportArray:rotArray];
    glUniformMatrix4fv(_unif_cammat4, 1, GL_FALSE, (GLfloat*)rotArray);
    
    //2Dの三角形を、Z軸で回転させたい
    mat4* rotate_m = [mat4 rotate:[[vec3 alloc] init:0 y:0 z:1] radian: aaa];
    
    vec3* vart1new = [rotate_m Vec3xMat4:vert1];
    [vart1new exportArray:&posTri[0]];
    
    vec3* vart2new = [rotate_m Vec3xMat4:vert2];
    [vart2new exportArray:&posTri[3]];
    
    vec3* vart3new = [rotate_m Vec3xMat4:vert3];
    [vart3new exportArray:&posTri[6]];
    
#endif
    
    //行列適応後の頂点をおくる。
    glVertexAttribPointer(_attr_pos, 3, GL_FLOAT, GL_FALSE, 0, (GLvoid*)posTri);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 3);
    
}
*/

#pragma mark -  OpenGL ES 2 shader compilation

//シェーダーのロード、コンパイル、リンク、引数の指定まで
- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // 頂点シェーダーよみこむぜｓ
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // フラグメントシェーダーよみこむぜ
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // 頂点シェーダーわりあてー.
    glAttachShader(_program, vertShader);
    
    // フラグメントシェーダーわりあてー.
    glAttachShader(_program, fragShader);
    
    
    // 頂点情報の位置を、頂点処理の変数に指定する（これを用いて描画を行う）
    // Attributeは位置、色、テクスチャなどをひっくるめた「頂点の属性」
    //    typedef enum {
    //        GLKVertexAttribPosition,
    //        GLKVertexAttribNormal,
    //        GLKVertexAttribColor,
    //        GLKVertexAttribTexCoord0,
    //        GLKVertexAttribTexCoord1,
    //    } GLKVertexAttrib;
    
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // シェーダーとかの削除.リンクが終わったからかな。
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    /*
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    */
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

//まぁとにかく、シェーダーとプログラムをリンクするんだろう
- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
    /*
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    */
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}


@end
