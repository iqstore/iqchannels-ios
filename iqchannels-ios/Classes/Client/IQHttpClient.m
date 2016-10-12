//
// Created by Ivan Korobkov on 06/09/16.
//

#import "IQHttpClient.h"
#import "IQResponse.h"
#import "NSError+IQChannels.h"
#import "IQLogging.h"
#import "IQChannelThread.h"
#import "IQRelations.h"
#import "IQChannelMessage.h"
#import "IQChannelEvent.h"
#import "IQClientSession.h"
#import "IQClientIntegrationAuthRequest.h"
#import "IQLogger.h"
#import "IQChannelThreadQuery.h"
#import "IQChannelMessageForm.h"
#import "IQChannelMessagesQuery.h"
#import "IQHttpEventSource.h"
#import "IQClientAuth.h"
#import "IQClientAuthRequest.h"
#import "IQChannelEventsQuery.h"


@implementation IQHttpClient {
    IQLogger *_logger;
    NSURLSession *_Nonnull _session;
}

- (instancetype)initWithLogging:(IQLogging *)logging address:(NSString *)address {
    return [self initWithLogging:logging address:address token:nil];
}

- (instancetype)initWithLogging:(IQLogging *)logging address:(NSString *)address token:(NSString *)token {
    if (!(self = [super init])) {
        return nil;
    }

    _logger = [logging loggerWithName:@"iqchannels.client"];
    _address = address;
    _token = token;
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    return self;
}

- (IQCancel)clientAuth:(NSString *)token callback:(IQHttpClientAutCallback)callback {
    NSString *path = @"/clients/auth";
    IQClientAuthRequest *req = [[IQClientAuthRequest alloc] init];
    req.Token = token;

    return [self post:path body:req callback:^(IQResponse *response, NSError *error) {
        if (error != nil) {
            callback(nil, nil, error);
            return;
        }

        IQClientAuth *auth = [IQClientAuth fromJSONObject:response.Result];
        callback(auth, response.Rels, nil);
    }];
}

- (IQCancel)clientIntegrationAuth:(NSString *)credentials callback:(IQHttpClientAutCallback)callback {
    NSString *path = @"/clients/integration_auth";
    IQClientIntegrationAuthRequest *req = [[IQClientIntegrationAuthRequest alloc] init];
    req.Credentials = credentials;

    return [self post:path body:req callback:^(IQResponse *response, NSError *error) {
        if (error != nil) {
            callback(nil, nil, error);
            return;
        }

        IQClientAuth *auth = [IQClientAuth fromJSONObject:response.Result];
        callback(auth, response.Rels, nil);
    }];
}

- (IQCancel)channel:(NSString *)channel thread:(IQChannelThreadQuery *)query callback:(IQHttpThreadCallback)callback {
    NSString *path = [NSString stringWithFormat:@"/channels/thread/%@", channel];
    return [self post:path body:query callback:^(IQResponse *response, NSError *error) {
        if (error != nil) {
            callback(nil, nil, error);
            return;
        }

        IQChannelThread *thread = [IQChannelThread fromJSONObject:response.Result];
        callback(thread, response.Rels, nil);
    }];
}

- (IQCancel)channel:(NSString *)channel typingCallback:(IQHttpVoidCallback)callback {
    NSString *path = [NSString stringWithFormat:@"/channels/typing/%@", channel];
    return [self post:path body:nil callback:^(IQResponse *response, NSError *error) {
        callback(error);
    }];
}

- (IQCancel)channel:(NSString *)channel sendForm:(IQChannelMessageForm *)form callback:(IQHttpVoidCallback)callback {
    NSString *path = [NSString stringWithFormat:@"/channels/send/%@", channel];
    return [self post:path body:form callback:^(IQResponse *response, NSError *error) {
        callback(error);
    }];
}

- (IQCancel)receivedMessages:(NSArray<NSNumber *> *)messageIds callback:(IQHttpVoidCallback)callback {
    NSString *path = @"/channels/received";
    return [self post:path jsonObject:messageIds callback:^(IQResponse *response, NSError *error) {
        callback(error);
    }];
}

- (IQCancel)readMessages:(NSArray<NSNumber *> *)messageIds callback:(IQHttpVoidCallback)callback {
    NSString *path = @"/channels/read";
    return [self post:path jsonObject:messageIds callback:^(IQResponse *response, NSError *error) {
        callback(error);
    }];
}

- (IQCancel)channel:(NSString *)channel messages:(IQChannelMessagesQuery *)query callback:(IQHttpMessagesCallback)callback {
    NSString *path = [NSString stringWithFormat:@"/channels/messages/%@", channel];
    return [self post:path body:query callback:^(IQResponse *response, NSError *error) {
        if (error != nil) {
            callback(nil, nil, error);
            return;
        }

        NSArray<IQChannelMessage *> *messages = [IQChannelMessage fromJSONArray:response.Result];
        callback(messages, response.Rels, nil);
    }];
}

- (IQCancel)channel:(NSString *)channel listen:(IQChannelEventsQuery *)query callback:(IQHttpEventsCallback)callback {
    NSString *path = [NSString stringWithFormat:@"/sse/channels/events/%@", channel];
    if (query.LastEventId != nil) {
        path = [NSString stringWithFormat:@"%@?LastEventId=%lli", path, query.LastEventId.longLongValue];
    }
    if (query.Limit != nil) {
        if ([path containsString:@"?"]) {
            path = [NSString stringWithFormat:@"%@&", path];
        } else {
            path = [NSString stringWithFormat:@"%@?", path];
        }
        path = [NSString stringWithFormat:@"%@Limit=%i", path, query.Limit.integerValue];
    }

    return [self sse:path callback:^(IQResponse *response, NSError *error) {
        if (error != nil) {
            callback(nil, nil, error);
            return;
        }
        if (response == nil) {
            // An opened event.
            callback(@[], [[IQRelations alloc] init], nil);
            return;
        }

        NSArray<IQChannelEvent *> *events = [IQChannelEvent fromJSONArray:response.Result];
        callback(events, response.Rels, nil);
    }];
}

- (IQCancel)channel:(NSString *)channel unreadWithCallback:(IQHttpUnreadCallback)callback {
    NSString *path = [NSString stringWithFormat:@"/sse/channels/unread/%@", channel];
    return [self sse:path callback:^(IQResponse *response, NSError *error) {
        if (error != nil) {
            callback(nil, error);
            return;
        }
        if (response == nil) {
            // An opened event.
            return;
        }

        NSNumber *unread = @(0);
        if (response.Result && [response.Result isKindOfClass:NSNumber.class]) {
            unread = (NSNumber *) response.Result;
        }
        callback(unread, nil);
    }];
}


#pragma mark POST

- (IQCancel)post:(NSString *_Nonnull)path body:(id <IQJSONEncodable> _Nullable)body
        callback:(void (^)(IQResponse *, NSError *))callback {
    id jsonObject = nil;
    if (body != nil) {
        jsonObject = [body toJSONObject];
    }

    return [self post:path jsonObject:jsonObject callback:callback];
}

- (IQCancel)post:(NSString *_Nonnull)path jsonObject:(id _Nullable)jsonObject
        callback:(void (^)(IQResponse *, NSError *))callback {
    NSError *error = nil;
    NSURLRequest *request = [self request:path jsonObject:jsonObject error:&error];
    if (request == nil) {
        callback(nil, error);
        return ^{};
    }

    NSURL *url = request.URL;
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *taskError) {
            [self handleResponse:url data:data response:response error:taskError callback:callback];
        }];
    [task resume];

    return ^{
        [task cancel];
    };
}

- (NSURLRequest *)request:(NSString *_Nonnull)path jsonObject:(id _Nullable)jsonObject
                    error:(NSError **)error {

    NSURL *url = [self requestUrl:path];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    if (_token) {
        NSString *auth = [NSString stringWithFormat:@"Client %@", _token];
        [request addValue:auth forHTTPHeaderField:@"Authorization"];
    }

    if (jsonObject != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObject
            options:NSJSONWritingPrettyPrinted error:error];
        if (data == nil) {
            return nil;
        }

        request.HTTPBody = data;
        [request addValue:[NSString stringWithFormat:@"%u", data.length]
            forHTTPHeaderField:@"Content-Length"];
    }

    return request;
}

- (NSURL *)requestUrl:(NSString *)path {
    NSString *address = _address ? _address : @"";
    if ([address hasPrefix:@"/"]) {
        address = [address substringFromIndex:1];
    }

    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/public%@", address, path]];
}

- (void)handleResponse:(NSURL *)url data:(NSData *)data response:(NSURLResponse *)urlResponse
                 error:(NSError *)error
              callback:(void (^)(IQResponse *, NSError *))callback {
    if (error != nil) {
        [_logger info:@"POST ERROR %@ error=%@", url.absoluteString, error];
        callback(nil, error);
        return;
    }

    // Check HTTP status.
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) urlResponse;
    [_logger info:@"POST %d %@", httpResponse.statusCode, url.absoluteString];

    if ((httpResponse.statusCode / 100) != 2) {
        NSString *text = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
        callback(nil, [NSError iq_clientErrorWithLocalizedDescription:text]);
        return;
    }

    // Return when a void response.
    if (data == nil || data.length == 0) {
        IQResponse *response = [[IQResponse alloc] init];
        response.OK = true;
        response.Rels = [[IQRelations alloc] init];
        callback(response, nil);
        return;
    }

    // Parse IQResponse.
    NSError *jsonError = nil;
    IQResponse *response = [IQResponse fromJSONData:data error:&jsonError];
    if (jsonError != nil) {
        [_logger error:@"POST JSON ERROR %@ error=%@", url.absoluteString, error];
        callback(nil, error);
        return;
    }

    if (!response.OK) {
        error = [NSError iq_withIQError:response.Error];
        callback(nil, error);
    }
    callback(response, nil);
}

#pragma mark SSE

- (IQCancel)sse:(NSString *_Nonnull)path callback:(void (^)(IQResponse *, NSError *))callback {
    NSURL *url = [self requestUrl:path];
    [_logger info:@"SSE %@", url.absoluteString];

    IQHttpEventSource *eventSource = [[IQHttpEventSource alloc]
        initWithUrl:url authToken:_token
        callback:^(NSData *data, NSError *error) {
            if (error != nil) {
                [_logger error:@"SSE ERROR %@ error=%@", url.absoluteString, error];
                callback(nil, error);
                return;
            }
            if (data == nil) {
                // Must be an opened event.
                callback(nil, nil);
                return;
            }

            NSError *jsonError = nil;
            IQResponse *response = [IQResponse fromJSONData:data error:&jsonError];
            if (jsonError != nil) {
                [_logger error:@"SSE JSON ERROR %@ error=%@", url.absoluteString, error];
                [eventSource close];
                callback(nil, error);
                return;
            }

            callback(response, nil);
        }];
    return ^{
        [eventSource close];
    };
}
@end
