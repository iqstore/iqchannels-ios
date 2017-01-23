//
// Created by Ivan Korobkov on 20/01/2017.
//

#import "IQFileSize.h"


@implementation IQFileSize
+ (NSString *)unitWithSize:(int64_t)size {

    static NSArray *units = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        units = @[@"байт", @"кб", @"мб", @"гб", @"тб", @"пб"];
    });

    double sizef = size;
    NSUInteger unit = 0;
    while (sizef >= 1024 && unit < (units.count - 1)) {
        unit++;
        sizef = sizef / 1024;
    }

    return [NSString stringWithFormat:@"%.01f %@", sizef, units[unit]];
}
@end
