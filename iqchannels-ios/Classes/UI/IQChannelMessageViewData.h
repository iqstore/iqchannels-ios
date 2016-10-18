//
// Created by Ivan Korobkov on 11/10/2016.
//

#import <Foundation/Foundation.h>
#import <JSQMessagesViewController/JSQMessageData.h>

@class IQChannelMessage;
@class IQChannelEvent;


@interface IQChannelMessageViewData : NSObject <JSQMessageData>
@property(nonatomic, readonly, nonnull) IQChannelMessage *message;
@property(nonatomic) BOOL showDate;

- (instancetype _Nonnull)initWithMessage:(IQChannelMessage *_Nonnull)message;
- (void)applyEvent:(IQChannelEvent *)event;

+ (NSString *_Nonnull)senderIdWithClientId:(int64_t)clientId;
@end
