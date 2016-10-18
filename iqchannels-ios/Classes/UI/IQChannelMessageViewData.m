//
// Created by Ivan Korobkov on 11/10/2016.
//

#import "IQChannelMessageViewData.h"
#import "IQChannelMessage.h"
#import "IQClient.h"
#import "IQUser.h"
#import "IQChannelEvent.h"


@implementation IQChannelMessageViewData {
    NSString *_senderId;
    NSString *_senderDisplayName;
    NSDate *_date;
    NSUInteger _hash;
}

- (instancetype)initWithMessage:(IQChannelMessage *)message {
    if (!(self = [super init])) {
        return nil;
    }

    _message = [message copy];
    if ([_message.Author isEqualToString:IQChannelAuthorClient]) {
        _senderId = [IQChannelMessageViewData senderIdWithClientId:_message.ClientId.longLongValue];
        _senderDisplayName = _message.Client && _message.Client.Name ? _message.Client.Name : @"Client";
    } else {
        _senderId = [IQChannelMessageViewData senderIdWithUserId:_message.UserId.longLongValue];
        _senderDisplayName = _message.User && _message.User.Name ? _message.User.Name : @"User";
    }

    if (_message.CreatedAt == 0) {
        _date = [NSDate date];
    } else {
        _date = [NSDate dateWithTimeIntervalSince1970:_message.CreatedAt / 1000.0];
    }
    _hash = [IQChannelMessageViewData hashWithMessage:_message];
    return self;
}

- (void)applyEvent:(IQChannelEvent *)event {
    [_message applyEvent:event];
}

#pragma mark JSQMessageData

- (NSString *)senderId {
    return _senderId;
}

- (NSString *)senderDisplayName {
    return _senderDisplayName;
}

- (NSDate *)date {
    return _date;
}

- (BOOL)isMediaMessage {
    return [_message.Payload isEqualToString:IQChannelPayloadFile];
}

- (NSUInteger)messageHash {
    return _hash;
}

- (NSString *)text {
    return _message.Text ? _message.Text : @"";
}

- (id <JSQMessageMediaData>)media {
    // TODO: Implement.
    return nil;
}

+ (NSString *)senderIdWithClientId:(int64_t)clientId {
    return [NSString stringWithFormat:@"client-%lli", clientId];
}

+ (NSString *)senderIdWithUserId:(int64_t)userId {
    return [NSString stringWithFormat:@"user-%lli", userId];
}

+ (NSUInteger)hashWithMessage:(IQChannelMessage *)message {
    NSUInteger hash = 31;
    hash = hash * 31 + ((NSUInteger) (message.Id ^ (message.Id >> 32)));
    hash = hash * 31 + ((NSUInteger) (message.LocalId ^ (message.LocalId >> 32)));
    return hash;
}

@end
