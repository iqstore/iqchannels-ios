//
//  IQChatEvent.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"
#import "IQChatEventType.h"
#import "IQActorType.h"


@class IQChat;
@class IQChatMessage;
@class IQRelationMap;
@class IQClient;
@class IQUser;


@interface IQChatEvent : NSObject <IQJSONDecodable>
@property(nonatomic) int64_t Id;
@property(nonatomic, copy, nonnull) IQChatEventType Type;
@property(nonatomic) int64_t ChatId;
@property(nonatomic) BOOL Public;
@property(nonatomic) BOOL Transitive;

@property(nonatomic, copy, nullable) NSNumber *SessionId;
@property(nonatomic, copy, nullable) NSNumber *MessageId;
@property(nonatomic, copy, nullable) NSNumber *MemberId;

@property(nonatomic, copy, nonnull) IQActorType Actor;
@property(nonatomic, copy, nullable) NSNumber *ClientId;
@property(nonatomic, copy, nullable) NSNumber *UserId;
@property(nonatomic) int64_t CreatedAt;
@property(nonatomic, copy, nullable) NSArray<IQChatMessage *> *Messages;

// Relations
@property(nonatomic, nullable) IQClient *Client;
@property(nonatomic, nullable) IQUser *User;
@property(nonatomic, nullable) IQChat *Chat;
@property(nonatomic, nullable) IQChatMessage *Message;

- (instancetype _Nonnull)init;

+ (NSArray<IQChatEvent *> *_Nonnull)fromJSONArray:(id _Nullable)array;
@end
