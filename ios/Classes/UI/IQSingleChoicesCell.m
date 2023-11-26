//
//  IQSingleChoicesCell.m
//  IQChannels
//
//  Created by Zhalgas Baibatyr on 25.11.2023.
//

#import "IQSingleChoicesCell.h"
#import "IQSingleChoicesView.h"
#import <IQChannels/IQSingleChoice.h>

@interface IQSingleChoicesCell()

@property (nonatomic, strong) IQSingleChoicesView *view;

@end

@implementation IQSingleChoicesCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.view = [[IQSingleChoicesView alloc] init];
        [self.contentView addSubview: self.view];
        [self setLayoutConstraints];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.view clearSingleChoices];
    self.view.delegate = nil;
}

- (void)setLayoutConstraints {
    [self.view setTranslatesAutoresizingMaskIntoConstraints: NO];
    NSLayoutConstraint *viewLeading = [NSLayoutConstraint
        constraintWithItem: self.view
        attribute: NSLayoutAttributeLeading
        relatedBy: NSLayoutRelationEqual
        toItem: self.contentView
        attribute: NSLayoutAttributeLeading
        multiplier: 1
        constant: 2
    ];
    NSLayoutConstraint *viewTop = [NSLayoutConstraint
        constraintWithItem: self.view
        attribute: NSLayoutAttributeTop
        relatedBy: NSLayoutRelationEqual
        toItem: self.contentView
        attribute: NSLayoutAttributeTop
        multiplier: 1
        constant: 0
    ];
    NSLayoutConstraint *viewTrailing = [NSLayoutConstraint
        constraintWithItem: self.view
        attribute: NSLayoutAttributeTrailing
        relatedBy: NSLayoutRelationEqual
        toItem: self.contentView
        attribute: NSLayoutAttributeTrailing
        multiplier: 1
        constant: 0
    ];
    NSLayoutConstraint *viewBottom = [NSLayoutConstraint
        constraintWithItem: self.view
        attribute: NSLayoutAttributeBottom
        relatedBy: NSLayoutRelationEqual
        toItem: self.contentView
        attribute: NSLayoutAttributeBottom
        multiplier: 1
        constant: 0
    ];

    [self addConstraints: @[viewLeading, viewTop, viewTrailing, viewBottom]];
}

+ (NSString *)cellReuseIdentifier { return NSStringFromClass([self class]); }

- (void)setSingleChoices:(NSMutableArray<IQSingleChoice *> *)singleChoices {
    [self.view setSingleChoices:singleChoices];
}

- (void)setSingleChoicesDelegate:(id<IQSingleChoicesViewDelegate>)delegate {
    self.view.delegate = delegate;
}

@end
