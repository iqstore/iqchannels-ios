//
//  ConsoleLogger.h
//  Pods
//
//  Created by Zhalgas Baibatyr on 09.12.2023.
//

#import <Foundation/Foundation.h>

@interface ConsoleLogger : NSObject

@property (nonatomic, strong, readonly) NSString *separatorLine;

- (instancetype)init;

- (void)logRequest:(NSURLRequest *)request;

- (void)logRequest:(NSURLRequest *)request
           response:(NSHTTPURLResponse *)response
       responseData:(NSData *)responseData
              error:(NSError *)error
   responseIsCached:(BOOL)responseIsCached
  responseIsMocked:(BOOL)responseIsMocked;

@end
