//
//  IQJSON.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQJSON.h"

@implementation IQJSON
+ (id _Nullable)objectWithData:(NSData * _Nonnull)data error:(NSError * _Nullable *)error {
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
}

+ (NSString * _Nullable)stringFromObject:(NSDictionary * _Nullable)object key:(NSString * _Nonnull)key {
    if (object == nil) {
        return nil;
    }
    
    id val = object[key];
    if (val == nil) {
        return nil;
    }
    if (![val isKindOfClass:NSString.class]) {
        return nil;
    }
    return val;
}

+ (NSNumber * _Nullable)numberFromObject:(NSDictionary * _Nullable)object key:(NSString * _Nonnull)key {
    if (object == nil) {
        return nil;
    }
    
    id val = object[key];
    if (val == nil) {
        return nil;
    }
    if (![val isKindOfClass:NSNumber.class]) {
        return nil;
    }
    return val;
}

+ (int32_t)int32FromObject:(NSDictionary * _Nullable)object key: (NSString * _Nonnull)key {
    NSNumber *number = [self numberFromObject:object key:key];
    if (number == nil) {
        return 0;
    }
    
    return number.longValue;
}

+ (int64_t)int64FromObject:(NSDictionary * _Nullable)object key: (NSString * _Nonnull)key {
    NSNumber *number = [self numberFromObject:object key:key];
    if (number == nil) {
        return 0;
    }
    
    return number.longLongValue;
}

+ (BOOL)boolFromObject:(NSDictionary * _Nullable)object key: (NSString * _Nonnull)key {
    NSNumber *number = [self numberFromObject:object key:key];
    if (number == nil) {
        return NO;
    }
    
    return number.boolValue;
}

+ (NSDictionary * _Nullable)dictFromObject:(NSDictionary * _Nullable)object key: (NSString * _Nonnull)key {
    if (object == nil) {
        return nil;
    }
    
    id val = object[key];
    if (val == nil) {
        return nil;
    }
    if (![val isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    return val;
}

+ (NSArray * _Nullable)arrayFromObject:(NSDictionary * _Nullable)object key: (NSString * _Nonnull)key {
    if (object == nil) {
        return nil;
    }
    
    id val = object[key];
    if (val == nil) {
        return nil;
    }
    if (![val isKindOfClass:NSArray.class]) {
        return nil;
    }
    return val;
}
@end
