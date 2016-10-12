//
// Created by Ivan Korobkov on 08/10/2016.
//

#import <Foundation/Foundation.h>

@class IQChannelsSession;
@class IQChannelMessage;
@class IQChannelMessageForm;


@interface IQChannelsSendMessages : NSObject
- (instancetype _Nonnull)initWithSession:(IQChannelsSession *_Nonnull)session;
- (NSArray<IQChannelMessageForm *> *_Nonnull)queue;
- (IQChannelMessage *_Nonnull)sendToChannel:(NSString *_Nonnull)channel message:(IQChannelMessageForm *_Nonnull)form;
@end
