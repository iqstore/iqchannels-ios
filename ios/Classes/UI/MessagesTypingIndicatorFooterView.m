//
//  MessagesTypingIndicatorFooterView.m
//  IQChannels
//
//  Created by Zhalgas Baibatyr on 25.08.2023.
//

#import "MessagesTypingIndicatorFooterView.h"

#import "JSQMessagesBubbleImageFactory.h"

#import "UIImage+JSQMessages.h"
#import "UIColor+JSQMessages.h"

const CGFloat kMessagesTypingIndicatorFooterViewHeight = 2 * 6 + 46.0f;


@interface MessagesTypingIndicatorFooterView ()

@property (weak, nonatomic) IBOutlet UIView *avatarContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewRightHorizontalConstraint;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typingIndicatorImageViewRightHorizontalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typingIndicatorToBubbleImageAlignConstraint;

@end

@implementation MessagesTypingIndicatorFooterView

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([MessagesTypingIndicatorFooterView class])
                          bundle:[NSBundle bundleForClass:[MessagesTypingIndicatorFooterView class]]];
}

+ (NSString *)footerReuseIdentifier
{
    return NSStringFromClass([MessagesTypingIndicatorFooterView class]);
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
}

- (void)dealloc
{
    _bubbleImageView = nil;
    _avatarImageView = nil;
}

#pragma mark - Reusable view

- (void)prepareForReuse {
    self.avatarImageView.image = nil;
    self.avatarImageView.highlightedImage = nil;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.bubbleImageView.backgroundColor = backgroundColor;
    self.avatarContainerView.backgroundColor = backgroundColor;
}

#pragma mark - Typing indicator

- (void)configureWithText:(NSString *)text
                textColor:(UIColor *)textColor
       messageBubbleColor:(UIColor *)messageBubbleColor
        forCollectionView:(UICollectionView *)collectionView
{
    NSParameterAssert(text != nil);
    NSParameterAssert(messageBubbleColor != nil);
    NSParameterAssert(collectionView != nil);

    CGFloat bubbleMarginMinimumSpacing = 6.0f;

    JSQMessagesBubbleImageFactory *bubbleImageFactory = [[JSQMessagesBubbleImageFactory alloc] init];

    self.bubbleImageView.image = [bubbleImageFactory incomingMessagesBubbleImageWithColor:messageBubbleColor].messageBubbleImage;

    CGFloat collectionViewWidth = CGRectGetWidth(collectionView.frame);
    CGFloat bubbleWidth = CGRectGetWidth(self.bubbleImageView.frame);
    CGFloat bubbleMarginMaximumSpacing = collectionViewWidth - bubbleWidth - bubbleMarginMinimumSpacing;

    self.bubbleImageViewRightHorizontalConstraint.constant = bubbleMarginMaximumSpacing;
    self.typingIndicatorToBubbleImageAlignConstraint.constant = 0;

    [self setNeedsUpdateConstraints];

    self.label.text = text;
    self.label.textColor = textColor;
}

@end

