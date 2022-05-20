//
// Created by Ivan Korobkov on 11/09/16.
//

#import <Foundation/Foundation.h>


typedef void (^IQHttpEventSourceCallback)(NSData *, NSError *);


@interface IQHttpEventSource : NSObject
- (instancetype)initWithUrl:(NSURL *)url authToken:(NSString *)authToken
              customHeaders:(NSDictionary<NSString*, NSString*>*)customHeaders
                   callback:(IQHttpEventSourceCallback)callback;
- (void)close;
@end
