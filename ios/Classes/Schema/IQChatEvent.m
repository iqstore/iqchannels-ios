//
//  IQChatEvent.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQChatEvent.h"
#import "IQChat.h"
#import "IQChatMessage.h"
#import "IQJSON.h"
#import "IQRelationMap.h"
#import "IQClient.h"
#import "IQUser.h"


@implementation IQChatEvent
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQChatEvent *event = [[IQChatEvent alloc] init];
    event.Id = [IQJSON int64FromObject:object key:@"Id"];
    event.Type = [IQJSON stringFromObject:object key:@"Type"];
    event.ChatId = [IQJSON int64FromObject:object key:@"ChatId"];
    event.Public = [IQJSON boolFromObject:object key:@"Public"];
    event.Transitive = [IQJSON boolFromObject:object key:@"Transitive"];

    event.SessionId = [IQJSON numberFromObject:object key:@"SessionId"];
    event.MessageId = [IQJSON numberFromObject:object key:@"MessageId"];
    event.MemberId = [IQJSON numberFromObject:object key:@"MemberId"];

    event.Actor = [IQJSON stringFromObject:object key:@"Actor"];
    event.ClientId = [IQJSON numberFromObject:object key:@"ClientId"];
    event.UserId = [IQJSON numberFromObject:object key:@"UserId"];

    event.Messages = [IQChatMessage fromJSONArray:[IQJSON arrayFromObject:object key:@"Messages"]];

    return event;
}

- (instancetype)init {
    return self = [super init];
}

+ (NSArray<IQChatEvent *> *)fromJSONArray:(id)array {
    if (array == nil) {
        return @[];
    }
    if (![array isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<IQChatEvent *> *threads = [[NSMutableArray alloc] init];
    for (id item in array) {
        IQChatEvent *thread = [IQChatEvent fromJSONObject:item];
        if (thread == nil) {
            continue;
        }
        [threads addObject:thread];
    }
    return threads;
}
@end
