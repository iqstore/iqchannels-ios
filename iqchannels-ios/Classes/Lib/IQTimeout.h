//
// Created by Ivan Korobkov on 07/09/16.
//

#import <Foundation/Foundation.h>

@interface IQTimeout : NSObject
+ (NSInteger)secondsWithAttempt:(NSInteger)attempt;
+ (dispatch_time_t)timeWithAttempt:(NSInteger)attempt;
+ (dispatch_time_t)timeWithTimeoutSeconds:(double)seconds;
@end
