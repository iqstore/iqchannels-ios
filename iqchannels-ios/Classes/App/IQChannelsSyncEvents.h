//
// Created by Ivan Korobkov on 08/10/2016.
//

#import <Foundation/Foundation.h>

@class IQChannelsSession;
@class IQChannelEvent;


typedef NS_ENUM(NSInteger, IQChannelsSyncEventsState) {
    IQChannelsSyncEventsInitial,
    IQChannelsSyncEventsFailed,
    IQChannelsSyncEventsWaitingForNetwork,
    IQChannelsSyncEventsConnecting,
    IQChannelsSyncEventsInProgress,
    IQChannelsSyncEventsClosed
};

typedef void (^IQChannelsSyncEventsCallback)(IQChannelsSyncEventsState, NSArray<IQChannelEvent *> *_Nullable, NSError *_Nullable);

@interface IQChannelsSyncEvents : NSObject
- (instancetype _Nonnull)initWithSession:(IQChannelsSession *_Nonnull)session
                                channel:(NSString *_Nonnull)channelName
                            lastEventId:(NSNumber *_Nullable)lastEventId
                               callback:(IQChannelsSyncEventsCallback _Nonnull)callback;
- (void)syncEvents;
- (void)close;
@end
