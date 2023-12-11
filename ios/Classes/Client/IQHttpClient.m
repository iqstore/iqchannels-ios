//
// Created by Ivan Korobkov on 06/09/16.
//

#import "IQHttpClient.h"
#import "IQResponse.h"
#import "NSError+IQChannels.h"
#import "IQChat.h"
#import "IQRelations.h"
#import "IQChatMessage.h"
#import "IQChatEvent.h"
#import "IQClientInput.h"
#import "IQClientIntegrationAuthRequest.h"
#import "IQLog.h"
#import "IQChatMessageForm.h"
#import "IQMaxIdQuery.h"
#import "IQHttpEventSource.h"
#import "IQClientAuth.h"
#import "IQClientAuthRequest.h"
#import "IQChatEventQuery.h"
#import "IQHttpRequest.h"
#import "IQRelationMap.h"
#import "IQRelationService.h"
#import "IQResult.h"
#import "IQFile.h"
#import "IQFileToken.h"
#import "IQHttpFile.h"
#import "IQClientInput.h"
#import "ConsoleLogger.h"


@implementation IQHttpClient {
    IQLog *_log;
    NSURLSession *_Nonnull _session;
    IQRelationService *_Nonnull _relations;
    NSDictionary<NSString*, NSString*>* _customHeaders;
    ConsoleLogger * _logger;
}

- (id)initWithLog:(IQLog *)log relations:(IQRelationService *)relations address:(NSString *)address {
    if (!(self = [super init])) {
        return nil;
    }

    _log = log;
    _address = address;
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    _relations = relations;
    _logger = [[ConsoleLogger alloc] init];
    return self;
}

- (void)setCustomeHeaders:(NSDictionary<NSString*, NSString*>*)headers {
    _customHeaders = headers;
}

- (IQHttpRequest *)clientsSignup:(NSString *)channel callback:(IQHttpClientSignupCallback)callback {
    NSString *path = @"/clients/signup";
    IQClientInput *input = [[IQClientInput alloc] init];
    input.Channel = channel;
    
    return [self post: path jsonEncodable:input callback:^(IQResult *result, NSError *error) {
        if (error != nil) {
            callback(nil, error);
            return;
        }

        IQClientAuth *auth = [IQClientAuth fromJSONObject:result.Value];
        [_relations clientAuth:auth withMap:result.Relations];
        callback(auth, nil);
    }];
}

- (IQHttpRequest *)clientsAuth:(NSString *)token callback:(IQHttpClientAutCallback)callback {
    NSString *path = @"/clients/auth";
    IQClientAuthRequest *req = [[IQClientAuthRequest alloc] init];
    req.Token = token;

    return [self post:path jsonEncodable:req callback:^(IQResult *result, NSError *error) {
        if (error != nil) {
            callback(nil, error);
            return;
        }

        IQClientAuth *auth = [IQClientAuth fromJSONObject:result.Value];
        [_relations clientAuth:auth withMap:result.Relations];
        callback(auth, nil);
    }];
}

- (IQHttpRequest *)clientsIntegrationAuth:(NSString *)credentials channel:(NSString *)channel callback:(IQHttpClientAutCallback)callback {
    NSString *path = @"/clients/integration_auth";
    IQClientIntegrationAuthRequest *req = [[IQClientIntegrationAuthRequest alloc] init];
    req.Credentials = credentials;
    req.Channel = channel;

    return [self post:path jsonEncodable:req callback:^(IQResult *result, NSError *error) {
        if (error != nil) {
            callback(nil, error);
            return;
        }

        IQClientAuth *auth = [IQClientAuth fromJSONObject:result.Value];
        [_relations clientAuth:auth withMap:result.Relations];
        callback(auth, nil);
    }];
}

- (IQHttpRequest *)chatsChannel:(NSString *)channel chat:(IQHttpChatCallback)callback {
    NSString *path = [NSString stringWithFormat:@"/chats/channel/chat/%@", channel];
    return [self post:path jsonEncodable:nil callback:^(IQResult *result, NSError *error) {
        if (error != nil) {
            callback(nil, error);
            return;
        }

        IQChat *chat = [IQChat fromJSONObject:result.Value];
        [_relations chat:chat withMap:result.Relations];
        callback(chat, nil);
    }];
}

- (IQHttpRequest *)chatsChannel:(NSString *)channel messages:(IQMaxIdQuery *)query callback:(IQHttpMessagesCallback)callback {
    NSString *path = [NSString stringWithFormat:@"/chats/channel/messages/%@", channel];
    return [self post:path jsonEncodable:query callback:^(IQResult *result, NSError *error) {
        if (error != nil) {
            callback(nil, error);
            return;
        }

        NSArray<IQChatMessage *> *messages = [IQChatMessage fromJSONArray:result.Value];
        [_relations chatMessages:messages withMap:result.Relations];
        callback(messages, nil);
    }];
}

- (IQHttpRequest *)chatsChannel:(NSString *)channel typing:(IQHttpVoidCallback)callback {
    NSString *path = [NSString stringWithFormat:@"/chats/channel/typing/%@", channel];
    return [self post:path jsonEncodable:nil callback:^(IQResult *result, NSError *error) {
        callback(error);
    }];
}

- (IQHttpRequest *)chatsChannel:(NSString *)channel send:(IQChatMessageForm *)form callback:(IQHttpVoidCallback)callback {
    NSString *path = [NSString stringWithFormat:@"/chats/channel/send/%@", channel];
    return [self post:path jsonEncodable:form callback:^(IQResult *result, NSError *error) {
        callback(error);
    }];
}

- (IQHttpRequest *)chatsChannel:(NSString *)channel events:(IQChatEventQuery *)query callback:(IQHttpEventsCallback)callback {
    NSString *path = [NSString stringWithFormat:@"/sse/chats/channel/events/%@", channel];
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

    return [self sse:path callback:^(IQResult *result, NSError *error) {
        if (error != nil) {
            callback(nil, error);
            return;
        }
        if (result == nil) {
            // An opened event.
            callback(@[], nil);
            return;
        }

        NSArray<IQChatEvent *> *events = [IQChatEvent fromJSONArray:result.Value];
        [_relations chatEvents:events withMap:result.Relations];
        callback(events, nil);
    }];
}

- (IQHttpRequest *)chatsChannel:(NSString *)channel unread:(IQHttpUnreadCallback)callback {
    NSString *path = [NSString stringWithFormat:@"/sse/chats/channel/unread/%@", channel];
    return [self sse:path callback:^(IQResult *result, NSError *error) {
        if (error != nil) {
            callback(nil, error);
            return;
        }
        if (result == nil) {
            // An opened event.
            return;
        }

        NSNumber *unread = @(0);
        if (result.Value && [result.Value isKindOfClass:NSNumber.class]) {
            unread = (NSNumber *) result.Value;
        }
        callback(unread, nil);
    }];
}

- (IQHttpRequest *)chatsMessagesReceived:(NSArray<NSNumber *> *)messageIds callback:(IQHttpVoidCallback)callback {
    NSString *path = @"/chats/messages/received";
    return [self post:path json:messageIds callback:^(IQResult *response, NSError *error) {
        callback(error);
    }];
}

- (IQHttpRequest *)chatsMessagesRead:(NSArray<NSNumber *> *)messageIds callback:(IQHttpVoidCallback)callback {
    NSString *path = @"/chats/messages/read";
    return [self post:path json:messageIds callback:^(IQResult *response, NSError *error) {
        callback(error);
    }];
}

- (IQHttpRequest *)filesUploadImage:(NSString *)filename data:(NSData *)data callback:(IQHttpFileCallback)callback {
    NSString *path = @"/files/upload";
    NSDictionary *params = @{@"Type": @"image"};
    NSDictionary *files = @{@"File": [[IQHttpFile alloc] initWithName:filename Data:data MimeType:@""]};

    return [self post:path multipart:params files:files callback:^(IQResult *result, NSError *error) {
        if (error != nil) {
            callback(nil, error);
            return;
        }

        IQFile *file0 = [IQFile fromJSONObject:result.Value];
        [_relations file:file0 withMap:result.Relations];
        callback(file0, nil);
    }];
}

- (IQHttpRequest *)filesUploadData:(NSString *)filename data:(NSData *)data callback:(IQHttpFileCallback)callback {
    NSString *path = @"/files/upload";
    NSDictionary *params = @{@"Type": @"file"};
    NSDictionary *files = @{@"File": [[IQHttpFile alloc] initWithName:filename Data:data MimeType:@""]};

    return [self post:path multipart:params files:files callback:^(IQResult *result, NSError *error) {
        if (error != nil) {
            callback(nil, error);
            return;
        }

        IQFile *file0 = [IQFile fromJSONObject:result.Value];
        [_relations file:file0 withMap:result.Relations];
        callback(file0, nil);
    }];
}

- (IQHttpRequest *)filesToken:(NSString *)fileId callback:(IQHttpFileTokenCallback)callback {
    NSString *path = @"/files/token";
    NSDictionary *params = @{@"FileId": fileId};
    
    return [self post:path json:params callback:^(IQResult *result, NSError *error) {
        if (error != nil) {
            callback(nil, error);
            return;
        }

        IQFileToken *token = [IQFileToken fromJSONObject:result.Value];
        callback(token, nil);
    }];
}

- (NSURL *)fileURL:(NSString *)fileId token:(NSString *)token {
    NSString *path = [NSString stringWithFormat:@"/files/get/%@?token=%@", fileId, token];
    return [self requestUrl:path];
}

- (IQHttpRequest *)ratingsRate:(int64_t)ratingId value:(int32_t)value callback:(IQHttpVoidCallback)callback {
    NSString *path = @"/ratings/rate";
    NSDictionary *params = @{@"RatingId": @(ratingId), @"Rating": @{@"Value": @(value)}};
    
    return [self post:path json:params callback:^(IQResult *result, NSError *error) {
        callback(error);
    }];
}

- (IQHttpRequest *)ratingsIgnore:(int64_t)ratingId callback:(IQHttpVoidCallback)callback {
    NSString *path = @"/ratings/ignore";
    NSDictionary *params = @{@"RatingId": @(ratingId)};
    
    return [self post:path json:params callback:^(IQResult *result, NSError *error) {
        callback(error);
    }];
}

- (IQHttpRequest *)pushChannel:(NSString *)channel apnsToken:(NSString *)token callback:(IQHttpVoidCallback)callback {
    NSString *path = [NSString stringWithFormat:@"/push/channel/apns/%@", channel];
    NSDictionary *params = @{@"Token": token};

    return [self post:path json:params callback:^(IQResult *result, NSError *error) {
        callback(error);
    }];
}


#pragma mark POST

- (IQHttpRequest *)post:(NSString *_Nonnull)path
          jsonEncodable:(id <IQJSONEncodable> _Nullable)body
               callback:(void (^)(IQResult *, NSError *))callback {
    id json = nil;
    if (body != nil) {
        json = [body toJSONObject];
    }

    return [self post:path json:json callback:callback];
}

- (IQHttpRequest *)post:(NSString *_Nonnull)path
                   json:(id _Nullable)jsonObject
               callback:(void (^)(IQResult *, NSError *))callback {

    NSError *error = nil;
    NSURLRequest *request = [self request:path json:jsonObject error:&error];
    if (!request) {
        callback(nil, error);
        return [[IQHttpRequest alloc] init];
    }

    return [self post:request callback:callback];
}

- (IQHttpRequest *)post:(NSString *_Nonnull)path
              multipart:(NSDictionary<NSString *, NSString *> *)params
                  files:(NSDictionary<NSString *, IQHttpFile *> *)files
               callback:(void (^)(IQResult *, NSError *))callback {

    NSError *error = nil;
    NSURLRequest *request = [self request:path multipart:params files:files error:&error];
    if (!request) {
        callback(nil, error);
        return [[IQHttpRequest alloc] init];
    }

    return [self post:request callback:callback];
}

- (IQHttpRequest *)post:(NSURLRequest *)request callback:(void (^)(IQResult *, NSError *))callback {
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:
            ^(NSData *data, NSURLResponse *response, NSError *taskError) {
#ifdef DEBUG
                [self->_logger
                    logRequest:request
                    response:(NSHTTPURLResponse *)response
                    responseData:data
                    error:taskError
                    responseIsCached:false
                    responseIsMocked:false
                ];
#endif
                [self handleResponse:request.URL data:data response:response error:taskError callback:callback];
            }];
#ifdef DEBUG
    [_logger logRequest:request];
#endif
    [task resume];
    return [[IQHttpRequest alloc] initWithCancellation:^{
        [task cancel];
    }];
}

#pragma mark Request

- (NSURL *)requestUrl:(NSString *)path {
    NSString *address = _address ? _address : @"";
    if ([address hasSuffix:@"/"]) {
        address = [address substringToIndex:address.length - 1];
    }

    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/public/api/v1%@", address, path]];
}

- (NSURLRequest *)request:(NSString *)path
                     json:(id _Nullable)json
                    error:(NSError **)error {

    NSURL *url = [self requestUrl:path];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    if (_token) {
        NSString *auth = [NSString stringWithFormat:@"Client %@", _token];
        [request addValue:auth forHTTPHeaderField:@"Authorization"];
    }
    
    if (_customHeaders) {
        for (NSString *key in _customHeaders) {
            NSString *value = _customHeaders[key];
            if (!value) {
                continue;
            }
            
            [request addValue:value forHTTPHeaderField:key];
        }
    }
    
    if (!json) {
        return request;
    }

    NSData *body = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:error];
    if (body == nil) {
        return nil;
    }
    request.HTTPBody = body;
    [request addValue:[NSString stringWithFormat:@"%u", body.length] forHTTPHeaderField:@"Content-Length"];
    return request;
}

- (NSURLRequest *)request:(NSString *)path
                multipart:(NSDictionary<NSString *, id> *)params
                    files:(NSDictionary<NSString *, IQHttpFile *> *)files
                    error:(NSError **)error {

    NSURL *url = [self requestUrl:path];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";

    NSString *boundary = [self requestMultipartBoundary];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    if (_customHeaders) {
        for (NSString *key in _customHeaders) {
            NSString *value = _customHeaders[key];
            if (!value) {
                continue;
            }
            
            [request addValue:value forHTTPHeaderField:key];
        }
    }

    NSData *body = [self requestMultipartBodyWithParams:params files:files boundary:boundary];
    request.HTTPBody = body;
    [request addValue:[NSString stringWithFormat:@"%u", body.length] forHTTPHeaderField:@"Content-Length"];
    return request;
}

- (NSString *)requestMultipartBoundary {
    return [NSString stringWithFormat:@"-----------iqchannels-boundary-%@", [[NSUUID UUID] UUIDString]];
}

- (NSData *)requestMultipartBodyWithParams:(NSDictionary<NSString *, NSString *> *)params
                                     files:(NSDictionary<NSString *, IQHttpFile *> *)files
                                  boundary:(NSString *)boundary {
    NSMutableData *body = [[NSMutableData alloc] init];

    for (NSString *key in params) {
        NSString *value = params[key];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key]
                dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", value] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    for (NSString *key in files) {
        IQHttpFile *file = files[key];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:
                @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, file.Name]
                dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", file.MimeType]
                dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:file.Data];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return body;
}

#pragma mark Response

- (void)handleResponse:(NSURL *)url data:(NSData *)data response:(NSURLResponse *)urlResponse
                 error:(NSError *)error
              callback:(void (^)(IQResult *, NSError *))callback {
    if (error != nil) {
        [_log debug:@"POST ERROR %@ error=%@", url.absoluteString, error.localizedDescription];
        callback(nil, error);
        return;
    }

    // Check HTTP status.
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) urlResponse;
    [_log debug:@"POST %d %@", httpResponse.statusCode, url.absoluteString];

    if ((httpResponse.statusCode / 100) != 2) {
        NSString *text = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
        callback(nil, [NSError iq_clientErrorWithLocalizedDescription:text]);
        return;
    }

    // Return when a void response.
    if (data == nil || data.length == 0) {
        IQResult *result = [[IQResult alloc] init];
        callback(result, nil);
        return;
    }

    // Parse IQResponse.
    NSError *jsonError = nil;
    IQResponse *response = [IQResponse fromJSONData:data error:&jsonError];
    if (jsonError != nil) {
        [_log debug:@"POST JSON ERROR %@ error=%@", url.absoluteString, error.localizedDescription];
        callback(nil, error);
        return;
    }

    if (!response.OK) {
        error = [NSError iq_withIQError:response.Error];
        callback(nil, error);
        return;
    }

    IQResult *result = [[IQResult alloc] init];
    result.Value = response.Result;
    result.Relations = [_relations mapFromRelations:response.Rels];
    callback(result, nil);
}

#pragma mark SSE

- (IQHttpRequest *)sse:(NSString *_Nonnull)path callback:(void (^)(IQResult *, NSError *))callback {
    NSURL *url = [self requestUrl:path];
    [_log debug:@"SSE %@", url.absoluteString];

    IQHttpEventSource *eventSource = [[IQHttpEventSource alloc] initWithUrl:url authToken:_token
                                                                   customHeaders:_customHeaders
                                                                   callback:
            ^(NSData *data, NSError *error) {
                if (error != nil) {
                    [_log debug:@"SSE ERROR %@ error=%@", url.absoluteString, error.localizedDescription];
                    callback(nil, error);
                    return;
                }
                if (data == nil) {
                    // Must be an open event.
                    callback(nil, nil);
                    return;
                }

                NSError *jsonError = nil;
                IQResponse *response = [IQResponse fromJSONData:data error:&jsonError];
                if (jsonError != nil) {
                    [_log debug:@"SSE JSON ERROR %@ error=%@", url.absoluteString, error.localizedDescription];
                    [eventSource close];
                    callback(nil, error);
                    return;
                }

                if (!response.OK) {
                    error = [NSError iq_withIQError:response.Error];
                    [eventSource close];
                    callback(nil, error);
                    return;
                }

                IQResult *result = [[IQResult alloc] init];
                result.Value = response.Result;
                result.Relations = [_relations mapFromRelations:response.Rels];
                callback(result, nil);
            }];

    return [[IQHttpRequest alloc] initWithCancellation:^{
        [eventSource close];
    }];
}
@end
