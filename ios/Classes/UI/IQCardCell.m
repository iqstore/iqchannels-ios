//
//  IQCardCell.m
//  IQChannels
//
//  Created by Zhalgas Baibatyr on 02.12.2023.
//

#import "IQCardCell.h"
#import <IQChannels/IQAction.h>

@interface IQCardCell()

@property (nonatomic, strong) UIStackView *contentStackView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIView *messageContainerView;
@property (nonatomic, strong) UIStackView *messageStackView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIStackView *buttonsStackView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttonsArray;

@end

@implementation IQCardCell {

    NSMutableArray<IQAction *> *_actions;
    NSLayoutConstraint *_messageContainerViewWidthConstraint;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentStackView = [[UIStackView alloc] init];
        self.timeLabel = [[UILabel alloc] init];
        self.avatarView = [[UIImageView alloc] init];
        self.messageContainerView = [[UIView alloc] init];
        self.messageStackView = [[UIStackView alloc] init];
        self.imageView = [[UIImageView alloc] init];
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        self.textLabel = [[UILabel alloc] init];
        self.buttonsStackView = [[UIStackView alloc] init];

        [self.contentView addSubview: self.contentStackView];
        [self.contentView addSubview: self.timeLabel];

        [self.contentStackView addArrangedSubview: self.avatarView];
        [self.contentStackView addArrangedSubview: self.messageContainerView];

        [self.messageContainerView addSubview: self.messageStackView];
        [self.messageStackView addArrangedSubview: self.textLabel];
        [self.messageStackView addArrangedSubview: self.buttonsStackView];

        [self setLayoutConstraints];
        [self setStyleProperties];

        self.buttonsArray = [@[] mutableCopy];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [_actions removeAllObjects];

    for (UIView *subview in self.buttonsStackView.arrangedSubviews) {
        [self.buttonsStackView removeArrangedSubview:subview];
        [subview removeFromSuperview];
    }

    for (UIView *subview in self.messageStackView.arrangedSubviews) {
        if ([subview isEqual: self.imageView]) {
            [self.messageStackView removeArrangedSubview: subview];
            [subview removeFromSuperview];
            break;
        }
    }

    [self.buttonsArray removeAllObjects];
    _messageContainerViewWidthConstraint.constant = 0;
    self.imageView.image = nil;
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
}

- (void)setLayoutConstraints {
    [self setContentStackViewLayoutConstraints];
    [self setTimeLabelLayoutConstraints];
    [self setMessageStackViewLayoutConstraints];
    [self setAvatarViewLayoutConstraints];
}

- (void)setContentStackViewLayoutConstraints {
    [self.contentStackView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *leading = [
        NSLayoutConstraint
        constraintWithItem: self.contentStackView
        attribute: NSLayoutAttributeLeading
        relatedBy: NSLayoutRelationEqual
        toItem: self.contentView
        attribute: NSLayoutAttributeLeading
        multiplier: 1
        constant: 0
    ];
    NSLayoutConstraint *top = [
        NSLayoutConstraint
        constraintWithItem: self.contentStackView
        attribute: NSLayoutAttributeTop
        relatedBy: NSLayoutRelationEqual
        toItem: self.contentView
        attribute: NSLayoutAttributeTop
        multiplier: 1
        constant: 0
    ];
    NSLayoutConstraint *trailing = [
        NSLayoutConstraint
        constraintWithItem: self.contentStackView
        attribute: NSLayoutAttributeTrailing
        relatedBy: NSLayoutRelationLessThanOrEqual
        toItem: self.contentView
        attribute: NSLayoutAttributeTrailing
        multiplier: 1
        constant: 0
    ];

    [self addConstraints:@[leading, top, trailing]];
}

- (void)setTimeLabelLayoutConstraints {
    [self.timeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *leading = [
        NSLayoutConstraint
        constraintWithItem: self.timeLabel
        attribute: NSLayoutAttributeLeading
        relatedBy: NSLayoutRelationEqual
        toItem: self.messageContainerView
        attribute: NSLayoutAttributeLeading
        multiplier: 1
        constant: 8
    ];
    NSLayoutConstraint *top = [
        NSLayoutConstraint
        constraintWithItem: self.timeLabel
        attribute: NSLayoutAttributeTop
        relatedBy: NSLayoutRelationEqual
        toItem: self.contentStackView
        attribute: NSLayoutAttributeBottom
        multiplier: 1
        constant: 0
    ];
    NSLayoutConstraint *trailing = [
        NSLayoutConstraint
        constraintWithItem: self.timeLabel
        attribute: NSLayoutAttributeTrailing
        relatedBy: NSLayoutRelationLessThanOrEqual
        toItem: self.contentView
        attribute: NSLayoutAttributeTrailing
        multiplier: 1
        constant: 0
    ];
    NSLayoutConstraint *bottom = [
        NSLayoutConstraint
        constraintWithItem: self.timeLabel
        attribute: NSLayoutAttributeBottom
        relatedBy: NSLayoutRelationEqual
        toItem: self.contentView
        attribute: NSLayoutAttributeBottom
        multiplier: 1
        constant: 0
    ];
    NSLayoutConstraint *height = [
        NSLayoutConstraint
        constraintWithItem: self.timeLabel
        attribute: NSLayoutAttributeHeight
        relatedBy: NSLayoutRelationEqual
        toItem: nil
        attribute: NSLayoutAttributeNotAnAttribute
        multiplier: 1
        constant: 24
    ];

    [self addConstraints:@[leading, top, trailing, bottom, height]];
}

- (void)setMessageStackViewLayoutConstraints {
    [self.messageStackView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *leading = [
        NSLayoutConstraint
        constraintWithItem: self.messageStackView
        attribute: NSLayoutAttributeLeading
        relatedBy: NSLayoutRelationEqual
        toItem: self.messageContainerView
        attribute: NSLayoutAttributeLeading
        multiplier: 1
        constant: 16
    ];
    NSLayoutConstraint *top = [
        NSLayoutConstraint
        constraintWithItem: self.messageStackView
        attribute: NSLayoutAttributeTop
        relatedBy: NSLayoutRelationEqual
        toItem: self.messageContainerView
        attribute: NSLayoutAttributeTop
        multiplier: 1
        constant: 16
    ];
    NSLayoutConstraint *trailing = [
        NSLayoutConstraint
        constraintWithItem: self.messageStackView
        attribute: NSLayoutAttributeTrailing
        relatedBy: NSLayoutRelationEqual
        toItem: self.messageContainerView
        attribute: NSLayoutAttributeTrailing
        multiplier: 1
        constant: -16
    ];
    NSLayoutConstraint *bottom = [
        NSLayoutConstraint
        constraintWithItem: self.messageStackView
        attribute: NSLayoutAttributeBottom
        relatedBy: NSLayoutRelationEqual
        toItem: self.messageContainerView
        attribute: NSLayoutAttributeBottom
        multiplier: 1
        constant: -16
    ];
    _messageContainerViewWidthConstraint = [
        NSLayoutConstraint
        constraintWithItem: self.messageContainerView
        attribute: NSLayoutAttributeWidth
        relatedBy: NSLayoutRelationGreaterThanOrEqual
        toItem: nil
        attribute: NSLayoutAttributeNotAnAttribute
        multiplier: 1
        constant: 0
    ];

    [self addConstraints:@[leading, top, trailing, bottom, _messageContainerViewWidthConstraint]];
}

- (void)setAvatarViewLayoutConstraints {
    [self.avatarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *width = [
        NSLayoutConstraint
        constraintWithItem: self.avatarView
        attribute: NSLayoutAttributeWidth
        relatedBy: NSLayoutRelationEqual
        toItem: nil
        attribute: NSLayoutAttributeNotAnAttribute
        multiplier: 1
        constant: 30
    ];
    NSLayoutConstraint *height = [
        NSLayoutConstraint
        constraintWithItem: self.avatarView
        attribute: NSLayoutAttributeHeight
        relatedBy: NSLayoutRelationEqual
        toItem: nil
        attribute: NSLayoutAttributeNotAnAttribute
        multiplier: 1
        constant: 30
    ];

    [self addConstraints:@[width, height]];
}

- (void)setImageViewLayoutConstraints {
    [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *width = [
        NSLayoutConstraint
        constraintWithItem: self.imageView
        attribute: NSLayoutAttributeWidth
        relatedBy: NSLayoutRelationEqual
        toItem: nil
        attribute: NSLayoutAttributeNotAnAttribute
        multiplier: 1
        constant: 210
    ];
    NSLayoutConstraint *height = [
        NSLayoutConstraint
        constraintWithItem: self.imageView
        attribute: NSLayoutAttributeHeight
        relatedBy: NSLayoutRelationEqual
        toItem: nil
        attribute: NSLayoutAttributeNotAnAttribute
        multiplier: 1
        constant: 150
    ];

    [self addConstraints:@[width, height]];
}

- (void)setActivityIndicatorViewLayoutConstraints {
    [self.activityIndicatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *centerX = [
        NSLayoutConstraint
        constraintWithItem: self.activityIndicatorView
        attribute: NSLayoutAttributeCenterX
        relatedBy: NSLayoutRelationEqual
        toItem: self.imageView
        attribute: NSLayoutAttributeCenterX
        multiplier: 1
        constant: 0
    ];
    NSLayoutConstraint *centerY = [
        NSLayoutConstraint
        constraintWithItem: self.activityIndicatorView
        attribute: NSLayoutAttributeCenterY
        relatedBy: NSLayoutRelationEqual
        toItem: self.imageView
        attribute: NSLayoutAttributeCenterY
        multiplier: 1
        constant: 0
    ];

    [self addConstraints:@[centerX, centerY]];
}

- (void)setStyleProperties {
    self.contentStackView.alignment = UIStackViewAlignmentBottom;
    self.contentStackView.spacing = 8;

    self.timeLabel.font = [UIFont systemFontOfSize:11];
    self.timeLabel.textColor = [UIColor lightGrayColor];

    self.messageContainerView.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:234.0/255 alpha:1];
    self.messageContainerView.layer.cornerRadius = 16;

    self.messageStackView.axis = UILayoutConstraintAxisVertical;
    self.messageStackView.alignment = UIStackViewAlignmentFill;

    self.activityIndicatorView.color = [UIColor whiteColor];

    self.imageView.contentMode = UIViewContentModeScaleAspectFit;

    self.textLabel.numberOfLines = 0;
    [self.textLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    self.textLabel.textColor = [UIColor blackColor];

    self.buttonsStackView.axis = UILayoutConstraintAxisVertical;
    self.buttonsStackView.spacing = -1;
}

+ (NSString *)cellReuseIdentifier { return NSStringFromClass([self class]); }

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    [self.activityIndicatorView stopAnimating];
}

- (void)setText:(NSString *)text {
    self.textLabel.text = text;
}

- (void)setTime:(NSString *)time {
    self.timeLabel.text = time;
}

- (void)setActions:(NSMutableArray<IQAction *> *)actions {
    _actions = actions;

    for (IQAction *action in actions) {
        UIButton *button = [self getNewButtonWithTitle: action.Title];
        [self.buttonsStackView addArrangedSubview:button];
        [self.buttonsArray addObject:button];
    }

    [self layoutSubviews];
}

- (void)setMessageBubbleWidth:(CGFloat)width {
    _messageContainerViewWidthConstraint.constant = width;
}

- (void)setAsMedia {
    [self.messageStackView insertArrangedSubview:self.imageView atIndex:0];
    [self.messageContainerView addSubview: self.activityIndicatorView];
    [self setImageViewLayoutConstraints];
    [self setActivityIndicatorViewLayoutConstraints];
    [self.activityIndicatorView startAnimating];
}

- (UIButton *)getNewButtonWithTitle:(NSString*)title {
    UIButton *button = [[UIButton alloc] init];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[[button heightAnchor] constraintEqualToConstant: 32] setActive:YES];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    UIColor *backgroundColor = [UIColor colorWithRed:227.0/255 green:227.0/255 blue:227.0/255 alpha:1];
    button.backgroundColor = backgroundColor;
    button.titleLabel.font = [UIFont systemFontOfSize: 12];
    button.layer.cornerRadius = 4;
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIColor *borderColor = [UIColor colorWithRed:132.0/255 green:132.0/255 blue:132.0/255 alpha:1];
    button.layer.borderColor = borderColor.CGColor;
    button.layer.borderWidth = 1;
    return button;
}

- (void)buttonAction:(UIButton *)button {
    NSUInteger index = [self.buttonsArray indexOfObject: button];
    [self.delegate cardCell:self didSelectOption:_actions[index]];
}

@end
