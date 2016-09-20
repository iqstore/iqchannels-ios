//
// Created by Ivan Korobkov on 14/09/16.
//

#import <Foundation/Foundation.h>

@class IQChannelEvent;
@class IQChannelMessage;
@class IQChannelThread;


typedef void (^IQChannelThreadCallback)(IQChannelThread *_Nullable, NSError *_Nullable);
typedef void (^IQChannelMessagesCallback)(NSArray<IQChannelMessage *> *_Nullable, NSError *_Nullable);
typedef void (^IQChannelListenCallback)(NSArray<IQChannelEvent *> *_Nonnull);
