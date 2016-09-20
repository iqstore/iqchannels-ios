//
// Created by Ivan Korobkov on 16/09/16.
//

#import <Foundation/Foundation.h>

@class IQClient;
@class IQUser;
@class IQRelations;
@class IQChannelMessage;
@class IQChannelThread;
@class IQChannelEvent;


@interface IQRelationMap : NSObject
@property(nonatomic, nonnull, readonly) NSDictionary<NSNumber *, IQClient *> *Clients;
@property(nonatomic, nonnull, readonly) NSDictionary<NSNumber *, IQUser *> *Users;
- (instancetype _Nonnull)init;
- (instancetype _Nonnull)initWithRelations:(IQRelations *_Nullable)relations;

- (void)fillThread:(IQChannelThread *_Nullable)thread;
- (void)fillThreads:(NSArray<IQChannelThread *> *_Nullable)threads;

- (void)fillMessage:(IQChannelMessage *_Nullable)message;
- (void)fillMessages:(NSArray<IQChannelMessage *> *_Nullable)messages;

- (void)fillEvent:(IQChannelEvent *_Nullable)event;
- (void)fillEvents:(NSArray<IQChannelEvent *> *_Nullable)events;
@end
