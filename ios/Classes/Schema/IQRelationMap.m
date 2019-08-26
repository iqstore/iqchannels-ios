//
// Created by Ivan Korobkov on 16/09/16.
//

#import "IQRelationMap.h"
#import "IQClient.h"
#import "IQUser.h"
#import "IQRelations.h"
#import "IQChatMessage.h"
#import "IQChat.h"
#import "IQChatEvent.h"
#import "IQChannel.h"
#import "IQFile.h"
#import "IQRating.h"


@implementation IQRelationMap
- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }

    _Channels = [[NSMutableDictionary alloc] init];
    _Chats = [[NSMutableDictionary alloc] init];
    _ChatMessages = [[NSMutableDictionary alloc] init];
    _Clients = [[NSMutableDictionary alloc] init];
    _Files = [[NSMutableDictionary alloc] init];
    _Ratings = [[NSMutableDictionary alloc] init];
    _Users = [[NSMutableDictionary alloc] init];
    return self;
}

- (instancetype)initWithClient:(IQClient *)client {
    if (!(self = [self init])) {
        return nil;
    }

    _Clients[@(client.Id)] = client;
    return self;
}

- (instancetype)initWithRelations:(IQRelations *_Nullable)relations {
    if (!(self = [self init])) {
        return nil;
    }

    if (relations.Channels != nil) {
        for (IQChannel *channel in relations.Channels) {
            _Channels[@(channel.Id)] = channel;
        }
    }

    if (relations.Chats != nil) {
        for (IQChat *chat in relations.Chats) {
            _Chats[@(chat.Id)] = chat;
        }
    }
    if (relations.ChatMessages != nil) {
        for (IQChatMessage *message in relations.ChatMessages) {
            _ChatMessages[@(message.Id)] = message;
        }
    }

    if (relations.Clients != nil) {
        for (IQClient *client in relations.Clients) {
            _Clients[@(client.Id)] = client;
        }
    }
    if (relations.Files != nil) {
        for (IQFile *file in relations.Files) {
            _Files[file.Id] = file;
        }
    }
    if (relations.Ratings != nil) {
        for (IQRating *rating in relations.Ratings) {
            _Ratings[@(rating.Id)] = rating;
        }
    }
    if (relations.Users != nil) {
        for (IQUser *user in relations.Users) {
            _Users[@(user.Id)] = user;
        }
    }
    return self;
}
@end
