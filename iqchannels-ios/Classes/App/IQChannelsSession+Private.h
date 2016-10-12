//
// Created by Ivan Korobkov on 10/10/2016.
//

#import <Foundation/Foundation.h>
#import "IQChannelsSession.h"

@class IQLogger;
@class IQClient;
@class IQClientSession;
@class IQHttpClient;


@protocol IQChannelsSessionListener
- (void)channelsSessionLoggedOut;
@end


@interface IQChannelsSession (Private)
- (IQLogger *_Nonnull)logger;
- (IQNetwork *_Nonnull)network;
- (IQHttpClient *_Nonnull)httpClient;
- (IQChannelsConfig *_Nonnull)config;

- (int64_t)clientId;
- (IQClient *_Nonnull)client;
- (IQClientSession *_Nonnull)session;

- (void)addListener:(id <IQChannelsSessionListener> _Nonnull)listener;
- (void)removeListener:(id <IQChannelsSessionListener> _Nonnull)listener;
@end
