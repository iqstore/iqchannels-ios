//
//  IQChannelEvent.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQChannelEvent.h"
#import "IQChannelThread.h"
#import "IQChannelMessage.h"
#import "IQJSON.h"
#import "IQRelationMap.h"


@implementation IQChannelEvent
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQChannelEvent *event = [[IQChannelEvent alloc] init];
    event.Id = [IQJSON int64FromObject:object key:@"Id"];
    event.Type = [IQJSON stringFromObject:object key:@"Type"];
    event.ClientId = [IQJSON numberFromObject:object key:@"ClientId"];
    event.UserId = [IQJSON numberFromObject:object key:@"UserId"];
    event.ChannelId = [IQJSON int64FromObject:object key:@"ChannelId"];
    event.ThreadId = [IQJSON int64FromObject:object key:@"ThreadId"];
    event.MessageId = [IQJSON numberFromObject:object key:@"MessageId"];
    event.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];

    NSDictionary *thread = [IQJSON dictFromObject:object key:@"Thread"];
    if (thread != nil) {
        event.Thread = [IQChannelThread fromJSONObject:thread];
    }

    NSDictionary *message = [IQJSON dictFromObject:object key:@"Message"];
    if (message != nil) {
        event.Message = [IQChannelMessage fromJSONObject:message];
    }
    return event;
}

+ (NSArray<IQChannelEvent *> *)fromJSONArray:(id)array {
    if (array == nil) {
        return @[];
    }
    if (![array isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<IQChannelEvent *> *threads = [[NSMutableArray alloc] init];
    for (id item in array) {
        IQChannelEvent *thread = [IQChannelEvent fromJSONObject:item];
        if (thread == nil) {
            continue;
        }
        [threads addObject:thread];
    }
    return threads;
}

- (id)copyWithZone:(NSZone *)zone {
    IQChannelEvent *copy = [[IQChannelEvent allocWithZone:zone] init];
    copy.Id = _Id;
    copy.Type = _Type;
    copy.ClientId = _ClientId;
    copy.UserId = _UserId;
    copy.ChannelId = _ChannelId;
    copy.ThreadId = _ThreadId;
    copy.MessageId = _MessageId;
    copy.CreatedAt = _CreatedAt;

    copy.Thread = [_Thread copyWithZone:zone];
    copy.Message = [_Message copyWithZone:zone];
    return self;
}
@end
