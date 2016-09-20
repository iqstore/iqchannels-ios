//
//  IQChannelMessage.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQChannelMessage.h"
#import "IQJSON.h"
#import "IQUser.h"
#import "IQClient.h"
#import "IQChannelMessageForm.h"
#import "IQChannelEvent.h"


@implementation IQChannelMessage {
    NSString *_senderId;
}

+ (NSString *)senderIdWithUserId:(int64_t)userId {
    return [NSString stringWithFormat:@"user-%lli", userId];
}

+ (NSString *)senderIdWithClientId:(int64_t)clientId {
    return [NSString stringWithFormat:@"client-%lli", clientId];
}

+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQChannelMessage *message = [[IQChannelMessage alloc] init];
    message.Id = [IQJSON int64FromObject:object key:@"Id"];
    message.ThreadId = [IQJSON int64FromObject:object key:@"ThreadId"];
    message.LocalId = [IQJSON int64FromObject:object key:@"LocalId"];

    message.Author = [IQJSON stringFromObject:object key:@"Author"];
    message.ClientId = [IQJSON numberFromObject:object key:@"ClientId"];
    message.UserId = [IQJSON numberFromObject:object key:@"UserId"];

    message.Payload = [IQJSON stringFromObject:object key:@"Payload"];
    message.Text = [IQJSON stringFromObject:object key:@"Text"];
    message.EventId = [IQJSON numberFromObject:object key:@"EventId"];

    message.Received = [IQJSON boolFromObject:object key:@"Received"];
    message.Read = [IQJSON boolFromObject:object key:@"Read"];

    message.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];
    message.UpdatedAt = [IQJSON int64FromObject:object key:@"UpdatedAt"];
    message.ReceivedAt = [IQJSON numberFromObject:object key:@"ReceivedAt"];
    message.ReadAt = [IQJSON numberFromObject:object key:@"ReadAt"];
    return message;
}

+ (NSArray<IQChannelMessage *> *_Nonnull)fromJSONArray:(id _Nullable)array {
    if (array == nil) {
        return @[];
    }
    if (![array isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<IQChannelMessage *> *messages = [[NSMutableArray alloc] init];
    for (id item in array) {
        IQChannelMessage *user = [IQChannelMessage fromJSONObject:item];
        if (user == nil) {
            continue;
        }

        [messages addObject:user];
    }
    return messages;
}

- (instancetype)initWithClientId:(int64_t)clientId form:(IQChannelMessageForm *)form {
    if (!(self = [super init])) {
        return nil;
    }

    _LocalId = form.LocalId;
    _Author = IQChannelAuthorClient;
    _ClientId = @(clientId);
    _Payload = form.Payload;
    _Text = form.Text;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    IQChannelMessage *copy = [[IQChannelMessage allocWithZone:zone] init];
    [copy copyDataFromMessage:self];
    return copy;
}

- (void)copyDataFromMessage:(IQChannelMessage *)message {
    _Id = message.Id;
    _ThreadId = message.ThreadId;
    _LocalId = message.LocalId;

    // Author
    _Author = message.Author;
    _ClientId = message.ClientId;
    _UserId = message.UserId;

    // Payload
    _Payload = message.Payload;
    _Text = message.Text;
    _EventId = message.EventId;

    // Flags
    _Received = message.Received;
    _Read = message.Read;

    _CreatedAt = message.CreatedAt;
    _UpdatedAt = message.UpdatedAt;
    _ReceivedAt = message.ReceivedAt;
    _ReadAt = message.ReadAt;

    // Transitive
    _User = [message.User copy];
    _Client = [message.Client copy];
}

- (void)applyEvent:(IQChannelEvent *)event {
    if (event.MessageId == nil) {
        return;
    }
    if (_EventId.longLongValue > event.Id) {
        return;
    }
    _EventId = @(event.Id);

    // Check that message ids match.
    if (_Id != event.MessageId.longLongValue) {
        if (![event.Message.Author isEqualToString:IQChannelAuthorClient]) {
            return;
        }
        if (_LocalId != event.Message.LocalId) {
            return;
        }
    }

    // Apply the event.
    if ([event.Type isEqualToString:IQChannelEventMessageCreated]) {
        [self copyDataFromMessage:event.Message];

    } else if ([event.Type isEqualToString:IQChannelEventMessageReceived]) {
        _Received = YES;
        _ReceivedAt = @(event.CreatedAt);

    } else if ([event.Type isEqualToString:IQChannelEventMessageRead]) {
        _Read = YES;
        _ReadAt = @(event.CreatedAt);

        if (!_Received) {
            _Received = YES;
            _ReceivedAt = @(event.CreatedAt);
        }
    }
}

#pragma mark JSQMessageData

- (NSString *)senderId {
    if (_senderId != nil) {
        return _senderId;
    }

    if ([_Author isEqualToString:IQChannelAuthorClient]) {
        _senderId = [IQChannelMessage senderIdWithClientId:_ClientId.longLongValue];
    } else {
        _senderId = [IQChannelMessage senderIdWithUserId:_UserId.longLongValue];
    }
    return _senderId;
}

- (NSString *)senderDisplayName {
    if ([_Author isEqualToString:IQChannelAuthorClient]) {
        return _Client ? _Client.Name : @"Client";
    } else {
        return _User ? _User.Name : @"User";
    }
}

- (NSDate *)date {
    NSTimeInterval time = _CreatedAt / 1000.0;
    return [NSDate dateWithTimeIntervalSince1970:time];
}

- (BOOL)isMediaMessage {
    return NO;
}

- (NSUInteger)messageHash {
    return (NSUInteger) (_LocalId ^ (_LocalId >> 32));
}

- (NSString *)text {
    return _Text;
}

- (id <JSQMessageMediaData>)media {
    // TODO: Implement.
    return nil;
}
@end
