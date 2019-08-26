//
// Created by Ivan Korobkov on 16/09/16.
//

#import <Foundation/Foundation.h>

@class IQClient;
@class IQUser;
@class IQRelations;
@class IQChatMessage;
@class IQChat;
@class IQChatEvent;
@class IQChannel;
@class IQFile;
@class IQRating;


@interface IQRelationMap : NSObject
@property(nonatomic, nonnull) NSMutableDictionary<NSNumber *, IQChannel *> *Channels;
@property(nonatomic, nonnull) NSMutableDictionary<NSNumber *, IQChat *> *Chats;
@property(nonatomic, nonnull) NSMutableDictionary<NSNumber *, IQChatMessage *> *ChatMessages;
@property(nonatomic, nonnull) NSMutableDictionary<NSNumber *, IQClient *> *Clients;
@property(nonatomic, nonnull) NSMutableDictionary<NSString *, IQFile *> *Files;
@property(nonatomic, nonnull) NSMutableDictionary<NSNumber *, IQRating *> *Ratings;
@property(nonatomic, nonnull) NSMutableDictionary<NSNumber *, IQUser *> *Users;

- (instancetype _Nonnull)init;
- (instancetype _Nonnull)initWithClient:(IQClient *_Nonnull)client;
- (instancetype _Nonnull)initWithRelations:(IQRelations *_Nullable)relations;
@end
