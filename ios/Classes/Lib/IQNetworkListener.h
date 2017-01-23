//
// Created by Ivan Korobkov on 08/10/2016.
//

#import <Foundation/Foundation.h>

@protocol IQNetworkListener <NSObject>
- (void)networkStatusChanged:(IQNetworkStatus)status;
@end
