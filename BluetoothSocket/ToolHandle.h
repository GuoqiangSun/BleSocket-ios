//
//  ToolHandle.h
//  BluetoothSocket
//
//  Created by Mac on 2018/4/13.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToolHandle : NSObject

+ (NSString *)toJsonString:(id)objet;

+ (NSMutableData *)checkeffData:(NSMutableData *)data;

+ (NSMutableData *)checkeeeData:(NSMutableData *)data;

+ (NSMutableData *)checke55Data:(NSMutableData *)data;

+ (NSMutableData *)getPacketData:(NSMutableData *)data;

+ (NSData *)getData:(uint8_t)da;

+ (uint8_t)getByteWithData:(NSData *)data offset:(int)offset;

+ (NSMutableData *)escapingSpecialCharacters:(NSMutableData *)data;

Byte myCRC8(Byte *buffer,int start,int end);

@end
