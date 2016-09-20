//
// Created by Ivan Korobkov on 06/09/16.
//

#import "IQError.h"
#import "IQJSON.h"


@implementation IQError
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQError *error = [[IQError alloc] init];
    error.Code = [IQJSON stringFromObject:object key:@"Code"];
    error.Text = [IQJSON stringFromObject:object key:@"Text"];
    return error;
}

- (id)copyWithZone:(NSZone *)zone {
    IQError *copy = [IQError allocWithZone:zone];
    copy.Code = _Code;
    copy.Text = _Text;
    return copy;
}

@end
