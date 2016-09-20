//
// Created by Ivan Korobkov on 16/09/16.
//

#import "IQRelationMap.h"
#import "IQClient.h"
#import "IQUser.h"
#import "IQRelations.h"
#import "IQChannelMessage.h"
#import "IQChannelThread.h"
#import "IQChannelEvent.h"


@implementation IQRelationMap {
    NSMutableDictionary<NSNumber *, IQClient *> *_Nonnull _Clients;
    NSMutableDictionary<NSNumber *, IQUser *> *_Nonnull _Users;
}

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }

    _Clients = [[NSMutableDictionary alloc] init];
    _Users = [[NSMutableDictionary alloc] init];
    return self;
}

- (instancetype)initWithRelations:(IQRelations *_Nullable)relations {
    if (!(self = [self init])) {
        return nil;
    }

    if (relations.Clients != nil) {
        for (IQClient *client in relations.Clients) {
            _Clients[@(client.Id)] = client;
        }
    }
    if (relations.Users != nil) {
        for (IQUser *user in relations.Users) {
            _Users[@(user.Id)] = user;
        }
    }
    return self;
}

- (void)fillThread:(IQChannelThread *_Nullable)thread {
    if (thread == nil) {
        return;
    }
    [self fillMessages:thread.Messages];
}

- (void)fillThreads:(NSArray<IQChannelThread *> *_Nullable)threads {
    if (threads == nil) {
        return;
    }
    for (IQChannelThread *thread in threads) {
        [self fillThread:thread];
    }
}

- (void)fillMessage:(IQChannelMessage *_Nullable)message {
    if (message == nil) {
        return;
    }

    if (message.ClientId != nil) {
        message.Client = _Clients[message.ClientId];
    }
    if (message.UserId != nil) {
        message.User = _Users[message.UserId];
    }
}

- (void)fillMessages:(NSArray<IQChannelMessage *> *_Nullable)messages {
    if (messages == nil) {
        return;
    }

    for (IQChannelMessage *message in messages) {
        [self fillMessage:message];
    }
}

- (void)fillEvent:(IQChannelEvent *)event {
    if (event == nil) {
        return;
    }

    [self fillThread:event.Thread];
    [self fillMessage:event.Message];
}

- (void)fillEvents:(NSArray<IQChannelEvent *> *_Nullable)events {
    if (events == nil) {
        return;
    }

    for (IQChannelEvent *event in events) {
        [self fillEvent:event];
    }
}
@end
