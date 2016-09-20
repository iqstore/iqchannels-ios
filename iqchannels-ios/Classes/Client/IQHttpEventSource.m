//
// Created by Ivan Korobkov on 11/09/16.
//

#import "IQHttpEventSource.h"
#import "TRVSEventSource.h"
#import "NSError+IQChannels.h"


@interface IQHttpEventSource () <TRVSEventSourceDelegate>
@end


@implementation IQHttpEventSource {
    IQHttpEventSourceCallback _callback;
    TRVSEventSource *_eventSource;
}

- (instancetype)initWithUrl:(NSURL *)url authToken:(NSString *)authToken
                   callback:(IQHttpEventSourceCallback)callback {
    if (!(self = [super init])) {
        return nil;
    }

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    config.HTTPAdditionalHeaders = @{
        @"Authorization": [NSString stringWithFormat:@"Client %@", authToken]
    };

    _callback = callback;
    _eventSource = [[TRVSEventSource alloc] initWithURL:url sessionConfiguration:config];
    _eventSource.delegate = self;
    [_eventSource open];
    return self;
}

- (void)close {
    [_eventSource close];
}

- (void)eventSourceDidOpen:(TRVSEventSource *)eventSource {
    _callback(nil, nil);
}

- (void)eventSource:(TRVSEventSource *)eventSource didReceiveEvent:(TRVSServerSentEvent *)event {
    _callback(event.data, nil);
}

- (void)eventSource:(TRVSEventSource *)eventSource didFailWithError:(NSError *)error {
    if (error == nil) {
        error = [NSError iq_clientErrorWithLocalizedDescription:
            NSLocalizedString(@"Unknown event stream error", nil)];
    }

    _callback(nil, error);
}
@end
