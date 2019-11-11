//
// Created by Ivan Korobkov on 17/01/2017.
//

#import "IQRelationService.h"
#import "IQChat.h"
#import "IQChatEvent.h"
#import "IQClient.h"
#import "IQFile.h"
#import "IQUser.h"
#import "IQRelationMap.h"
#import "IQChatMessage.h"
#import "IQClientAuth.h"
#import "IQRelations.h"
#import "JSQPhotoMediaItem.h"
#import "IQFileImageSize.h"
#import "IQFileSize.h"


@implementation IQRelationService {
    NSCalendar *_calendar;
}

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }

    _calendar = [NSCalendar currentCalendar];
    return self;
}

// Chats

- (void)map:(IQRelationMap *)map {
    [self chats:map.Chats.allValues withMap:map];
    [self chatMessages:map.ChatMessages.allValues withMap:map];
    [self clients:map.Clients.allValues withMap:map];
    [self files:map.Files.allValues withMap:map];
    [self users:map.Users.allValues withMap:map];
}

- (IQRelationMap *)mapFromRelations:(IQRelations *)relations {
    IQRelationMap *map = [[IQRelationMap alloc] initWithRelations:relations];
    [self map:map];
    return map;
}

- (void)chats:(NSArray<IQChat *> *)chats withMap:(IQRelationMap *)map {
    if (chats == nil) {
        return;
    }

    for (IQChat *chat in chats) {
        [self chat:chat withMap:map];
    }
}

- (void)chat:(IQChat *)chat withMap:(IQRelationMap *)map {
    if (chat == nil) {
        return;
    }

    chat.Client = map.Clients[@(chat.ClientId)];
    chat.Message = map.ChatMessages[chat.MessageId];
    chat.Channel = map.Channels[@(chat.ChannelId)];
}

// Chat messages

- (void)chatMessages:(NSArray<IQChatMessage *> *)messages withMap:(IQRelationMap *)map {
    if (messages == nil) {
        return;
    }

    for (IQChatMessage *message in messages) {
        [self chatMessage:message withMap:map];
    }
}

- (void)chatMessage:(IQChatMessage *)message withMap:(IQRelationMap *)map {
    if (message == nil) {
        return;
    }

    message.Client = map.Clients[message.ClientId];
    message.User = map.Users[message.UserId];
    message.File = map.Files[message.FileId];
    message.Rating = map.Ratings[message.RatingId];

    message.CreatedDate = [[NSDate alloc] initWithTimeIntervalSince1970:((NSTimeInterval) message.CreatedAt) / 1000];
    message.CreatedComponents = [_calendar
            components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
              fromDate:message.CreatedDate];

    // JSQMessageData
    message.senderId = [self chatMessageSenderId:message];
    message.senderDisplayName = [self chatMessageSenderDisplayName:message];
    message.date = message.CreatedDate;
    message.messageHash = [self chatMessageHash:message];
}

- (NSString *)chatMessageSenderId:(IQChatMessage *)message {
    if ([message.Author isEqualToString:IQActorClient]) {
        return [self jsq_clientSenderId:message.ClientId.longLongValue];
    }
    if ([message.Author isEqualToString:IQActorUser]) {
        return [self jsq_userSenderId:message.UserId.longLongValue];
    }
    if ([message.Author isEqualToString:IQActorSystem]) {
        return @"system";
    }
    return @"";
}

- (NSString *)chatMessageSenderDisplayName:(IQChatMessage *)message {
    if ([message.Author isEqualToString:IQActorClient]) {
        if (!message.Client) {
            return @"";
        }
        return message.Client.Name;
    }

    if ([message.Author isEqualToString:IQActorUser]) {
        if (!message.User) {
            return @"";
        }
        return message.User.Name;
    }
    return @"";
}

- (NSUInteger)chatMessageHash:(IQChatMessage *)message {
    NSUInteger hash = 31;
    hash = hash * 31 + ((NSUInteger) (message.Id ^ (message.Id >> 32)));
    hash = hash * 31 + ((NSUInteger) (message.LocalId ^ (message.LocalId >> 32)));
    return hash;
}

// Chat events

- (void)chatEvents:(NSArray<IQChatEvent *> *)events withMap:(IQRelationMap *)map {
    if (events == nil) {
        return;
    }

    for (IQChatEvent *event in events) {
        [self chatEvent:event withMap:map];
    }
}

- (void)chatEvent:(IQChatEvent *)event withMap:(IQRelationMap *)map {
    if (event == nil) {
        return;
    }

    event.Client = map.Clients[event.ClientId];
    event.User = map.Users[event.UserId];
    event.Chat = map.Chats[@(event.ChatId)];
    event.Message = map.ChatMessages[event.MessageId];
}

// Clients

- (void)clients:(NSArray<IQClient *> *)clients withMap:(IQRelationMap *)map {
    if (clients == nil) {
        return;
    }

    for (IQClient *client in clients) {
        [self client:client withMap:map];
    }
}

- (void)client:(IQClient *)client withMap:(IQRelationMap *)map {
    if (client == nil) {
        return;
    }

    client.senderId = [self jsq_clientSenderId:client.Id];
    client.senderDisplayName = client.Name;
}

// Client auth

- (void)clientAuth:(IQClientAuth *)auth withMap:(IQRelationMap *)map {
    if (!auth) {
        return;
    }

    [self client:auth.Client withMap:map];
}

// Files

- (void)files:(NSArray<IQFile *> *)files withMap:(IQRelationMap *)map {
    if (files == nil) {
        return;
    }

    for (IQFile *file in files) {
        [self file:file withMap:map];
    }
}

- (void)file:(IQFile *)file withMap:(IQRelationMap *)map {
    if (file == nil) {
        return;
    }

    file.URL = [self fileUrl:file.Id];
    file.ImagePreviewURL = [self fileImageUrl:file.Id size:IQFileImageSizePreview];
}

- (NSURL *)fileUrl:(NSString *)fileId {
    NSString *address = _address ? _address : @"";
    if ([address hasPrefix:@"/"]) {
        address = [address substringFromIndex:1];
    }
    if ([address hasSuffix:@"/"]) {
        address = [address substringToIndex: [address length] - 1];
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/public/api/v1/files/get/%@", address, fileId]];
}

- (NSURL *)fileImageUrl:(NSString *)fileId size:(IQFileImageSize)size {
    NSString *address = _address ? _address : @"";
    if ([address hasPrefix:@"/"]) {
        address = [address substringFromIndex:1];
    }
    if ([address hasSuffix:@"/"]) {
        address = [address substringToIndex: [address length] - 1];
    }
    return [NSURL URLWithString:
            [NSString stringWithFormat:@"%@/public/api/v1/files/image/%@?size=%@", address, fileId, size]];
}

// Users

- (void)users:(NSArray<IQUser *> *)users withMap:(IQRelationMap *)map {
    if (users == nil) {
        return;
    }

    for (IQUser *user in users) {
        [self user:user withMap:map];
    }
}

- (void)user:(IQUser *)user withMap:(IQRelationMap *)map {
    if (user == nil) {
        return;
    }

    user.senderId = [self jsq_userSenderId:user.Id];
    user.senderDisplayName = user.Name;

    if (user.AvatarId) {
        user.AvatarURL = [self fileImageUrl:user.AvatarId size:IQFileImageSizeAvatar];
    }
}

// JSQ

- (NSString *)jsq_clientSenderId:(int64_t)clientId {
    return [NSString stringWithFormat:@"client-%lli", clientId];
}

- (NSString *)jsq_userSenderId:(int64_t)userId {
    return [NSString stringWithFormat:@"user-%lli", userId];
}
@end
