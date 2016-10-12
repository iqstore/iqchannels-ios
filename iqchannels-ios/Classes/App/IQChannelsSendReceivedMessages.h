//
// Created by Ivan Korobkov on 08/10/2016.
//

#import <Foundation/Foundation.h>
@class IQChannelsSession;


@interface IQChannelsSendReceivedMessages : NSObject
- (instancetype _Nonnull)initWithSession:(IQChannelsSession *_Nonnull)session;
- (void)sendReceivedMessageId:(int64_t)messageId;
@end
