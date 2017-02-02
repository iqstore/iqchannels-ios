//
// Created by Ivan Korobkov on 06/09/16.
//

#import "IQChannelsConfig.h"
#import "IQJSON.h"


@implementation IQChannelsConfig
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQChannelsConfig *config = [[IQChannelsConfig alloc] init];
    config.address = [IQJSON stringFromObject:object key:@"address"];
    config.channel = [IQJSON stringFromObject:object key:@"channel"];
    config.disableUnreadBadge = [IQJSON stringFromObject:object key:@"disableUnreadBadge"];
    return config;
}

- (instancetype)init {
    if ([super init]) {
        return self;
    }
    return nil;
}

- (instancetype)initWithAddress:(NSString *)address channel:(NSString *)channel {
    if (!(self = [super init])) {
        return nil;
    }

    _address = address;
    _channel = channel;
    return self;
}

- (NSDictionary *)toJSONObject {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    if (_address != nil) {
        d[@"address"] = _address;
    }
    if (_channel != nil) {
        d[@"channel"] = _channel;
    }
    if (_disableUnreadBadge) {
        d[@"disableUnreadBadge"] = @(_disableUnreadBadge);
    }
    return d;
}

- (id)copyWithZone:(NSZone *)zone {
    IQChannelsConfig *copy = [[IQChannelsConfig allocWithZone:zone] init];
    copy.channel = _channel;
    copy.address = _address;
    copy.disableUnreadBadge = _disableUnreadBadge;
    return copy;
}
@end
