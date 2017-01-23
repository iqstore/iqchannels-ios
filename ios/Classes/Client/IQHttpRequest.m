//
// Created by Ivan Korobkov on 18/01/2017.
//

#import "IQHttpRequest.h"


@implementation IQHttpRequest {
    void (^_cancellation)();
}
- (instancetype)init {
    return [self initWithCancellation:^{
    }];
}

- (instancetype)initWithCancellation:(void (^)())cancellation {
    if (!(self = [super init])) {
        return nil;
    }

    _cancellation = cancellation;
    return self;
}

- (void)cancel {
    _cancellation();
}
@end
