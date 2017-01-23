//
// Created by Ivan Korobkov on 17/01/2017.
//

#import <Foundation/Foundation.h>
#import "IQChannelsState.h"

@class IQClient;


@protocol IQChannelsStateListener <NSObject>
- (void)iq_loggedOut:(IQChannelsState)state;
- (void)iq_awaitingNetwork:(IQChannelsState)state;
- (void)iq_authenticating:(IQChannelsState)state;
- (void)iq_authenticated:(IQChannelsState)state client:(IQClient *)client;
@end
