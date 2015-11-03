/*
 * RawData.c
 *
 *  Created on: 2013/04/07
 */

//#include    "support.h"
#include "support_RawData.h"

/**
 * 読み込んだファイルを解放する
 */
void RawData_freeFile(RawData *rawData) {
    free(rawData->head);
    free(rawData);
}

/**
 * データの長さを取得する
 */
int RawData_getLength(RawData *rawData) {
    return rawData->length;
}

/**
 * 現在の読み取りポインタ位置を取得する
 */
void* RawData_getReadHeader(RawData *rawData) {
    return (void*) rawData->read_head;
}

/**
 * 指定バイト数の情報を読み込む
 */
void RawData_readBytes(RawData* rawData, void* result, int bytes) {
    memcpy(result, rawData->read_head, bytes);
    rawData->read_head += bytes;
}

/**
 * 8bit整数を読み込む
 */
int8_t RawData_read8(RawData* rawData) {
    int8_t result = *rawData->read_head;
    ++rawData->read_head;
    return result;
}

/**
 * 読み取りポインタを指定バイト数移動させる
 */
void RawData_offsetHeader(RawData *rawData, int offsetBytes) {
    rawData->read_head += offsetBytes;
}

/**
 * 読み込みヘッダの位置を指定位置に移動させる
 */
void RawData_setHeaderPosition(RawData *rawData, int position) {
    assert(position >= 0);
    rawData->read_head = ((uint8_t*) rawData->head) + position;
}

/**
 * 読み込める残量を取得する
 */
int RawData_getAvailableBytes(RawData *rawData) {
    return rawData->length - ((int) (rawData->read_head) - (int) ((uint8_t*) rawData->head));
}

/**
 * Big Endian格納の16bit整数を読み込む
 */
int16_t RawData_readBE16(RawData* rawData) {
    int16_t w0 = (int16_t) (rawData->read_head)[0] & 0xFF;
    int16_t w1 = (int16_t) (rawData->read_head)[1] & 0xFF;

    rawData->read_head += 2;

    return (w0 << 8) | w1;
}

/**
 * Big Endian格納の32bit整数を読み込む
 */
int32_t RawData_readBE32(RawData* rawData) {

    int32_t w0 = (int16_t) (rawData->read_head)[0] & 0xFF;
    int32_t w1 = (int16_t) (rawData->read_head)[1] & 0xFF;
    int32_t w2 = (int16_t) (rawData->read_head)[2] & 0xFF;
    int32_t w3 = (int16_t) (rawData->read_head)[3] & 0xFF;

    rawData->read_head += 4;
    return (w0 << 24) | (w1 << 16) | (w2 << 8) | w3;
}

/**
 * Big Endian格納の16bit整数を読み込む
 */
int16_t RawData_readLE16(RawData* rawData) {

    int16_t w0 = (int16_t) (rawData->read_head)[0] & 0xFF;
    int16_t w1 = (int16_t) (rawData->read_head)[1] & 0xFF;

    rawData->read_head += 2;
    return (w1 << 8) | w0;
}

/**
 * Little Endian格納の32bit整数を読み込む
 */
int32_t RawData_readLE32(RawData* rawData) {
    int32_t w0 = (int16_t) (rawData->read_head)[0] & 0xFF;
    int32_t w1 = (int16_t) (rawData->read_head)[1] & 0xFF;
    int32_t w2 = (int16_t) (rawData->read_head)[2] & 0xFF;
    int32_t w3 = (int16_t) (rawData->read_head)[3] & 0xFF;

    rawData->read_head += 4;
    return (w3 << 24) | (w2 << 16) | (w1 << 8) | w0;
}

