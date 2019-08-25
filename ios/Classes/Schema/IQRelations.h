//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"

@class IQClient;
@class IQUser;
@class IQRelationMap;
@class IQChannel;
@class IQChat;
@class IQChatMessage;
@class IQFile;
@class IQRating;


@interface IQRelations : NSObject <IQJSONDecodable>
@property(nonatomic, nullable) NSArray<IQChannel *> *Channels;
@property(nonatomic, nullable) NSArray<IQChat *> *Chats;
@property(nonatomic, nullable) NSArray<IQChatMessage *> *ChatMessages;
@property(nonatomic, nullable) NSArray<IQClient *> *Clients;
@property(nonatomic, nullable) NSArray<IQFile *> *Files;
@property(nonatomic, nullable) NSArray<IQRating *> *Ratings;
@property(nonatomic, nullable) NSArray<IQUser *> *Users;
@end
