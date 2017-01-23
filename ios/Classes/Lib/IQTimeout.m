//
// Created by Ivan Korobkov on 07/09/16.
//

#import "IQTimeout.h"


@implementation IQTimeout
+ (NSInteger)secondsWithAttempt:(NSInteger)attempt {
    if (attempt <= 0) {
        return 0;
    }

    switch (attempt) {
        case 1:
            return 1;
        case 2:
            return 2;
        case 3:
            return 5;
        case 4:
            return 10;
        case 5:
            return 15;
        case 6:
            return 20;
        default:
            return 30;
    }
}

+ (dispatch_time_t)timeWithAttempt:(NSInteger)attempt {
    NSInteger seconds = [self secondsWithAttempt:attempt];
    return [self timeWithTimeoutSeconds:seconds];
}

+ (dispatch_time_t)timeWithTimeoutSeconds:(double)seconds {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t) (seconds * NSEC_PER_SEC));
}
@end
