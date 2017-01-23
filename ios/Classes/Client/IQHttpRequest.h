//
// Created by Ivan Korobkov on 18/01/2017.
//

#import <Foundation/Foundation.h>


@interface IQHttpRequest : NSObject
- (instancetype)init;
- (instancetype)initWithCancellation:(void (^)())cancellation;
- (void)cancel;
@end
