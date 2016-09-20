//
//  IQChannelEvent.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQSchemaConsts.h"
#import "IQJSONDecodable.h"


@class IQChannelThread;
@class IQChannelMessage;
@class IQRelationMap;


@interface IQChannelEvent : NSObject <IQJSONDecodable, NSCopying>
@property(nonatomic) int64_t Id;
@property(nonatomic, copy, nullable) IQChannelEventType Type;
@property(nonatomic, copy, nullable) NSNumber *ClientId;
@property(nonatomic, copy, nullable) NSNumber *UserId;
@property(nonatomic) int64_t ChannelId;
@property(nonatomic) int64_t ThreadId;
@property(nonatomic, copy, nullable) NSNumber *MessageId;
@property(nonatomic) int64_t CreatedAt;

// Transitive
@property(nonatomic, nullable) IQChannelThread *Thread;  // Present in thread_created.
@property(nonatomic, nullable) IQChannelMessage *Message;  // Present in event_created.

+ (NSArray<IQChannelEvent *> *_Nonnull)fromJSONArray:(id _Nullable)array;
@end