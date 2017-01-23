//
// Created by Ivan Korobkov on 17/01/2017.
//

#import <Foundation/Foundation.h>


@protocol IQChannelsUnreadListener <NSObject>
- (void)iq_unreadChanged:(NSInteger)unread;
@end
