//
//  IQFileToken.m
//  IQChannels
//
//  Created by Ivan Korobkov on 16.06.2020.
//

#import "IQFileToken.h"
#import "IQJSON.h"

@implementation IQFileToken
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQFileToken *error = [[IQFileToken alloc] init];
    error.Token = [IQJSON stringFromObject:object key:@"Token"];
    return error;
}
@end
