//
//  IQChannelMessagesViewController.h
//  Pods
//
//  Created by Ivan Korobkov on 11/09/16.
//
//

#import <Foundation/Foundation.h>
#import <JSQMessagesViewController/JSQMessages.h>

@class JSQMessagesBubbleImage;

@interface IQChannelMessagesViewController : JSQMessagesViewController
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) JSQMessagesBubbleImage *incomingBubble;
@property (nonatomic) JSQMessagesBubbleImage *outgoingBubble;
@end
