//
// Created by Ivan Korobkov on 18/01/2017.
//

#import <Foundation/Foundation.h>

@protocol IQChannelsMoreMessagesListener <NSObject>
- (void)iq_moreMessagesLoaded;
- (void)iq_moreMessagesError:(NSError *)error;
@end
