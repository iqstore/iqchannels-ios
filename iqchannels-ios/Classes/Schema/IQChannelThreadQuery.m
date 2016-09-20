//
// Created by Ivan Korobkov on 18/09/16.
//

#import "IQChannelThreadQuery.h"


@implementation IQChannelThreadQuery
- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    return self;
}

- (instancetype)initWithMessagesLimit:(NSNumber *)messagesLimit {
    if (!(self = [super init])) {
        return nil;
    }

    _MessagesLimit = messagesLimit;
    return self;
}

- (NSDictionary *)toJSONObject {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    if (_MessagesLimit != nil) {
        d[@"MessagesLimit"] = _MessagesLimit;
    }
    return d;
}
@end
