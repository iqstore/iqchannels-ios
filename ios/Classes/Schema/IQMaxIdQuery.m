//
//  IQMaxIdQuery.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQMaxIdQuery.h"

@implementation IQMaxIdQuery
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
@end
