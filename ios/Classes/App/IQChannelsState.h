//
// Created by Ivan Korobkov on 17/01/2017.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, IQChannelsState) {
    IQChannelsStateLoggedOut,
    IQChannelsStateAwaitingNetwork,
    IQChannelsStateAuthenticating,
    IQChannelsStateAuthenticated
};
