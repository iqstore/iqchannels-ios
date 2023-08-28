//
//  MessagesTypingIndicatorFooterView.h
//  IQChannels
//
//  Created by Zhalgas Baibatyr on 25.08.2023.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  A constant defining the default height of a `MessagesTypingIndicatorFooterView`.
 */
FOUNDATION_EXPORT const CGFloat kMessagesTypingIndicatorFooterViewHeight;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `MessagesTypingIndicatorFooterView` class implements a reusable view that can be placed
 *  at the bottom of a `JSQMessagesCollectionView`. This view represents a typing indicator
 *  for incoming messages.
 */
@interface MessagesTypingIndicatorFooterView : UICollectionReusableView

/**
 *  Returns the avatar image view of the cell that is responsible for displaying avatar images.
 */
@property (weak, nonatomic, readonly, nullable) UIImageView *avatarImageView;

#pragma mark - Class methods

/**
 *  Returns the `UINib` object initialized for the collection reusable view.
 *
 *  @return The initialized `UINib` object.
 */
+ (UINib *)nib;

/**
 *  Returns the default string used to identify the reusable footer view.
 *
 *  @return The string used to identify the reusable footer view.
 */
+ (NSString *)footerReuseIdentifier;

#pragma mark - Typing indicator

/**
 *  Configures the receiver with the specified attributes for the given collection view.
 *  Call this method after dequeuing the footer view.
 *
 *  @param text  Displayed text
 *  @param textColor Color of displayed text
 *  @param messageBubbleColor  The color of the typing indicator message bubble. This value must not be `nil`.
 *  @param animated            Specifies whether the typing indicator should animate.
 *  @param collectionView      The collection view in which the footer view will appear. This value must not be `nil`.
 */
- (void)configureWithText:(NSString *)text
                textColor:(UIColor *)textColor
                messageBubbleColor:(UIColor *)messageBubbleColor
                 forCollectionView:(UICollectionView *)collectionView;
@end

NS_ASSUME_NONNULL_END
