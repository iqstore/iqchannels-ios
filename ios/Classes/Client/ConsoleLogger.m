//
//  ConsoleLogger.m
//  IQChannels
//
//  Created by Zhalgas Baibatyr on 09.12.2023.
//

#import "ConsoleLogger.h"

@implementation ConsoleLogger

- (instancetype)init {
    self = [super init];
    if (self) {
        _separatorLine = [@"" stringByPaddingToLength:64 withString:@"☰" startingAtIndex:0];
    }
    return self;
}

- (NSString *)title:(NSString *)token {
    return [NSString stringWithFormat:@"[ NetworkS: HTTP %@ ]", token];
}

- (NSString *)getLogForRequest:(NSURLRequest *)request {
    NSMutableString *log = [NSMutableString string];

    NSURL *url = request.URL;
    NSString *method = request.HTTPMethod;
    if (url && method) {
        NSString *urlString = url.absoluteString;
        if ([urlString hasSuffix:@"?"]) {
            urlString = [urlString substringToIndex:urlString.length - 1];
        }
        [log appendFormat:@"‣ URL: %@\n\n", urlString];
        [log appendFormat:@"‣ METHOD: %@\n\n", method];
    }

    NSDictionary *headerFields = request.allHTTPHeaderFields;
    if (headerFields.count > 0) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:headerFields options:NSJSONWritingPrettyPrinted error:&error];
        if (!error) {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [log appendFormat:@"‣ REQUEST HEADERS: %@\n\n", jsonString];
        }
    }

    NSData *httpBody = request.HTTPBody;
    if (httpBody.length > 0) {
        NSError *error;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:httpBody options:0 error:&error];
        if (!error) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
            if (!error) {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [log appendFormat:@"‣ REQUEST BODY: %@\n\n", jsonString];
            } else {
                [log appendString:@"‣ REQUEST BODY (FAILED TO PRINT)\n\n"];
            }
        }
    }

    return log;
}

- (void)logRequest:(NSURLRequest *)request {
    NSMutableString *log = [NSMutableString string];

    [log appendFormat:@"\n%@\n\n", self.separatorLine];
    [log appendFormat:@"%@\n\n", [self title:@"Request ➡️"]];
    [log appendFormat:@"‣ TIME: %@\n\n", [NSDate date]];
    [log appendString:[self getLogForRequest:request]];
    [log appendFormat:@"%@\n\n", self.separatorLine];

    NSLog(@"%@", log);
}

- (void)logRequest:(NSURLRequest *)request
           response:(NSHTTPURLResponse *)response
      responseData:(NSData *)responseData
             error:(NSError *)error
  responseIsCached:(BOOL)responseIsCached
  responseIsMocked:(BOOL)responseIsMocked {
    NSMutableString *log = [NSMutableString string];

    [log appendFormat:@"\n%@\n\n", self.separatorLine];

    NSString *titlePrefix = responseIsCached ? @"Cached " : (responseIsMocked ? @"Mocked " : @"");
    [log appendFormat:@"%@\n\n", [self title:[titlePrefix stringByAppendingString:@"Response ⬅️"]]];
    [log appendFormat:@"‣ TIME: %@\n\n", [NSDate date]];

    if (response.statusCode != 0) {
        NSString *statusEmoji = (response.statusCode >= 200 && response.statusCode < 300) ? @"✅" : @"⚠️";
        [log appendFormat:@"‣ STATUS CODE: %ld %@\n\n", (long)response.statusCode, statusEmoji];
    }
    [log appendString:[self getLogForRequest:request]];

    NSDictionary *headerFields = response.allHeaderFields;
    if (headerFields.count > 0) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:headerFields options:NSJSONWritingPrettyPrinted error:&error];
        if (!error) {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [log appendFormat:@"‣ RESPONSE HEADERS: %@\n\n", jsonString];
        }
    }

    if (responseData.length > 0) {
        NSError *error;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        if (!error) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
            if (!error) {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [log appendFormat:@"‣ RESPONSE BODY: %@\n\n", jsonString];
            } else {
                [log appendString:@"‣ RESPONSE BODY (FAILED TO PRINT)\n\n"];
            }
        }
    }

    if ([error.domain isEqualToString:@"NetworkError"]) {
        [log appendFormat:@"‣ ERROR: %@\n\n", error.userInfo[@"rawValue"]];
    } else if (error) {
        [log appendFormat:@"‣ ERROR: %@\n\n", error.localizedDescription];
    }

    [log appendFormat:@"%@\n\n", self.separatorLine];

    NSLog(@"%@", log);
}

@end
