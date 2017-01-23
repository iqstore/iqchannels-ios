//
//  IQChat.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQChat.h"
#import "IQJSON.h"
#import "IQChatMessage.h"
#import "IQChannel.h"
#import "IQClient.h"


@implementation IQChat
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQChat *chat = [[IQChat alloc] init];
    chat.Id = [IQJSON int64FromObject:object key:@"Id"];
    chat.ChannelId = [IQJSON int64FromObject:object key:@"ChannelId"];
    chat.ClientId = [IQJSON int64FromObject:object key:@"ClientId"];
    chat.Open = [IQJSON boolFromObject:object key:@"Open"];

    chat.EventId = [IQJSON numberFromObject:object key:@"EventId"];
    chat.MessageId = [IQJSON numberFromObject:object key:@"MessageId"];
    chat.SessionId = [IQJSON numberFromObject:object key:@"SessionId"];
    chat.AssigneeId = [IQJSON numberFromObject:object key:@"AssigneeId"];

    chat.ClientUnread = [IQJSON int32FromObject:object key:@"ClientUnread"];
    chat.UserUnread = [IQJSON int32FromObject:object key:@"UserUnread"];
    chat.TotalMembers = [IQJSON int32FromObject:object key:@"TotalMembers"];

    chat.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];
    chat.OpenedAt = [IQJSON numberFromObject:object key:@"OpenedAt"];
    chat.ClosedAt = [IQJSON numberFromObject:object key:@"ClosedAt"];
    return chat;
}

- (instancetype)init {
    return self = [super init];
}

+ (NSArray<IQChat *> *_Nonnull)fromJSONArray:(id _Nullable)array {
    if (array == nil) {
        return @[];
    }

    NSMutableArray<IQChat *> *chats = [[NSMutableArray alloc] init];
    for (id item in array) {
        IQChat *user = [IQChat fromJSONObject:item];
        if (user == nil) {
            continue;
        }

        [chats addObject:user];
    }
    return chats;
}
@end
