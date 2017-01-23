//
// Created by Ivan Korobkov on 18/01/2017.
//

#import "IQSubscription.h"


@implementation IQSubscription {
    void (^_unsubscribe)();
}
- (instancetype)init {
    return [self initWithUnsubscribe:^{}];
}

- (instancetype)initWithUnsubscribe:(void (^)())unsubscribe {
    if (!(self = [super init])) {
        return nil;
    }

    _unsubscribe = unsubscribe;
    return self;
}

- (void)unsubscribe {
    _unsubscribe();
}
@end
