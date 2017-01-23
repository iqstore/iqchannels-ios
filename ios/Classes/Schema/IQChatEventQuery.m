//
// Created by Ivan Korobkov on 06/09/16.
//

#import "IQChatEventQuery.h"
#import "IQJSON.h"


@implementation IQChatEventQuery
- (instancetype)init {
    return self;
}

- (instancetype)initWithLastEventId:(NSNumber *)lastEventId {
    if (!(self = [super init])) {
        return nil;
    }

    _LastEventId = lastEventId;
    return self;
}

- (NSDictionary *)toJSONObject {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    if (_LastEventId != nil) {
        d[@"LastEventId"] = _LastEventId;
    }
    if (_Limit != nil) {
        d[@"Limit"] = _Limit;
    }
    return d;
}
@end
