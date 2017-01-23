//
// Created by Ivan Korobkov on 17/01/2017.
//

#import <Foundation/Foundation.h>

@class IQRelationMap;
@class IQChat;
@class IQChatEvent;
@class IQChatMessage;
@class IQClient;
@class IQFile;
@class IQUser;
@class IQClientAuth;
@class IQRelations;


@interface IQRelationService : NSObject
@property(nonatomic, copy) NSString *address;
- (instancetype)init;

- (void)map:(IQRelationMap *)map;
- (IQRelationMap *)mapFromRelations:(IQRelations *)relations;

- (void)chats:(NSArray<IQChat *> *)chats withMap:(IQRelationMap *)map;
- (void)chat:(IQChat *)chat withMap:(IQRelationMap *)map;

- (void)chatMessages:(NSArray<IQChatMessage *> *)messages withMap:(IQRelationMap *)map;
- (void)chatMessage:(IQChatMessage *)message withMap:(IQRelationMap *)map;

- (void)chatEvents:(NSArray<IQChatEvent *> *)events withMap:(IQRelationMap *)map;
- (void)chatEvent:(IQChatEvent *)event withMap:(IQRelationMap *)map;

- (void)clients:(NSArray<IQClient *> *)clients withMap:(IQRelationMap *)map;
- (void)client:(IQClient *)client withMap:(IQRelationMap *)map;
- (void)clientAuth:(IQClientAuth *)auth withMap:(IQRelationMap *)map;

- (void)files:(NSArray<IQFile *> *)files withMap:(IQRelationMap *)map;
- (void)file:(IQFile *)file withMap:(IQRelationMap *)map;

- (void)users:(NSArray<IQUser *> *)users withMap:(IQRelationMap *)map;
- (void)user:(IQUser *)user withMap:(IQRelationMap *)map;
@end
