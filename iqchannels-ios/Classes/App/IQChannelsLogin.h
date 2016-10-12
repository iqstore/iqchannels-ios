//
// Created by Ivan Korobkov on 10/10/2016.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, IQChannelsLoginState) {
    IQChannelsLoginLoggedOut,
    IQChannelsLoginWaitingForNetwork,
    IQChannelsLoginInProgress,
    IQChannelsLoginComplete
};


@protocol IQChannelsLoginListener
- (void)channelsLoginStateChanged:(IQChannelsLoginState)state;
@end
