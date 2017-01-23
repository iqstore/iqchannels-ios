//
// Created by Ivan Korobkov on 18/01/2017.
//

#import <Foundation/Foundation.h>


@interface IQSubscription : NSObject
- (instancetype)init;
- (instancetype)initWithUnsubscribe:(void (^)())unsubscribe;
- (void)unsubscribe;
@end
