//
//  IQChannelThread.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQChannelThread.h"
#import "IQJSON.h"
#import "IQChannelEvent.h"
#import "IQChannelMessage.h"
#import "IQChannel.h"


@implementation IQChannelThread
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQChannelThread *thread = [[IQChannelThread alloc] init];
    thread.Id = [IQJSON int64FromObject:object key:@"Id"];
    thread.ChannelId = [IQJSON int64FromObject:object key:@"ChannelId"];
    thread.ClientId = [IQJSON int64FromObject:object key:@"ClientId"];
    thread.EventId = [IQJSON numberFromObject:object key:@"EventId"];

    thread.ClientUnread = [IQJSON int32FromObject:object key:@"ClientUnread"];
    thread.UserUnread = [IQJSON int32FromObject:object key:@"UserUnread"];

    thread.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];
    thread.UpdatedAt = [IQJSON int64FromObject:object key:@"UpdatedAt"];

    NSArray *messages = [IQChannelMessage fromJSONArray:[IQJSON arrayFromObject:object key:@"Messages"]];
    if (messages != nil) {
        thread.Messages = [[NSMutableArray alloc] initWithArray:messages];
    }

    return thread;
}

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }

    _Messages = [[NSMutableArray alloc] init];
    return self;
}

+ (NSArray<IQChannelThread *> *_Nonnull)fromJSONArray:(id _Nullable)array {
    if (array == nil) {
        return @[];
    }

    NSMutableArray<IQChannelThread *> *threads = [[NSMutableArray alloc] init];
    for (id item in array) {
        IQChannelThread *user = [IQChannelThread fromJSONObject:item];
        if (user == nil) {
            continue;
        }

        [threads addObject:user];
    }
    return threads;
}

- (id)copyWithZone:(NSZone *)zone {
    IQChannelThread *copy = [[IQChannelThread allocWithZone:zone] init];
    copy.Id = _Id;
    copy.ChannelId = _ChannelId;
    copy.ClientId = _ClientId;
    copy.EventId = _EventId;

    copy.ClientUnread = _ClientUnread;
    copy.UserUnread = _UserUnread;

    copy.CreatedAt = _CreatedAt;
    copy.UpdatedAt = _UpdatedAt;

    if (_Messages != nil) {
        copy.Messages = [[NSMutableArray alloc] initWithArray:_Messages copyItems:YES];
    }
    return copy;
}

- (void)applyEvents:(NSArray<IQChannelEvent *> *_Nullable)events {
    if (events == nil) {
        return;
    }

    for (IQChannelEvent *event in events) {
        [self applyEvent:event];
    }
}

- (void)appendMessage:(IQChannelMessage *_Nullable)message {
    if (message == nil) {
        return;
    }
    if (_Messages == nil) {
        return;
    }

    [_Messages addObject:message];
}

- (void)appendOutgoingMessage:(IQChannelMessage *)message {
    if (message == nil) {
        return;
    }

    IQChannelMessage *local = [self clientMessageByLocalId:message.LocalId];
    if (local != nil) {
        return;
    }

    [self appendMessage:message];
}

- (void)prependMessages:(NSArray<IQChannelMessage *> *_Nullable)messages {
    if (messages == nil || messages.count == 0) {
        return;
    }

    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:messages copyItems:YES];
    if (_Messages != nil) {
        [temp addObjectsFromArray:_Messages];
    }
    _Messages = temp;
}

- (void)applyEvent:(IQChannelEvent *_Nullable)event {
    if (event == nil) {
        return;
    }
    if (event.Id < _EventId.longLongValue) {
        return;
    }
    _EventId = @(event.Id);

    // Apply the event to the thread.
    if ([event.Type isEqualToString:IQChannelEventMessageCreated]) {
        [self applyMessageCreatedEvent:event];

    } else if ([event.Type isEqualToString:IQChannelEventMessageRead]) {
        [self applyMessageReadEvent:event];

    } else if ([event.Type isEqualToString:IQChannelEventTyping]) {
        [self applyTypingEvent:event];
    }

    // Apply the event to the messages if present.
    if (_Messages != nil) {
        IQChannelMessage *local = [self messageById:event.MessageId.longLongValue];
        if (local != nil) {
            [local applyEvent:event];
        }
    }
}

- (void)applyMessageCreatedEvent:(IQChannelEvent *)event {
    if ([event.Message.Author isEqualToString:IQChannelAuthorClient]) {
        _UserUnread++;
    } else {
        _ClientUnread++;
    }

    if (event.Message) {
        IQChannelMessage *local = [self clientMessageByLocalId:event.Message.LocalId];
        if (local != nil) {
            [local applyEvent:event];
        } else {
            [_Messages addObject:event.Message];
        }
    }
}

- (void)applyMessageReadEvent:(IQChannelEvent *)event {
    if (event.ClientId != nil) {
        _ClientUnread--;
    } else {
        _UserUnread--;
    }
}

- (void)applyTypingEvent:(IQChannelEvent *)event {
    if (event.ClientId != nil) {
        _ClientTypingAt = event.CreatedAt;
    } else {
        _UserTypingAt = event.CreatedAt;
    }
}

- (IQChannelMessage *)messageById:(int64_t)messageId {
    if (_Messages == nil) {
        return nil;
    }

    for (IQChannelMessage *message in _Messages.reverseObjectEnumerator) {
        if (message.Id == messageId) {
            return message;
        }
    }
    return nil;
}

- (IQChannelMessage *_Nullable)clientMessageByLocalId:(int64_t)localId {
    if (_Messages == nil) {
        return nil;
    }

    for (IQChannelMessage *message in _Messages.reverseObjectEnumerator) {
        if ([message.Author isEqualToString:IQChannelAuthorClient]) {
            if (message.LocalId == localId) {
                return message;
            }
        }
    }
    return nil;
}
@end


@implementation IQChannelThread (Local)
- (BOOL) UserIsTyping {
    int64_t now = (int64_t) ([[NSDate date] timeIntervalSince1970] * 1000);
    return (now - self.UserTypingAt) < 2000;
}
@end
