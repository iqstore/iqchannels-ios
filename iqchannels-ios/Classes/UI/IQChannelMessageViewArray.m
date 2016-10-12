//
// Created by Ivan Korobkov on 11/10/2016.
//

#import "IQChannelMessageViewArray.h"
#import "IQChannelMessageViewData.h"
#import "IQChannelMessage.h"


@implementation IQChannelMessageViewArray {
    int64_t _clientId;
    NSMutableArray<IQChannelMessageViewData *> *_items;
    NSMutableDictionary<NSNumber *, IQChannelMessageViewData *> *_itemsByIds;
    NSMutableDictionary<NSNumber *, IQChannelMessageViewData *> *_itemsByLocalIds;   // Local client messages.
}

- (instancetype _Nonnull)initWithClientId:(int64_t)clientId {
    return [self initWithClientId:clientId messages:@[]];
}

- (instancetype _Nonnull)initWithClientId:(int64_t)clientId messages:(NSArray<IQChannelMessage *> *_Nullable)messages {
    if (!(self = [super init])) {
        return nil;
    }

    _clientId = clientId;
    _items = [[NSMutableArray alloc] init];
    _itemsByIds = [[NSMutableDictionary alloc] init];
    _itemsByLocalIds = [[NSMutableDictionary alloc] init];

    [self appendMessages:messages];
    return self;
}

- (NSNumber *)minMessageId {
    for (IQChannelMessageViewData *data in _items) {
        if (data.message.Id != 0) {
            return @(data.message.Id);
        }
    }
    return nil;
}

- (NSNumber *)maxEventId {
    NSNumber *maxEventId = nil;
    for (IQChannelMessageViewData *data in _items.reverseObjectEnumerator) {
        if (data.message.EventId == nil) {
            continue;
        }
        if (maxEventId == nil) {
            maxEventId = data.message.EventId;
            continue;
        }
        if (maxEventId.longLongValue < data.message.EventId.longLongValue) {
            maxEventId = data.message.EventId;
        }
    }
    return maxEventId;
}

- (void)appendMessages:(NSArray<IQChannelMessage *> *_Nullable)messages {
    if (messages == nil || messages.count == 0) {
        return;
    }

    for (IQChannelMessage *message in messages) {
        [self appendMessage:message];
    }
}

- (void)prependMessages:(NSArray<IQChannelMessage *> *_Nullable)messages {
    if (messages == nil || messages.count == 0) {
        return;
    }

    for (IQChannelMessage *message in messages) {
        [self prependMessage:message];
    }
}

- (void)appendMessage:(IQChannelMessage *_Nonnull)message {
    IQChannelMessageViewData *data = [[IQChannelMessageViewData alloc] initWithMessage:message];
    [_items addObject:data];
    [self updateMessageIndexes:data];
}

- (void)prependMessage:(IQChannelMessage *_Nonnull)message {
    IQChannelMessageViewData *data = [[IQChannelMessageViewData alloc] initWithMessage:message];
    [_items insertObject:data atIndex:0];
    [self updateMessageIndexes:data];
}

- (void)updateMessageIndexes:(IQChannelMessageViewData *)data {
    IQChannelMessage *message = data.message;
    if (message.Id != 0) {
        _itemsByIds[@(message.Id)] = data;
    }
    if ([message.Author isEqualToString:IQChannelAuthorClient]
        && message.ClientId.longLongValue == _clientId
        && message.LocalId != 0) {
        _itemsByLocalIds[@(message.LocalId)] = data;
    }
}

- (void)applyEvent:(IQChannelEvent *_Nonnull)event created:(BOOL *)created updated:(NSUInteger *)updated {
    if (event.MessageId == nil) {
        return;
    }

    NSString *type = event.Type;
    if ([type isEqualToString:IQChannelEventMessageCreated]) {
        IQChannelMessage *message = event.Message;
        if (message == nil) {
            return;
        }

        IQChannelMessageViewData *item = _itemsByIds[@(message.Id)];
        if (item == nil) {
            if ([message.Author isEqualToString:IQChannelAuthorClient]
                && message.ClientId.longLongValue == _clientId
                && message.LocalId != 0) {
                item = _itemsByLocalIds[@(message.LocalId)];
            }
        }

        if (item == nil) {
            [self appendMessage:message];
            *created = YES;
        } else {
            [item applyEvent:event];
            *updated = [_items indexOfObject:item];
        }

        [self updateMessageIndexes:item];
        return;
    }

    IQChannelMessageViewData *item = _itemsByIds[event.MessageId];
    if (item == nil) {
        return;
    }

    [item applyEvent:event];
    *updated = [_items indexOfObject:item];
    [self updateMessageIndexes:item];
}
@end
