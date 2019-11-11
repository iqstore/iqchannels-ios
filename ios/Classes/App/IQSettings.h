//
//  IQSettings.h
//  IQChannels
//
//  Created by Ivan Korobkov on 11.11.2019.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IQSettings : NSObject
- (instancetype)init;

- (NSString *)loadAnonymousToken;
- (void)saveAnonymousToken:(NSString *)token;
- (void)deleteAnonymousToken;
@end

NS_ASSUME_NONNULL_END
