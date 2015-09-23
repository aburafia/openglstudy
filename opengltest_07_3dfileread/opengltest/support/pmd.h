/*
 * support_gl_Pmd.h
 *
 * 簡易MMDファイル読み込みライブラリ
 * 各構造体の文字列部分についてはsjis->utf8変換を見込んで大きめに確保してある
 *  Created on: 2014/02/18
 */
#import "vert.h"
#import "textures.h"
#import "support_RawData.h"

/**
 * PMDファイルのヘッダ情報
 */
typedef struct PmdHeader {
    GLfloat version;
    GLchar name[32]; //モデル名
    GLchar comment[256 + 128]; //コメント
} PmdHeader;

/**
 * PMDファイルが格納する頂点情報
 */
typedef struct PmdVertex {
    vec3raw position;
    vec2raw uv;
    vec3raw normal;

    /**
     * サンプルでは使用しないが、PMDファイル仕様的に含まれている情報
     */
    struct {
        GLshort bone_num[2]; //関連付けられたボーン番号

        /**
         * ボーンの重み情報（最大100）
         * bone_num[0]の影響度がbone_weight、bone_num[1]の影響度が100 - bone_weightで表される
         */
        GLbyte bone_weight;

        GLbyte edge_flag; //エッジ表示フラグ 0=無効 1=有効
    } extra;
} PmdVertex;

/**
 * PMD材質情報
 */
typedef struct PmdMaterial {

    vec4raw diffuse; //拡散反射光
    GLint indices_num; //頂点数
    GLchar diffuse_texture_name[20 + 12]; //テクスチャファイル名

    /**
     * サンプルでは使用しないが、PMDファイル仕様的に含まれている情報
     */
    struct {

        GLbyte edge_flag; //輪郭フラグ
        GLfloat shininess;
        vec3raw specular_color; //スペキュラ色
        vec3raw ambient_color; //環境光
        GLbyte toon_index;

        /**
         * エフェクト用テクスチャ名
         * .sph/.spaファイルが指定される。サンプル内では利用しない
         */
        GLchar effect_texture_name[20 + 12];
    } extra;

} PmdMaterial;

/**
 * ボーン情報
 */
typedef struct PmdBone {
    GLchar name[20 + 12]; //ボーン名
    GLshort parent_bone_index; //親ボーン番号 無い場合は0xFFFF = -1
    vec3raw position; //ボーンの位置

    /**
     * サンプルでは使用しないが、PMDファイル仕様的に含まれている情報
     */
    struct {
        GLshort tail_pos_bone_index; //制御ボーン
        GLbyte type; //ボーンの種類

        /**
         * IKボーン
         * サンプルではベイク済みもしくは手動制御を前提とする
         */
        GLshort ik_parent_bone_index;
    } extra;
} PmdBone;

/**
 * PMDファイルコンテナ
 */
typedef struct PmdFile {

    PmdHeader header; //ヘッダファイル
    PmdVertex *vertices; //頂点配列
    GLuint vertices_num; //頂点数
    GLushort *indices; //頂点インデックス
    GLuint indices_num; //頂点インデックス数
    PmdMaterial *materials; //材質情報
    GLuint materials_num; //管理している材質数
    PmdBone *bones; //ボーン情報
    GLuint bones_num; //ボーン数
} PmdFile;

@interface pmd : NSObject{
    GLint _attr_pos;
    GLint _attr_uv;
    NSMutableArray* vert_array;
    NSMutableArray* triangle_array;
    
    RawData* data;
    PmdHeader _pmdheader;
    PmdFile _result;
}

-(bool)loadHeader;
-(void)loadVertices;
-(void)loadIndices;
-(void)loadMaterial;
-(void)loadBone;
-(void)loadTextures:(textures*)texlist;

/**
 * PMDファイルをロードする
 */
-(void)load:(const NSString*)file_name;

/**
 * PMDファイルを解放する
 */
-(void)PmdFile_free:(PmdFile *)pmd;

/**
 * 最小最大地点を求める
 */
-(void)calcAABB:(vec3raw*)minPoint maxPoint:(vec3raw*)maxPoint;

@end

