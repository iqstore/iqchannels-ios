//
//  RightAlignedCollectionViewFlowLayout.m
//  IQChannels
//
//  Created by Zhalgas Baibatyr on 05.11.2023.
//

#import "RightAlignedCollectionViewFlowLayout.h"

@interface RightAlignedCollectionViewFlowLayout ()

@end

@implementation RightAlignedCollectionViewFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.minimumLineSpacing = 0;
        self.minimumInteritemSpacing = 0;
    }
    return self;
}

- (BOOL)flipsHorizontallyInOppositeLayoutDirection {
    return YES;
}

- (UIUserInterfaceLayoutDirection)developmentLayoutDirection {
    return UIUserInterfaceLayoutDirectionRightToLeft;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];

    CGFloat leftMargin = self.sectionInset.left;
    CGFloat maxY = -1.0f;

    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        if (attribute.frame.origin.y >= maxY) {
            leftMargin = self.sectionInset.left;
        }

        attribute.frame = CGRectMake(
            leftMargin,
            attribute.frame.origin.y,
            attribute.frame.size.width,
            attribute.frame.size.height
        );

        leftMargin += attribute.frame.size.width + self.minimumInteritemSpacing;
        maxY = MAX(CGRectGetMaxY(attribute.frame), maxY);
    }

    return attributes;
}

@end
