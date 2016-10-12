//
// Created by Ivan Korobkov on 08/10/2016.
//

#import <Foundation/Foundation.h>

@class IQChannelsSession;


typedef NS_ENUM(NSInteger, IQChannelsSyncUnreadState) {
    IQChannelsSyncUnreadFailed,
    IQChannelsSyncUnreadWaitingForNetwork,
    IQChannelsSyncUnreadConnecting,
    IQChannelsSyncUnreadInProgress
};

typedef void (^IQChannelsSyncUnreadCallback)(IQChannelsSyncUnreadState, NSNumber *_Nullable, NSError *_Nullable);

@interface IQChannelsSyncUnread : NSObject
- (instancetype _Nonnull)initWithSession:(IQChannelsSession *_Nonnull)session
                                channel:(NSString *_Nonnull)channelName
                               callback:(IQChannelsSyncUnreadCallback _Nonnull)callback;
- (void)syncUnread;
- (void)close;
@end
