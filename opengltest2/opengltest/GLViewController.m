//
//  GLViewController.m
//  opengltest
//
//  Created by ryu on 2015/04/22.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "GLViewController.h"

@interface GLViewController (){
    GLuint _program;
    
    GLint _attr_pos;
    GLint _attr_uv;
    
    GLuint texture_id;

    GLint _unif_texture;

    GLKTextureInfo* textureInfo;
    
}


- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;


@end

@implementation GLViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
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

- (void)setupGL
{
    
    [EAGLContext setCurrentContext:self.context];
    [self loadShaders];

    //シェーダーの利用を開始
    glUseProgram(_program);

    //頂点引数を取得する
    _attr_pos = glGetAttribLocation(_program, "attr_pos");
    _attr_uv = glGetAttribLocation(_program, "attr_uv");
    
    //固定引数を取得する
    _unif_texture = glGetUniformLocation(_program, "unif_texture");
    
    //頂点シェーダへの引数割り当てを有効にする
    glEnableVertexAttribArray(_attr_pos);
    glEnableVertexAttribArray(_attr_uv);
    
    //テクスチャの読み込み
    texture_id = [self textureload];

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    
}

-(GLuint)textureload{

    GLuint _texture_id;

    //-----------------------
    //画像ピクセルを読み込み
    CGImageRef image = [UIImage imageNamed:@"xbox-icon.png"].CGImage;
    
    assert(image != NULL);
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    //ビットマップデータを用意します
    GLubyte* imageData = (GLubyte *) malloc(width * height * 4);
    
    CGContextRef imageContext = CGBitmapContextCreate(imageData,
                                                      width,
                                                      height,
                                                      8,
                                                      width * 4,
                                                      CGColorSpaceCreateDeviceRGB(),
                                                      (CGBitmapInfo)kCGImageAlphaPremultipliedLast
                                                      );// 第六引数がCGImageGetColorSpace(image)だとバグる模様
    
    CGContextClearRect(imageContext,CGRectMake(0, 0, (CGFloat)width, (CGFloat)height));
    CGContextDrawImage(imageContext, CGRectMake(0, 0, (CGFloat)width, (CGFloat)height), image);
    
    glPixelStorei(GL_UNPACK_ALIGNMENT,1);
    
    //OpenGL用のテクスチャを生成します
    glGenTextures(1, &_texture_id);
    
    assert(_texture_id != 0);

    //glBindTexture(GL_TEXTURE_2D, _texture_id);

    //VRAMにコピーして、元は解放
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);//ここでセットされていない？
    
    CGContextRelease(imageContext);
    free(imageData);// imageDataを解放

    //パラメータ設定
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T, GL_REPEAT);

    
    assert(glGetError() == GL_NO_ERROR);
    
    
    return _texture_id;

}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    
    glClearColor(0.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture_id);
    
    glUniform1i(_unif_texture, 0);
    
    const GLfloat position[] = {
        -0.75f, 0.75f,
        -0.75f, -0.75f,
        0.75f, 0.75f,
        0.75f, -0.75f
    };
    
    const GLfloat uv[] = {
        0, 0,
        0, 1,
        1, 0,
        1, 1
    };
    
    glVertexAttribPointer(_attr_pos, 2, GL_FLOAT, GL_FALSE, 0, (GLvoid*)position);
    glVertexAttribPointer(_attr_uv, 2, GL_FLOAT, GL_FALSE, 0, (GLvoid*)uv);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
}

#pragma mark -  OpenGL ES 2 shader compilation

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
