//
// Created by Ivan Korobkov on 11/09/16.
//

#import "UIColor+IQChannels.h"


@implementation UIColor (IQChannels)
+ (instancetype)colorWithHex:(NSInteger)hex {
    NSInteger red = (hex & 0xFF0000) >> 16;
    NSInteger green = (hex & 0x00FF00) >> 8;
    NSInteger blue = (hex & 0x0000FF);

    CGFloat rf = (CGFloat) (red / 255.0);
    CGFloat gf = (CGFloat) (green / 255.0);
    CGFloat bf = (CGFloat) (blue / 255.0);

    return [[UIColor alloc] initWithRed:rf green:gf blue:bf alpha:1.0];
}
@end
