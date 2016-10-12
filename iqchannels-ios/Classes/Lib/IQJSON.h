//
//  IQJSON.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>

@interface IQJSON : NSObject
+ (id _Nullable)objectWithData:(NSData * _Nonnull)data error:(NSError *_Nullable * _Nullable)error;

+ (NSString * _Nullable)stringFromObject:(NSDictionary * _Nullable)object key:(NSString * _Nonnull)key;
+ (NSNumber * _Nullable)numberFromObject:(NSDictionary * _Nullable)object key:(NSString * _Nonnull)key;
+ (int32_t)int32FromObject:(NSDictionary * _Nullable)object key: (NSString * _Nonnull)key;
+ (int64_t)int64FromObject:(NSDictionary * _Nullable)object key: (NSString * _Nonnull)key;
+ (BOOL)boolFromObject:(NSDictionary * _Nullable)object key: (NSString * _Nonnull)key;
+ (NSDictionary * _Nullable)dictFromObject:(NSDictionary * _Nullable)object key: (NSString * _Nonnull)key;
+ (NSArray * _Nullable)arrayFromObject:(NSDictionary * _Nullable)object key: (NSString * _Nonnull)key;
@end
