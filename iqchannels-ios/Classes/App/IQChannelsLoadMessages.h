//
// Created by Ivan Korobkov on 10/10/2016.
//

#import <Foundation/Foundation.h>
@class IQChannelMessage;


typedef void (^IQChannelsLoadMessagesCallback)(NSArray<IQChannelMessage *> *_Nullable, NSError *_Nullable);
