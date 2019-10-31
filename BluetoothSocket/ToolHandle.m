//
//  ToolHandle.m
//  BluetoothSocket
//
//  Created by Mac on 2018/4/13.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "ToolHandle.h"

@implementation ToolHandle

+ (NSString *)toJsonString:(id)objet
{
    NSString *json;
    if (objet == nil) {
        json = @"";
    }else if ([objet isKindOfClass:[NSString class]]){
        json = objet;
    }else{
        NSData *data = [NSJSONSerialization dataWithJSONObject:objet options:NSJSONWritingPrettyPrinted error:nil];
        json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    json = [json stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    json = [json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return json;
}

+ (NSMutableData *)checkeffData:(NSMutableData *)data
{
    NSData *ff = [self getData:0xff];
    NSMutableData *tianchong = [[NSMutableData alloc] init];
    [tianchong appendData:[self getData:0x55]];
    [tianchong appendData:[self getData:0xaa]];
    BOOL res = true;
    while (res) {
        NSRange range = [data rangeOfData:ff options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)];
        if (!range.length) {
            res = false;
        }else{
            [data replaceBytesInRange:range withBytes:tianchong.bytes length:2];
        }
    }
    
    return data;
}

+ (NSMutableData *)checkeeeData:(NSMutableData *)data
{
    NSData *ee = [self getData:0xee];
    NSMutableData *tianchong = [[NSMutableData alloc] init];
    [tianchong appendData:[self getData:0x55]];
    [tianchong appendData:[self getData:0x99]];
    BOOL res = true;
    while (res) {
        NSRange range = [data rangeOfData:ee options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)];
        if (!range.length) {
            res = false;
        }else{
            [data replaceBytesInRange:range withBytes:tianchong.bytes length:2];
        }
    }
    
    return data;
}

+ (NSMutableData *)checke55Data:(NSMutableData *)data
{
    NSData *five = [self getData:0x55];
    NSData *zero = [self getData:0x00];
    NSMutableData *tianchong = [[NSMutableData alloc] init];
    [tianchong appendData:[self getData:0x55]];
    [tianchong appendData:[self getData:0x00]];
    
    NSInteger length = data.length-2;
    
    while (length) {
        NSRange range1 = [data rangeOfData:five options:NSDataSearchBackwards range:NSMakeRange(1, length)];
        if (range1.length) {
            NSData *data1 = [data subdataWithRange:NSMakeRange(range1.location+1, 1)];
            if ([data1 isEqualToData:zero]) {
                
            }else{
                [data replaceBytesInRange:range1 withBytes:tianchong.bytes length:2];
            }
        }
        length--;
    }
    
    return data;
}

+ (NSMutableData *)getPacketData:(NSMutableData *)data
{
    int8_t header = 0xff;
    int8_t len_h = 0x00;
    int8_t len_l = data.length+2;
    uint8_t reserve2 = 0x00;
    uint8_t reserve1 = 0x00;
    int8_t ee = 0xee;
    
    NSMutableData *packetData = [[NSMutableData alloc] init];
    [packetData appendData:[self getData:header]];
    [packetData appendData:[self getData:len_h]];
    [packetData appendData:[self getData:len_l]];
    [packetData appendData:[self getData:reserve2]];
    [packetData appendData:[self getData:reserve1]];
    [packetData appendData:data];
    
    Byte *byte = (Byte*)[packetData bytes];
    Byte b = myCRC8(byte, 3, (int)packetData.length);
    [packetData appendData:[NSData dataWithBytes:&b length:sizeof(b)]];
    [packetData appendData:[self getData:ee]];
    
    packetData = [self checke55Data:packetData];
    packetData = [self checkeffData:packetData];
    packetData = [self checkeeeData:packetData];
    
    
    return packetData;
}


+ (NSMutableData *)escapingSpecialCharacters:(NSMutableData *)data
{
    NSMutableData *ffda = [[NSMutableData alloc] init];
    NSMutableData *eeda = [[NSMutableData alloc] init];
    NSMutableData *fiveda = [[NSMutableData alloc] init];
    
    uint8_t a = 0x55;
    uint8_t b = 0xaa;
    uint8_t c= 0x00;
    uint8_t d = 0x99;
    
    [ffda appendBytes:&a length:1];
    [ffda appendBytes:&b length:1];
    
    [eeda appendBytes:&a length:1];
    [eeda appendBytes:&d length:1];
    
    [fiveda appendBytes:&a length:1];
    [fiveda appendBytes:&c length:1];
    
    if (data.length>3 &&[data rangeOfData:ffda options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)].length) {
        BOOL res = true;
        while (res) {
            NSRange range = [data rangeOfData:ffda options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)];
            uint8_t ff = 0xff;
            if (!range.length) {
                res = false;
            }else{
                [data replaceBytesInRange:range withBytes:&ff length:1];
            }
        }
    }
    
    if (data.length>3 &&[data rangeOfData:eeda options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)].length) {
        BOOL res = true;
        while (res) {
            NSRange range = [data rangeOfData:eeda options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)];
            uint8_t ff = 0xee;
            if (!range.length) {
                res = false;
            }else{
                [data replaceBytesInRange:range withBytes:&ff length:1];
            }
        }
    }
    
    if (data.length>3 &&[data rangeOfData:fiveda options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)].length) {
        BOOL res = true;
        while (res) {
            NSRange range = [data rangeOfData:fiveda options:NSDataSearchBackwards range:NSMakeRange(1, data.length-2)];
            uint8_t ff = 0x55;
            if (!range.length) {
                res = false;
            }else{
                [data replaceBytesInRange:range withBytes:&ff length:1];
            }
        }
    }
    return data;
}

+ (NSData *)getData:(uint8_t)da
{
    NSData *data = [[NSData alloc] initWithBytes:&da length:sizeof(da)];
    return data;
}

+ (uint8_t)getByteWithData:(NSData *)data offset:(int)offset
{
    if (offset > data.length) {
        return 0x00;
    }
    Byte *testByte = (Byte*)[data bytes];
    return testByte[offset];
}

Byte myCRC8(Byte *buffer,int start,int end){
    unsigned char crc = 0x00;   //起始字节00
    for (int j = start; j < end; j++) {
        crc ^= buffer[j] & 0xFF;
        for (int i = 0; i < 8; i++) {
            if ((crc & 0x01) != 0) {
                crc = (crc >> 1) ^ 0x8c;
            } else {
                crc >>= 1;
            }
        }
    }
    return (Byte) (crc & 0xFF);
}


@end
