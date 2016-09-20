//
//  IQChannelMessagesQuery.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQChannelMessagesQuery.h"

@implementation IQChannelMessagesQuery
- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    return self;
}

- (instancetype)initWithMaxId:(NSNumber *)maxId {
    if (!(self = [super init])) {
        return nil;
    }
    _MaxId = maxId;
    return self;
}

- (NSDictionary *)toJSONObject {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    if (_MaxId != nil) {
        d[@"MaxId"] = _MaxId;
    }
    if (_Limit != nil) {
        d[@"Limit"] = _Limit;
    }
    return d;
}

- (id)copyWithZone:(NSZone *)zone {
    IQChannelMessagesQuery *copy = [[IQChannelMessagesQuery allocWithZone:zone] init];
    copy.MaxId = _MaxId;
    copy.Limit = _Limit;
    return copy;
}
@end
