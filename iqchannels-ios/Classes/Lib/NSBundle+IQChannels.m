//
// Created by Ivan Korobkov on 13/09/16.
//

#import "NSBundle+IQChannels.h"
#import "IQChannels.h"


@implementation NSBundle (IQChannels)
+ (NSBundle *)iq_channelsBundle {
    return [NSBundle bundleForClass:IQChannels.class];
}

+ (NSString *)iq_channelsLocalizedStringForKey:(NSString *)key value:(NSString *)value {
    return NSLocalizedStringWithDefaultValue(key, @"IQChannels", [self iq_channelsBundle], value, nil);
}
@end
