//
//  GLViewController.m
//  opengltest
//
//  Created by ryu on 2015/04/22.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "GLViewController.h"
#import "pmd.h"

#define LOADER 1
#define PI 3.141592



@interface GLViewController (){
    GLKView *view;
    
    //============
    // main用shader
    //============
    GLuint _program;
    
    GLint _attr_pos;
    
    GLint _attr_uv;

    GLint _unif_color;
    
    GLfloat _unif_alpha;

    GLint _unif_texture;

    GLint _unif_cammat4; //カメラ行列

    //============
    // edge用shader
    //============
    GLuint _program_edge;
    
    GLint _attr_pos_edge;

    GLint _attr_normal_edge;
    
    GLint _unif_color_edge;

    GLint _unif_cammat4_edge; //カメラ行列
    
    GLint _unif_edgesize;
    
    //============
    // バッファオブジェクト
    //============
    GLuint _vertex_buffer;
    GLuint _index_buffer;
    
    //============
    // フレームバッファ
    //============
    GLuint _def_frame_buffer;//IOSのデフォルトのフレームバッファ

    GLuint _frame_buffer;
    
    GLuint _write_texture;
    
    GLuint _depth_buffer;
    
    int width;
    int height;
    
    

    camera* cam;
    textures* tex;
    
    
    pmd* pmdfile;
}


- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders:(GLuint*)pg vshname:(NSString*)vshname fshname:(NSString*)fshname;


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
    
    //GLの基本的な設定
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnable(GL_CULL_FACE);
    
    //Shaderの設定
    //[self setupEdgeShader];
    [self setupMainShader];
    
    //カメラの設定
    //カメラのプロパティ。位置、どこをみてるか、カメラの上の方向
    vec3* campos = [[vec3 alloc] init:0.0f y:15.0f z:-35.0f];
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
    //[tex add:@"texture_rgb_512x512.png"];
    //[[tex get:@"texture_rgb_512x512.png"] bind];

    
    //pmdファイルを読み込み
    pmdfile = [[pmd alloc] init];
    [pmdfile load:@"pmd-sample.pmd"];
    [pmdfile loadTextures:tex];
    
    //[[tex get:@"pmd-face.png"] bind];
    
    //BufferObjectの初期化
    //[self setVertexBufferObject];
    //[self setIndexBufferObject];
    
    
    //デフォルトのFBOを取得
    GLint aaa;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, (GLint*)&aaa);
    assert(glGetError() == GL_NO_ERROR);
    assert(aaa != 0);
    width = 512;
    height = 512;
    
    //描画対象のテクスチャ生成
    glGenTextures(1, &_write_texture);
    assert(glGetError() == GL_NO_ERROR);
    assert(_write_texture != 0);
    
    //テクスチャの確保
    glBindTexture(GL_TEXTURE_2D, _write_texture);
    
    //テクスチャの設定
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER  , GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER  , GL_LINEAR);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, nil);
    assert(glGetError() == GL_NO_ERROR);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    
    //レンダリングバッファをつくつ
    glGenRenderbuffers(1, &_depth_buffer);
    assert(glGetError() == GL_NO_ERROR);
    assert(_depth_buffer != 0);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _depth_buffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    
    
    //テクスチャとバッファをフレームバッファへ
    glGenFramebuffers(1, &_frame_buffer);
    assert(glGetError() == GL_NO_ERROR);
    assert(_frame_buffer != 0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frame_buffer);
    
    //テクスチャをアタッチ
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _write_texture, 0);
    assert(glGetError() == GL_NO_ERROR);
    
    //レンダーバッファをアタッチ
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depth_buffer);
    assert(glGetError() == GL_NO_ERROR);
    
    assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
    
    //フレームバファのunbind
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    
}

/*
-(void)setVertexBufferObject{
    
    //generate
    glGenBuffers(1, &_vertex_buffer);
    assert(glGetError()==GL_NO_ERROR);
    assert(_vertex_buffer != 0);
    
    //bind
    glBindBuffer(GL_ARRAY_BUFFER, _vertex_buffer);
    assert(glGetError()==GL_NO_ERROR);

    //upload
    glBufferData(GL_ARRAY_BUFFER,
                 sizeof(PmdVertex) * pmdfile->_result.vertices_num,
                 pmdfile->_result.vertices,
                 GL_STATIC_DRAW);

    //bind解除
    //転送だけ済ませておく
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
}

-(void)deleteBufferObject{
    glDeleteBuffers(1,&_vertex_buffer);
    glDeleteBuffers(1,&_index_buffer);
    
}

-(void)setIndexBufferObject{
    
    //generate
    glGenBuffers(1, &_index_buffer);
    assert(glGetError()==GL_NO_ERROR);
    assert(_index_buffer != 0);
    
    //bind
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _index_buffer);
    assert(glGetError()==GL_NO_ERROR);
    
    //upload
    glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                 sizeof(GLushort) * pmdfile->_result.indices_num,
                 pmdfile->_result.indices,
                 GL_STATIC_DRAW);
    
    //bind解除
    //転送だけ済ませておく
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
}
*/

-(void)setupMainShader{
    
    [self loadShaders:&_program vshname:@"Shader.vsh" fshname:@"Shader.fsh"];
    
    //頂点引数を取得する
    _attr_pos = glGetAttribLocation(_program, "attr_pos");
    _attr_uv = glGetAttribLocation(_program, "attr_uv");
    
    //固定引数を取得する
    _unif_texture = glGetUniformLocation(_program, "unif_texture");
    _unif_color = glGetUniformLocation(_program, "unif_color");
    _unif_alpha = glGetUniformLocation(_program, "unif_alpha");
    
    _unif_cammat4 = glGetUniformLocation(_program, "unif_cammat4");

}

/*
-(void)setupEdgeShader{
    
    [self loadShaders:&_program_edge vshname:@"EdgeShader.vsh" fshname:@"EdgeShader.fsh"];
    
    //頂点引数を取得する
    _attr_pos_edge = glGetAttribLocation(_program_edge, "attr_pos");
    _attr_normal_edge = glGetAttribLocation(_program_edge, "attr_normal");
    
    //固定引数を取得する
    _unif_color_edge = glGetUniformLocation(_program_edge, "unif_color");
    _unif_cammat4_edge = glGetUniformLocation(_program_edge, "unif_cammat4");
    _unif_edgesize = glGetUniformLocation(_program_edge, "unif_edgesize");
    
}
*/

-(void) sceneRendering{
    
    //水色で背景塗りつぶす
    glClearColor(0.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    
    //フレムバッファにpmdモデルをレンダリング
    [self renderingPMD];
    
    
    //フレームバッファをテクスチャとしてボックスをレンダリング
    //[self renderingBox];
    
    
    
    
    
    
}

-(void)renderingBox{
    
    
    //デフォルトのフレームバッファにもどす
    glBindFramebuffer(GL_FRAMEBUFFER, _def_frame_buffer);
    glViewport(0, 0, view.bounds.size.width, view.bounds.size.height);
    
    
    //シェーダーの利用を開始
    glUseProgram(_program);
    
    //頂点シェーダへの引数割り当てを有効にする
    glEnableVertexAttribArray(_attr_pos);
    glEnableVertexAttribArray(_attr_uv);
    
    
    //カメラ位置、移動などの計算
    //射影 x view
    mat4* view2 = [cam viewMat4];
    mat4* parspective = [cam perspectiveMat4];
    mat4* mat1 = [parspective multiplyMat4:view2];
    
    //(射影 x view) x ワールド加工系
    mat4* rotate = [mat4 rotate:[[vec3 alloc] init:0 y:1 z:0] radian:rrr];
    //rrr += 0.1;
    
    //mat4* transform = [mat4 translate:[[vec3 alloc] init:x * 3 y:0 z:z * 3]];
    //mat4* matdata = [mat1 multiplyMat4:rotate];
    
    verts* boxvert = [[verts alloc] init];
    [boxvert addVert:-0.5 y:0.5 z:0 u:1 v:1];
    [boxvert addVert:-0.5 y:-0.5 z:0 u:1 v:1];
    [boxvert addVert:0.5 y:0.5 z:0 u:1 v:1];
    [boxvert addVert:0.5 y:-0.5 z:0 u:1 v:1];
    
    [boxvert addTriangle:0 b:1 c:2];
    [boxvert addTriangle:0 b:4 c:2];
    
    vertraw posTri[4];
    GLshort posIdx[6];

    [boxvert vertExportToArray:posTri vertcount:4];
    [boxvert indexExportToArray:posIdx];
    
    const GLfloat uv[] = {
        0, 0,
        0, 1,
        1, 0,
        1, 1
    };
    
    GLfloat calc[4][4];
    [rotate exportArrayGLType:calc];
    glUniformMatrix4fv(_unif_cammat4, 1, GL_FALSE, (GLfloat*)calc);
    
    glVertexAttribPointer(_attr_pos, 2, GL_FLOAT, GL_FALSE, 0, (GLvoid*)posTri);
    glVertexAttribPointer(_attr_uv, 2, GL_FLOAT, GL_FALSE, 0, (GLvoid*)uv);

    glUniform1f(_unif_alpha, 1);
    glUniform4f(_unif_color, 0, 0, 0, 1);


    
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);

    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    
}

float rrr = 0;

-(void)renderingPMD{

    
    //フレームバッファへ一度レンダリングする
    glBindFramebuffer(GL_FRAMEBUFFER, _def_frame_buffer);
    NSLog(@"_def_frame_buffer ==== %d",_def_frame_buffer);

    NSLog(@"ERROR ==== %d",glGetError());
    assert(glGetError() == GL_NO_ERROR);
    
    //viewportの変更
    //glViewport(0, 0, width, height);
    glViewport(0, 0, view.bounds.size.width, view.bounds.size.height);
    
    //バッファをクリア
    glClearColor(1.0f, 0.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    
    //カメラ位置、移動などの計算
    //射影 x view
    mat4* view2 = [cam viewMat4];
    mat4* parspective = [cam perspectiveMat4];
    mat4* mat1 = [parspective multiplyMat4:view2];
    
    //(射影 x view) x ワールド加工系
    mat4* rotate = [mat4 rotate:[[vec3 alloc] init:0 y:1 z:0] radian:rrr];
    rrr += 0.1;
    
    //mat4* transform = [mat4 translate:[[vec3 alloc] init:x * 3 y:0 z:z * 3]];
    mat4* matdata = [mat1 multiplyMat4:rotate];

    
    
    //シェーダーの利用を開始
    glUseProgram(_program);
    
    //頂点シェーダへの引数割り当てを有効にする
    glEnableVertexAttribArray(_attr_pos);
    glEnableVertexAttribArray(_attr_uv);
    
    //背面をかリング
    glCullFace(GL_BACK);
    
    //テクスチャの指定
    glUniform1i(_unif_texture, 0);
    
    GLfloat calc[4][4];
    [matdata exportArrayGLType:calc];
    glUniformMatrix4fv(_unif_cammat4, 1, GL_FALSE, (GLfloat*)calc);
    
    vec3raw* pospt = &pmdfile->_result.vertices->position;
    glVertexAttribPointer(_attr_pos, 3, GL_FLOAT, GL_FALSE, sizeof(PmdVertex), pospt);
    
    vec2raw* uvpt = &pmdfile->_result.vertices->uv;
    glVertexAttribPointer(_attr_uv, 2, GL_FLOAT, GL_FALSE, sizeof(PmdVertex), uvpt);
    
    GLint beginIndicesIndex = 0;
    
    glUniform1f(_unif_alpha, 1);
    
    
    //マテリアルの数だけ描写を行う。
    for(int i = 0;i < pmdfile->_result.materials_num; i++){
        
        PmdMaterial* mat = &pmdfile->_result.materials[i];
        NSString *texture_name = [[NSString alloc] initWithUTF8String:mat->diffuse_texture_name ];
        texture* t = [tex get:texture_name];
        
        if(t == nil){
            glUniform4f(_unif_color, mat->diffuse.x, mat->diffuse.y, mat->diffuse.z, mat->diffuse.w);
        }else{
            [t bind];
            glUniform1i(_unif_texture, 0);
            glUniform4f(_unif_color, 0, 0, 0, 0);
        }
        
        //インデックスバッファでレンダリング
        glDrawElements(GL_TRIANGLES, mat->indices_num, GL_UNSIGNED_SHORT, pmdfile->_result.indices + beginIndicesIndex);
        assert(glGetError() == GL_NO_ERROR);
        beginIndicesIndex += mat->indices_num;
        
    }
    
    
}

-(void)renderingPMDEdge:(mat4*)matdata{
    
    //なんで、カリングを逆にするかは、
    //これがわかりやすい。
    //http://wgld.org/d/webgl/w048.html
    
    //シェーダーの利用を開始
    glUseProgram(_program_edge);
    
    //前面をカリング
    glCullFace(GL_FRONT);
    
    //頂点シェーダへの引数割り当てを有効にする
    glEnableVertexAttribArray(_attr_pos_edge);
    glEnableVertexAttribArray(_attr_normal_edge);
    
    glUniform4f(_unif_color_edge, 0.0f, 0.0f, 0.0f, 1.0f);
    glUniform1f(_unif_edgesize, 0.005f);

    GLfloat calc[4][4];
    [matdata exportArrayGLType:calc];
    glUniformMatrix4fv(_unif_cammat4_edge, 1, GL_FALSE, (GLfloat*)calc);
    
    vec3raw* pospt = &pmdfile->_result.vertices->position;
    glVertexAttribPointer(_attr_pos_edge, 3, GL_FLOAT, GL_FALSE, sizeof(PmdVertex), pospt);//先頭
    
    vec3raw* normalpt = &pmdfile->_result.vertices->normal;
    glVertexAttribPointer(_attr_normal_edge, 3, GL_FLOAT, GL_FALSE, sizeof(PmdVertex), normalpt); //pos->uv->ここ
    
    glDrawElements(GL_TRIANGLES, pmdfile->_result.indices_num, GL_UNSIGNED_SHORT, pmdfile->_result.indices);
    
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

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self sceneRendering];

}


#pragma mark -  OpenGL ES 2 shader compilation

//シェーダーのロード、コンパイル、リンク、引数の指定まで
- (BOOL)loadShaders:(GLuint*)pg vshname:(NSString*)vshname fshname:(NSString*)fshname
{
    GLuint vertShader, fragShader;
    
    // Create shader program.
    *pg = glCreateProgram();
    
    vertShader = [self attachShader:pg filename:vshname shaderType:GL_VERTEX_SHADER];
    fragShader = [self attachShader:pg filename:fshname shaderType:GL_FRAGMENT_SHADER];
    
    BOOL link_success = [self linkProgram:*pg];
    
    [self deleteShader:pg shaderPointer:&vertShader];
    [self deleteShader:pg shaderPointer:&fragShader];
    
    //失敗したのにできちゃってる場合は削除
    if (!link_success && *pg) {
        glDeleteProgram(*pg);
        *pg = 0;
    }
    
    return link_success;
}

-(void)deleteShader:(GLuint*)pg shaderPointer:(GLuint*)shaderPointer{
    
    if(pg){
        glDetachShader(*pg, *shaderPointer);
    }
    
    if (*shaderPointer) {
        glDeleteShader(*shaderPointer);
        *shaderPointer = 0;
    }
    
}

//shaderをロードしたあと、programにshaderを割り当て。
-(GLuint)attachShader:(GLuint*)pg filename:(NSString *)filename shaderType:(GLint)shaderType{
    
    GLuint shaderPointer = 0;
    
    // 頂点シェーダーよみこむぜｓ
    NSString *ShaderPathname = [[NSBundle mainBundle] pathForResource:filename ofType:@""];
    if (![self compileShader:&shaderPointer type:shaderType file:ShaderPathname]) {
        NSLog(@"Failed to compile %@",filename);
        return shaderPointer;
    }
    
    // 頂点シェーダーわりあてー.
    glAttachShader(*pg, shaderPointer);
    
    return shaderPointer;
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
