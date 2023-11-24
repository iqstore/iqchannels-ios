//
//  IQSingleChoiceCell.m
//  IQChannels
//
//  Created by Zhalgas Baibatyr on 05.11.2023.
//

#import "IQSingleChoiceCell.h"
#import <IQChannels/IQSingleChoice.h>

@interface IQSingleChoiceCell ()

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UILabel *label;

@end

@implementation IQSingleChoiceCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.containerView = [[UIView alloc] init];
        self.label = [[UILabel alloc] init];
        [self.contentView addSubview: self.containerView];
        [self.containerView addSubview: self.label];
        [self setLayoutConstraints];
        [self setStyleProperties];
    }
    return self;
}

- (void)setLayoutConstraints {
    [self.containerView setTranslatesAutoresizingMaskIntoConstraints: NO];
    NSLayoutConstraint *containerViewLeading = [NSLayoutConstraint
        constraintWithItem: self.containerView
        attribute: NSLayoutAttributeLeading
        relatedBy: NSLayoutRelationEqual
        toItem: self.contentView
        attribute: NSLayoutAttributeLeading
        multiplier: 1
        constant: 2
    ];
    NSLayoutConstraint *containerViewTop = [NSLayoutConstraint
        constraintWithItem: self.containerView
        attribute: NSLayoutAttributeTop
        relatedBy: NSLayoutRelationEqual
        toItem: self.contentView
        attribute: NSLayoutAttributeTop
        multiplier: 1
        constant: 2
    ];
    NSLayoutConstraint *containerViewTrailing = [NSLayoutConstraint
        constraintWithItem: self.containerView
        attribute: NSLayoutAttributeTrailing
        relatedBy: NSLayoutRelationEqual
        toItem: self.contentView
        attribute: NSLayoutAttributeTrailing
        multiplier: 1
        constant: -2
    ];
    NSLayoutConstraint *containerViewBottom = [NSLayoutConstraint
        constraintWithItem: self.containerView
        attribute: NSLayoutAttributeBottom
        relatedBy: NSLayoutRelationEqual
        toItem: self.contentView
        attribute: NSLayoutAttributeBottom
        multiplier: 1
        constant: -2
    ];

    [self.label setTranslatesAutoresizingMaskIntoConstraints: NO];
    NSLayoutConstraint *labelLeading = [NSLayoutConstraint
        constraintWithItem: self.label
        attribute: NSLayoutAttributeLeading
        relatedBy: NSLayoutRelationEqual
        toItem: self.containerView
        attribute: NSLayoutAttributeLeading
        multiplier: 1
        constant: 4
    ];
    NSLayoutConstraint *labelTop = [NSLayoutConstraint
        constraintWithItem: self.label
        attribute: NSLayoutAttributeTop
        relatedBy: NSLayoutRelationEqual
        toItem: self.containerView
        attribute: NSLayoutAttributeTop
        multiplier: 1
        constant: 0
    ];
    NSLayoutConstraint *labelTrailing = [NSLayoutConstraint
        constraintWithItem: self.label
        attribute: NSLayoutAttributeTrailing
        relatedBy: NSLayoutRelationEqual
        toItem: self.containerView
        attribute: NSLayoutAttributeTrailing
        multiplier: 1
        constant: -4
    ];
    NSLayoutConstraint *labelBottom = [NSLayoutConstraint
        constraintWithItem: self.label
        attribute: NSLayoutAttributeBottom
        relatedBy: NSLayoutRelationEqual
        toItem: self.containerView
        attribute: NSLayoutAttributeBottom
        multiplier: 1
        constant: 0
    ];

    [self addConstraints: @[
        containerViewLeading, containerViewTop, containerViewTrailing, containerViewBottom,
        labelLeading, labelTop, labelTrailing, labelBottom
    ]];
}

- (void)setStyleProperties {
    UIColor *color = [UIColor colorWithRed:136 / 255.0 green:186 / 255.0 blue:73 / 255.0 alpha:1];
    self.containerView.layer.cornerRadius = 8;
    self.containerView.layer.borderColor = [color CGColor];
    self.containerView.layer.borderWidth = 1;

    self.label.textColor = color;
    self.label.font = [UIFont systemFontOfSize: 12];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.contentView setTransform: CGAffineTransformMakeScale(-1, 1)];
}

+ (NSString *)cellReuseIdentifier { return NSStringFromClass([self class]); }

- (void)setSingleChoice:(IQSingleChoice *)singleChoice {
    _singleChoice = singleChoice;
    self.label.text = singleChoice.title;
}

@end
