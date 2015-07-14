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

    GLint _unif_color;
    
    GLint _unif_loockat; //支店変換
    GLint _unif_projection; //カメラ位置
    
    vec3 campos;
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
    
    //固定引数を取得する
    _unif_color = glGetUniformLocation(_program, "unif_color");
    
    //頂点シェーダへの引数割り当てを有効にする
    glEnableVertexAttribArray(_attr_pos);
    
    //シェーダーの利用を開始
    glUseProgram(_program);
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //カメラの初期位置
    campos = [vec3obj init:3.0f y:1.5f z:-5.0f];

}

-(void) cameraRendering{
    
    vec3 _campos = campos;
    vec3 camlook = [vec3obj init:0 y:0 z:0];
    vec3 up = [vec3obj init:0 y:1 z:0];
    
    mat4 lookAt = [mat4obj lookAt:_campos look:camlook up:up];
    GLfloat lookAtArray[4][4];
    [mat4obj copyToArray:lookAt a:lookAtArray];

    float view_width = view.bounds.size.width;
    float view_height = view.bounds.size.height;
    
    GLfloat near = 1.0f;
    GLfloat far = 30.0f;
    GLfloat Yradian = [self deg2rad:45.0f];
    GLfloat aspect = view_width/view_height;
    
    mat4 projection = [mat4obj perspective:near far:far Yradian:Yradian aspect:aspect];
    GLfloat projectionArray[4][4];

    [mat4obj copyToArray:projection a:projectionArray];
    
    //行列を転送しとく
    glUniformMatrix4fv(_unif_loockat, 1, GL_FALSE, (GLfloat*)lookAtArray);
    glUniformMatrix4fv(_unif_projection, 1, GL_FALSE, (GLfloat*)projectionArray);
    
    

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

//テクスチャを読み込みんでテクスチャユニットにBINDまで終わらせておく。
//Bindを実行時に変えたい場合は対応してない。
-(void)textureload:(NSString*)filename textureUniteId:(GLenum)textureUniteId{

    //GLKTextureLoader内部でOpenGLの何かがされてるっぽい。まずはactiveを切り替えないといけないみたい
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

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    //シェーダーの動的変更はしないので、initにもっていく
    //glUseProgram(_program);
    
    
    //カメラで行列をつくるぞー
    campos.x -= 0.01f;
    campos.z += 0.02f;
    
    [self cameraRendering];
    

    //水色で背景塗りつぶす
    glClearColor(0.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //四角の色指定
    glUniform4f(_unif_color, 1.0f, 0.0f, 1.0f, 0.5f);
    
    //四角の頂点指定
    const GLfloat posSqu[] = {
        -0.25f, 0.25f, 0.5f,
        -0.25f, -0.25f, 0.5f,
        0.25f, 0.25f, 0.5f,
        0.25f, -0.25f, 0.5f,
    };
    
    glVertexAttribPointer(_attr_pos, 3, GL_FLOAT, GL_FALSE, 0, (GLvoid*)posSqu);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //三角形の色指定
    glUniform4f(_unif_color, 1.0f, 1.0f, 1.0f, 0.5f);
    
    //三角形の頂点指定
    const GLfloat posTri[] = {
        0.0f, 0.5f, -0.5f,
        -0.5f, 0.0f, -0.5f,
        0.5f, 0.0f, -0.5f,
    };
    
    glVertexAttribPointer(_attr_pos, 3, GL_FLOAT, GL_FALSE, 0, (GLvoid*)posTri);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 3);
    
    
    
    
}


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
