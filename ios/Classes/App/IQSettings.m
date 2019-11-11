//
//  IQSettings.m
//  IQChannels
//
//  Created by Ivan Korobkov on 11.11.2019.
//

#import "IQSettings.h"

NSString *const anonymousTokenKey = @"iqchannels_anonymous_token";

@implementation IQSettings {
    NSUserDefaults *_defaults;
}

- (instancetype)init {
    self = [super init];
    
    _defaults = [NSUserDefaults standardUserDefaults];
    return self;
}

- (NSString *)loadAnonymousToken {
    return [_defaults stringForKey:anonymousTokenKey];
}

- (void)saveAnonymousToken:(NSString *)token {
    [_defaults setObject:token forKey:anonymousTokenKey];
    [_defaults synchronize];
}

- (void)deleteAnonymousToken {
    [_defaults removeObjectForKey:anonymousTokenKey];
    [_defaults synchronize];
}

@end
