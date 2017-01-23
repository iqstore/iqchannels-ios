//
// Created by Ivan Korobkov on 13/09/16.
//

#import <Foundation/Foundation.h>

@interface NSBundle (IQChannels)
+ (NSBundle *)iq_channelsBundle;
+ (NSString *)iq_channelsLocalizedStringForKey:(NSString *)key value:(NSString *)value;
@end
