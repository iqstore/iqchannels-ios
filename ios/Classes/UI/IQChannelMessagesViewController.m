//
//  IQChannelMessagesViewController.m
//  Pods
//
//  Created by Ivan Korobkov on 11/09/16.
//
//

#import <Photos/Photos.h>
#import "IQChannelMessagesViewController.h"
#import "IQChannels.h"
#import "IQClientSession.h"
#import "IQChatMessageForm.h"
#import "IQChatMessage.h"
#import "UIColor+IQChannels.h"
#import "IQActivityIndicator.h"
#import "SDK.h"
#import "IQSubscription.h"
#import "IQImagePreviewController.h"
#import "IQImagePreviewViewController.h"
#import "SDWebImageManager.h"
#import "MessagesTypingIndicatorFooterView.h"
#import "IQSingleChoicesView.h"
#import "IQStackedSingleChoicesCell.h"
#import "IQSingleChoicesCell.h"
#import "IQCardCell.h"


@interface IQChannelMessagesViewController () <
    IQChannelsStateListener,
    IQChannelsMessagesListener,
    IQChannelsMoreMessagesListener,
    UIActionSheetDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UIGestureRecognizerDelegate,
    UIDocumentPickerDelegate,
    IQSingleChoicesViewDelegate,
    IQStackedSingleChoicesCellDelegate,
    IQCardCellDelegate
>
@property(nonatomic) UIRefreshControl *refreshControl;
@property(nonatomic) IQActivityIndicator *loginIndicator;
@property(nonatomic) IQActivityIndicator *messagesIndicator;
@property(nonatomic) JSQMessagesBubbleImage *incomingBubble;
@property(nonatomic) JSQMessagesBubbleImage *outgoingBubble;
@end


@implementation IQChannelMessagesViewController {
    IQClient *_client;
    IQUser *_typingUser;
    NSTimer *typingTimer;
    BOOL _visible;

    IQChannelsState _state;
    IQSubscription *_stateSub;

    BOOL _messagesLoaded;
    NSMutableArray<IQChatMessage *> *_messages;
    NSMutableSet<NSNumber *> *_readMessages;

    IQSubscription *_messagesSub;
    IQSubscription *_moreMessagesLoading;


    // Action sheets
    UIActionSheet *_pickerActionSheet;
    UIActionSheet *_fileActionSheet;
    int64_t _fileActionSheetMessageId;
    UIActionSheet *_uploadActionSheet;
    int64_t _uploadActionSheetLocalId;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavbar];
    [self setupTabbarSupport];
    [self setupCollectionView];
    [self setupLoginIndicator];
    [self setupMessagesIndicator];
    [self setupBubbles];
    [self setupAvatars];
    [self setupRefreshControl];
}

- (void)setupNavbar {
    if (!self.navigationItem) {
        return;
    }
    if (self.navigationItem.title && self.navigationItem.title.length > 0) {
        return;
    };

    self.navigationItem.title = @"Сообщения";
};

- (void)setupTabbarSupport {
    if (!self.tabBarController && !(self.parentViewController && self.parentViewController.tabBarController)) {
        return;
    }

    self.edgesForExtendedLayout = UIRectEdgeTop;
}

- (void)setupCollectionView {
    // Hide keyboard on a tap.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tap.delegate = self;
    [self.collectionView addGestureRecognizer:tap];
    [self.collectionView registerNib:[MessagesTypingIndicatorFooterView nib]
          forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                 withReuseIdentifier:[MessagesTypingIndicatorFooterView footerReuseIdentifier]];
    [self.collectionView
        registerNib:[IQStackedSingleChoicesCell nib]
        forCellWithReuseIdentifier:[IQStackedSingleChoicesCell cellReuseIdentifier]
    ];
    [self.collectionView
        registerNib:[IQSingleChoicesCell nib]
        forCellWithReuseIdentifier:[IQSingleChoicesCell cellReuseIdentifier]
    ];
    [self.collectionView
        registerClass:[IQCardCell class]
        forCellWithReuseIdentifier: [IQCardCell cellReuseIdentifier]
    ];
}

- (void)setupLoginIndicator {
    _loginIndicator = [IQActivityIndicator activityIndicator];
    _loginIndicator.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:_loginIndicator];
    [self.view addConstraints:@[
            [NSLayoutConstraint constraintWithItem:_loginIndicator
                                         attribute:NSLayoutAttributeCenterX
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.view
                                         attribute:NSLayoutAttributeCenterX
                                        multiplier:1 constant:0],

            [NSLayoutConstraint constraintWithItem:_loginIndicator
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.view
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1 constant:0]
    ]];
}

- (void)setupMessagesIndicator {
    _messagesIndicator = [IQActivityIndicator activityIndicator];
    _messagesIndicator.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:_messagesIndicator];
    [self.view addConstraints:@[
            [NSLayoutConstraint constraintWithItem:_messagesIndicator
                                         attribute:NSLayoutAttributeCenterX
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.view
                                         attribute:NSLayoutAttributeCenterX
                                        multiplier:1 constant:0],

            [NSLayoutConstraint constraintWithItem:_messagesIndicator
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.view
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1 constant:0]
    ]];
}

- (void)setupBubbles {
    JSQMessagesBubbleImageFactory *factory = [[JSQMessagesBubbleImageFactory alloc] init];
    _incomingBubble = [factory incomingMessagesBubbleImageWithColor:[UIColor colorWithHex:0xe6e6eb]];
    _outgoingBubble = [factory outgoingMessagesBubbleImageWithColor:[UIColor colorWithHex:0x0f87ff]];
}

- (void)setupAvatars {
    // self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
}

- (void)setupRefreshControl {
    if (_refreshControl != nil) {
        return;
    }

    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:_refreshControl];
}

- (void)setupTypingTimer {
    typingTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                   target:self
                                                 selector:@selector(onTick)
                                                 userInfo:nil
                                                  repeats:NO];
    if (typingTimer == 0)
    {
        [typingTimer invalidate];
    }
}

- (void)singleChoicesView:(IQSingleChoicesView *)view didSelectOption:(IQSingleChoice *)singleChoice {
    [IQChannels sendSingleChoice: singleChoice];
}

- (void)onTick {
    self.showTypingIndicator = NO;
    self->_typingUser = nil;
    [typingTimer invalidate];
}

- (void)extendByTime:(NSInteger)seconds
{
    NSDate *newFireDate = [[typingTimer fireDate] dateByAddingTimeInterval:seconds];
    [typingTimer setFireDate:newFireDate];
}

- (NSString *)senderId {
    return _client ? _client.senderId : @"";
}

- (NSString *)senderDisplayName {
    return _client ? _client.senderDisplayName : @"";
}

#pragma mark viewWillAppear/Disappear

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _stateSub = [IQChannels state:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _visible = YES;

    if (_readMessages.count > 0) {
        for (NSNumber *messageId in _readMessages) {
            [IQChannels markAsRead:messageId.longLongValue];
        }
        [_readMessages removeAllObjects];
    }
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _visible = NO;
}

#pragma mark Keyboard

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark RefreshControl

- (void)refresh:(id)sender {
    if (_messagesLoaded) {
        [self loadMoreMessages];
    } else {
        [self loadMessages];
    }
}

#pragma mark InputToolbar

- (void)inputToolbarEnableInteraction {
    self.inputToolbar.contentView.textView.editable = YES;
    self.inputToolbar.contentView.leftBarButtonItem.enabled = YES;
}

- (void)inputToolbarDisableInteraction {
    self.inputToolbar.contentView.textView.editable = NO;
    self.inputToolbar.contentView.leftBarButtonItem.enabled = NO;
}

#pragma mark Clear all

- (void)clear {
    [self clearState];
    [self clearMessages];
    [self clearMoreMessages];
}

#pragma mark State

- (void)clearState {
    [_stateSub unsubscribe];

    _client = nil;
    _state = IQChannelsStateLoggedOut;
    _stateSub = nil;
}

- (void)iq_loggedOut:(IQChannelsState)state {
    if (_state == state) {
        return;
    }

    _state = state;
    [self clear];
    [_loginIndicator stopAnimating];
    [self inputToolbarDisableInteraction];
}

- (void)iq_awaitingNetwork:(IQChannelsState)state {
    if (_state == state) {
        return;
    }

    _state = state;
    _loginIndicator.label.text = [NSBundle
            iq_channelsLocalizedStringForKey:@"iqchannels.login_waiting_for_net" value:@"Ожидание сети..."];
    [_loginIndicator startAnimating];

    [self inputToolbarDisableInteraction];
}

- (void)iq_authenticating:(IQChannelsState)state {
    if (_state == state) {
        return;
    }

    _state = state;
    _loginIndicator.label.text = [NSBundle
            iq_channelsLocalizedStringForKey:@"iqchannels.login_in_progress" value:@"Авторизация..."];
    [_loginIndicator startAnimating];

    [self inputToolbarDisableInteraction];
}

- (void)iq_authenticated:(IQChannelsState)state client:(IQClient *)client {
    if (_state == state) {
        return;
    }

    _state = state;
    _client = client;
    _loginIndicator.label.text = @"";
    [_loginIndicator stopAnimating];

    [self loadMessages];
}

#pragma mark Messages

- (void)clearMessages {
    [_messagesIndicator stopAnimating];
    [_messagesSub unsubscribe];

    _messages = [[NSMutableArray alloc] init];
    _readMessages = [[NSMutableSet alloc] init];
    _messagesSub = nil;
    _messagesLoaded = NO;
}

- (void)loadMessages {
    if (!_client) {
        return;
    }
    if (_messagesSub) {
        return;
    }
    if (_messagesLoaded) {
        return;
    }

    _messagesSub = [IQChannels messages:self];
    _messagesIndicator.label.text = [NSBundle
            iq_channelsLocalizedStringForKey:@"iqchannels.loading" value:@"Загрузка..."];
    [_messagesIndicator startAnimating];
}

- (void)iq_messagesError:(NSError *)error {
    if (!_messagesSub) {
        return;
    }
    _messagesSub = nil;
    [_messagesIndicator stopAnimating];
    [_refreshControl endRefreshing];

    UIAlertView *alert = [UIAlertView iq_alertViewWithError:error];
    [alert show];
}

- (void)iq_messages:(NSArray<IQChatMessage *> *)messages {
    if (!_messagesSub) {
        return;
    }

    BOOL initial = !_messagesLoaded;
    CGFloat prevOffsetReversed = self.collectionView.contentSize.height - self.collectionView.contentOffset.y;

    _messages = [[NSMutableArray alloc] initWithArray:messages];
    _readMessages = [[NSMutableSet alloc] init];
    _messagesLoaded = YES;

    [_messagesIndicator stopAnimating];
    [self.collectionView reloadData];
    [self.view layoutIfNeeded];

    if (initial) {
        [self finishReceivingMessageAnimated:NO];

    } else {
        CGFloat offset = self.collectionView.contentSize.height - prevOffsetReversed;
        self.collectionView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, offset);
    }

    [_refreshControl endRefreshing];
}

- (void)iq_messagesCleared {
    [self clearMessages];

    [self.collectionView reloadData];
    [self inputToolbarDisableInteraction];
    [_messagesIndicator stopAnimating];
    [_refreshControl endRefreshing];
}

- (void)iq_messageAdded:(IQChatMessage *)message {
    [_messages addObject:message];
    [self finishReceivingMessageAnimated:YES];
}

- (void)iq_messageSent:(IQChatMessage *)message {
    [_messages addObject:message];
    [self finishSendingMessageAnimated:YES];
}

- (void)iq_messageUpdated:(IQChatMessage *)message {
    NSInteger index = [self getMessageIndex:message];
    if (index == -1) {
        return;
    }

    _messages[(NSUInteger) index] = message;
    {
        NSMutableArray *paths = [[NSMutableArray alloc] init];
        [paths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        if (index > 0) {
            [paths addObject:[NSIndexPath indexPathForItem:index - 1 inSection:0]];
        }
        [self.collectionView reloadItemsAtIndexPaths:paths];
    }
}

#pragma mark - Typing indicator

- (void)iq_messageTyping:(IQUser *)user; {
    if (self.showTypingIndicator == NO) {
        [self setupTypingTimer];
    } else {
        [self extendByTime:2];
    }

    _typingUser = user;
    self.showTypingIndicator = YES;
    [self scrollToBottomAnimated:YES];
}

- (UICollectionReusableView *)collectionView:(JSQMessagesCollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if (self.showTypingIndicator && [kind isEqualToString:UICollectionElementKindSectionFooter]) {
        return [self dequeueTypingIndicatorFooterViewForIndexPath:indexPath];
    }
    else if (self.showLoadEarlierMessagesHeader && [kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [collectionView dequeueLoadEarlierMessagesViewHeaderForIndexPath:indexPath];
    }

    return nil;
}

- (MessagesTypingIndicatorFooterView *)dequeueTypingIndicatorFooterViewForIndexPath:(NSIndexPath *)indexPath
{
    MessagesTypingIndicatorFooterView *footerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                            withReuseIdentifier:[MessagesTypingIndicatorFooterView footerReuseIdentifier]
                                                                                                   forIndexPath:indexPath];

    NSString *displayName = _typingUser.DisplayName;
    NSString *action = [NSBundle jsq_localizedStringForKey:@"печатает..."];
    NSString *text = [NSString stringWithFormat:@"%@ %@", displayName, action];
    [footerView configureWithText:text
                        textColor:[UIColor blackColor]
               messageBubbleColor:self.collectionView.typingIndicatorMessageBubbleColor
                forCollectionView:self.collectionView];
    return footerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (!self.showTypingIndicator) {
        return CGSizeZero;
    }

    return CGSizeMake([collectionViewLayout itemWidth], kMessagesTypingIndicatorFooterViewHeight);
}

- (void)iq_messagesRemoved:(NSArray<IQChatMessage *> *)messages {
    if (!_messagesSub) {
        return;
    }

    NSMutableArray<IQChatMessage *> *remoteMessages = [[NSMutableArray alloc] initWithArray:messages];

    NSInteger index = 0;
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for(IQChatMessage *localMessage in _messages) {
        for(IQChatMessage *remoteMessage in remoteMessages) {
            if (localMessage.Id == remoteMessage.Id) {
                [paths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
                [indexSet addIndex:index];
            }
        }

        index++;
    }

    [_messages removeObjectsAtIndexes:indexSet];
    [self.collectionView deleteItemsAtIndexPaths:paths];
}

- (NSInteger)getMessageIndex:(IQChatMessage *)message {
    NSInteger index = [self getMessageIndexById:message.Id];
    if (index >= 0) {
        return index;
    }
    if (message.My) {
        return [self getMyMessageByLocalId:message.LocalId];
    }
    return -1;
}

- (NSInteger)getMessageIndexById:(int64_t)messageId {
    if (messageId == 0) {
        return -1;
    }

    for (NSUInteger i = 0; i < _messages.count; i++) {
        IQChatMessage *message = _messages[i];
        if (message.Id == messageId) {
            return i;
        }
    }
    return -1;
}

- (NSInteger)getMyMessageByLocalId:(int64_t)localId {
    if (localId == 0) {
        return -1;
    }

    for (NSUInteger i = 0; i < _messages.count; i++) {
        IQChatMessage *message = _messages[i];
        if (message.My && message.LocalId == localId) {
            return i;
        }
    }
    return -1;
}

- (void)openMessageInBrowser:(int64_t)messageId {
    NSInteger index = [self getMessageIndexById:messageId];
    if (index == -1) {
        return;
    }

    IQChatMessage *message = _messages[(NSUInteger) index];
    if (!message) {
        return;
    }
    IQFile *file = message.File;
    if (!file) {
        return;
    }
    
    [IQChannels fileURL:file.Id callback:^(NSURL * _Nullable url, NSError * _Nullable error) {
        if (error) {
            UIAlertView *alert = [UIAlertView iq_alertViewWithError:error];
            [alert show];
            return;
        }
        
        [[UIApplication sharedApplication] openURL:url options:nil completionHandler:nil];
    }];
}

#pragma mark More messages

- (void)clearMoreMessages {
    [_moreMessagesLoading unsubscribe];
    _moreMessagesLoading = nil;
}

- (void)loadMoreMessages {
    if (!_client) {
        return;
    }
    if (!_messagesLoaded) {
        return;
    }

    _moreMessagesLoading = [IQChannels moreMessages:self];
    [_refreshControl beginRefreshing];
}

- (void)iq_moreMessagesLoaded {
    if (!_moreMessagesLoading) {
        return;
    }

    _moreMessagesLoading = nil;
    [_refreshControl endRefreshing];
}

- (void)iq_moreMessagesError:(NSError *)error {
    if (!_moreMessagesLoading) {
        return;
    }

    _moreMessagesLoading = nil;
    [_refreshControl endRefreshing];

    UIAlertView *alert = [UIAlertView iq_alertViewWithError:error];
    [alert show];
}

#pragma mark JSQMessagesViewController

- (void)textViewDidChange:(UITextView *)textView {
    [super textViewDidChange:textView];
    [IQChannels typing];
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    if (!_client) {
        return;
    }

    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];

    _pickerActionSheet = [[UIActionSheet alloc]
            initWithTitle:nil
                 delegate:self
        cancelButtonTitle:@"Отмена"
   destructiveButtonTitle:nil
        otherButtonTitles:nil];
    [_pickerActionSheet addButtonWithTitle:@"Галерея"];
    if (hasCamera) {
        [_pickerActionSheet addButtonWithTitle:@"Камера"];
    }
    [_pickerActionSheet addButtonWithTitle:@"Файл"];
    [_pickerActionSheet showInView:self.view];
}

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text
                  senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    if (!_messagesLoaded) {
        return;
    }

    [IQChannels sendText:text];
}

#pragma mark JSQMessagesCollectionViewDataSource

- (id <JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _messages[(NSUInteger) indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _messages.count;
}

- (id <JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
              messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    IQChatMessage *message = _messages[(NSUInteger) indexPath.item];
    if (message.My) {
        return _outgoingBubble;
    } else {
        return _incomingBubble;
    }
}

- (id <JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                     avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    IQChatMessage *message = _messages[(NSUInteger) indexPath.item];
    if (message.My) {
        return nil;
    }
    if (![self isGroupStart:indexPath]) {
        return nil;
    }

    IQUser *user = message.User;
    if (!user) {
        return nil;
    }
    if (user.AvatarImage) {
        return [JSQMessagesAvatarImageFactory
                avatarImageWithImage:user.AvatarImage diameter:(NSUInteger)
                        kJSQMessagesCollectionViewAvatarSizeDefault];
    }

    if (user.AvatarURL) {
        SDWebImageManager *m = [SDWebImageManager sharedManager];
        
        [m loadImageWithURL:user.AvatarURL options:0 progress:nil completed:
         ^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    return;
                }
                if (!image) {
                    return;
                }

                user.AvatarImage = image;
                NSInteger index = 0;
                if (message.My) {
                    index = [self getMyMessageByLocalId:message.LocalId];
                } else {
                    index = [self getMessageIndexById:message.Id];
                }

                NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
                [self.collectionView reloadItemsAtIndexPaths:@[path]];
            });
        }];
    }

    NSString *initials = [message.User.Name substringWithRange:NSMakeRange(0, 1)];
    return [JSQMessagesAvatarImageFactory
            avatarImageWithUserInitials:initials
                        backgroundColor:[UIColor paletteColorFromString:user.Name]
                              textColor:[UIColor whiteColor]
                                   font:[UIFont systemFontOfSize:14.0f]
                               diameter:(NSUInteger) kJSQMessagesCollectionViewAvatarSizeDefault];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *originalCellIdentifier = self.incomingCellIdentifier;
    IQChatMessage *message = _messages[(NSUInteger) indexPath.item];
    if ([message.Payload isEqual:IQChatPayloadSingleChoice]) {
        if (message.IsDropDown == YES) {
            self.incomingCellIdentifier = [IQSingleChoicesCell cellReuseIdentifier];
        } else {
            self.incomingCellIdentifier = [IQStackedSingleChoicesCell cellReuseIdentifier];
        }
    } else if ([message.Payload isEqual:IQChatPayloadCard] || [message.Payload isEqual:IQChatPayloadCarousel]) {
        return [self dequeueCardCell: collectionView atIndexPath: indexPath];
    }

    JSQMessagesCollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    self.incomingCellIdentifier = originalCellIdentifier;

    if (message.My) {
        cell.textView.textColor = [UIColor blackColor];
        UIImage *image = cell.messageBubbleImageView.image;
        cell.messageBubbleImageView.image = [image imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
        [cell.messageBubbleImageView setTintColor: [UIColor colorWithHex: 0xDCF5C0]];
    } else {
        cell.textView.textColor = [UIColor blackColor];

        if (!message.Read) {
            if (_visible) {
                [IQChannels markAsRead:message.Id];
            } else {
                [_readMessages addObject:@(message.Id)];
            }
        }

        if (_messages.count - 1 == indexPath.item) {
            if (message.DisableFreeText == YES) {
                [self inputToolbarDisableInteraction];
            } else {
                [self inputToolbarEnableInteraction];
            }
        }

    }

    cell.textView.linkTextAttributes = @{
        NSForegroundColorAttributeName : [UIColor colorWithHex: 0x0275d8],
        NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid)
    };

    if (message.isMediaMessage) {
        [IQChannels loadMessageMedia:message.Id];
    }
    
    if (message.File) {
        cell.textView.selectable = NO;
    } else {
        cell.textView.selectable = YES;
    }

    if (message.isFileMessage) {
        if (message.My) {
            JSQMessagesCollectionViewCellOutgoing *outgoingCell = (JSQMessagesCollectionViewCellOutgoing *)cell;
            outgoingCell.fileImageViewWidthConstraint.constant = 18;
            outgoingCell.fileImageViewLeadingConstraint.constant = 10;
            outgoingCell.fileImageViewTrailingConstraint.constant = 6;
        } else {
            JSQMessagesCollectionViewCellIncoming *incomingCell = (JSQMessagesCollectionViewCellIncoming *)cell;
            incomingCell.fileImageViewWidthConstraint.constant = 18;
            incomingCell.fileImageViewLeadingConstraint.constant = 18;
            incomingCell.fileImageViewTrailingConstraint.constant = -6;
        }
    }

    if ([message.Payload isEqual:IQChatPayloadSingleChoice]) {
        if (message.IsDropDown == YES) {
            if (_messages.count - 1 == indexPath.item && message.SingleChoices.count > 0) {
                IQSingleChoicesCell *incomingCell = (IQSingleChoicesCell *)cell;
                [incomingCell setSingleChoicesDelegate: self];
                [incomingCell setSingleChoices: [message.SingleChoices mutableCopy]];
            }
        } else {
            IQStackedSingleChoicesCell *incomingCell = (IQStackedSingleChoicesCell *)cell;
            [incomingCell setSingleChoices: [message.SingleChoices mutableCopy]];
            incomingCell.stackedSingleChoicesDelegate = self;
        }
    }

    return cell;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    IQChatMessage *message = _messages[(NSUInteger) indexPath.item];
    if (!message) {
        return;
    }

    IQFile *file = message.File;
    if (file) {
        NSString *filename = [file.Type isEqualToString:IQFileTypeImage] ? @"фото" : file.Name;
        _fileActionSheetMessageId = message.Id;
        _fileActionSheet = [[UIActionSheet alloc]
                initWithTitle:nil
                     delegate:self
            cancelButtonTitle:@"Отмена"
       destructiveButtonTitle:nil
            otherButtonTitles:[NSString stringWithFormat:@"Открыть %@ в браузере", filename], nil];
        [_fileActionSheet showInView:self.view];
        return;
    }

    if (message.UploadError) {
        _uploadActionSheetLocalId = message.LocalId;
        _uploadActionSheet = [[UIActionSheet alloc]
                initWithTitle:nil
                     delegate:self
            cancelButtonTitle:@"Отмена"
       destructiveButtonTitle:nil
            otherButtonTitles:@"Повторить", @"Удалить", nil];
        [_uploadActionSheet showInView:self.view];
    }

}

// User name

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    if (![self isGroupStart:indexPath]) {
        return nil;
    }
    IQChatMessage *message = _messages[(NSUInteger) indexPath.item];
    if (!message.User || !message.User.DisplayName) {
        return nil;
    }

    UIFont *font = [UIFont boldSystemFontOfSize:11];
    return [[NSAttributedString alloc] initWithString:message.User.DisplayName attributes:@{
            NSFontAttributeName: font
    }];
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    if (![self isGroupStart:indexPath]) {
        return 0.0f;
    }
    IQChatMessage *message = _messages[(NSUInteger) indexPath.item];
    if (!message.User) {
        return 0.0f;
    }

    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGSize)collectionView:(JSQMessagesCollectionView *)collectionView
                  layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [collectionViewLayout sizeForItemAtIndexPath:indexPath];
    IQChatMessage *message = _messages[(NSUInteger) indexPath.item];
    if ([message.Payload isEqual:IQChatPayloadSingleChoice]) {
        return [self getSingleChoiceCellSize: collectionViewLayout atIndexPath:indexPath];
    } else if ([message.Payload isEqual:IQChatPayloadCard] || [message.Payload isEqual:IQChatPayloadCarousel]) {
        return [self getCardCellSize: collectionViewLayout atIndexPath:indexPath];
    }
    return size;
}


// Message date

- (NSAttributedString *)  collectionView:(JSQMessagesCollectionView *)collectionView
attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    if (![self shouldDisplayMessageDate:indexPath]) {
        return nil;
    }

    NSUInteger index = (NSUInteger) indexPath.item;
    IQChatMessage *message = _messages[index];

    JSQMessagesTimestampFormatter *formatter = [JSQMessagesTimestampFormatter sharedFormatter];
    NSString *date = [formatter relativeDateForDate:message.date];
    return [[NSAttributedString alloc] initWithString:date attributes:formatter.dateTextAttributes];
}

- (CGFloat)       collectionView:(JSQMessagesCollectionView *)collectionView
                          layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    if (![self shouldDisplayMessageDate:indexPath]) {
        return 0.0f;
    }

    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (BOOL)shouldDisplayMessageDate:(NSIndexPath *)indexPath {
    NSUInteger index = (NSUInteger) indexPath.item;
    IQChatMessage *message = _messages[index];
    if (message.date == nil) {
        return NO;
    }
    if (index == 0) {
        return YES;
    }

    IQChatMessage *prev = _messages[index - 1];
    return prev.CreatedComponents.year != message.CreatedComponents.year
            || prev.CreatedComponents.month != message.CreatedComponents.month
            || prev.CreatedComponents.day != message.CreatedComponents.day;
}

// Message time

- (NSAttributedString *)     collectionView:(JSQMessagesCollectionView *)collectionView
attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    if (![self isGroupEnd:indexPath]) {
        return nil;
    }

    IQChatMessage *message = _messages[(NSUInteger) indexPath.item];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    if (message.My) {
        style.alignment = NSTextAlignmentRight;
    } else {
        style.alignment = NSTextAlignmentLeft;
    }

    NSString *time = [[JSQMessagesTimestampFormatter sharedFormatter] timeForDate:message.date];
    NSString *str = [NSString stringWithFormat:@"%@", time];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:11.0f],
            NSForegroundColorAttributeName: [UIColor lightGrayColor],
            NSParagraphStyleAttributeName: style
    }];

    if (message.My) {
        if (message.Received) {
            [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"✓" attributes:@{
                    NSForegroundColorAttributeName: [UIColor colorWithHex:0x00c853]
            }]];
        }
        if (message.Read) {
            [attrStr addAttribute:NSKernAttributeName value:@(-7) range:NSMakeRange(attrStr.length - 1, 1)];
            [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"✓" attributes:@{
                    NSForegroundColorAttributeName: [UIColor colorWithHex:0x00c853]
            }]];
        }
        [attrStr addAttribute:NSKernAttributeName value:@(7) range:NSMakeRange(attrStr.length - 1, 1)];

    } else {
        NSAttributedString *space = [[NSAttributedString alloc]
                initWithString:@" " attributes:@{NSKernAttributeName: @(33)}];
        [attrStr insertAttributedString:space atIndex:0];
    }

    return attrStr;
}

- (CGFloat)          collectionView:(JSQMessagesCollectionView *)collectionView
                             layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    if (![self isGroupEnd:indexPath]) {
        return 0.0f;
    }
    IQChatMessage *message = _messages[(NSUInteger) indexPath.item];
    if (!message.date) {
        return 0.0f;
    }

    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (BOOL)isGroupStart:(NSIndexPath *)indexPath {
    NSUInteger index = (NSUInteger) indexPath.item;
    IQChatMessage *message = _messages[index];
    if (index == 0) {
        return YES;
    }

    IQChatMessage *prev = _messages[index - 1];
    return prev.My != message.My
            || (prev.UserId && ![prev.UserId isEqual:message.UserId])
            || (message.CreatedAt - prev.CreatedAt) > 60000;
}

- (BOOL)isGroupEnd:(NSIndexPath *)indexPath {
    NSUInteger index = (NSUInteger) indexPath.item;
    IQChatMessage *message = _messages[index];
    if (index + 1 == _messages.count) {
        return YES;
    }

    IQChatMessage *next = _messages[index + 1];
    return next.My != message.My
            || (next.UserId && ![next.UserId isEqual:message.UserId])
            || (next.CreatedAt - message.CreatedAt) > 60000;
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == _uploadActionSheet) {
        switch (buttonIndex) {
            case 0:
                [self retryUpload:_uploadActionSheetLocalId];
                break;
            case 1:
                [self cancelUpload:_uploadActionSheetLocalId];
                break;
            default:
                break;
        }

    } else if (actionSheet == _fileActionSheet) {
        switch (buttonIndex) {
            case 0:
                [self openMessageInBrowser:_fileActionSheetMessageId];
                break;
            default:
                break;
        }

    } else if (actionSheet == _pickerActionSheet) {
        // Buttons are added manually, so they start with 1.
        switch (buttonIndex) {
            case 1:
                [self showPhotos];
                break;
            case 2:
                [self showCamera];
                break;
            case 3:
                [self showFiles];
                break;
            default:
                break;
        }
    }

    _uploadActionSheet = nil;
    _fileActionSheet = nil;
    _pickerActionSheet = nil;
}

#pragma mark Image picker

- (void)showCamera {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!granted) {
                        return;
                    }

                    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
                });
            }];
            break;
        }

        case AVAuthorizationStatusDenied: {
            NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id) kCFBundleNameKey];
            NSString *message = [NSString stringWithFormat:
                    @"Разрешить доступ к камере можно в Настройках телефона > %@ > Камера.", appName];
            UIAlertController *alertController = [UIAlertController
                    alertControllerWithTitle:@"Нет доступа к камере"
                                     message:message
                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }

        default: {
            [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
            break;
        }
    }
}

- (void)showPhotos {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (status0) {
                        case PHAuthorizationStatusRestricted:
                        case PHAuthorizationStatusAuthorized:
                            [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
                            break;
                        default:
                            break;
                    }
                });
            }];
            break;
        }

        case PHAuthorizationStatusDenied: {
            NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id) kCFBundleNameKey];
            NSString *message = [NSString stringWithFormat:
                    @"Разрешить доступ к фотографиям можно в Настройках телефона > %@ > Фото.", appName];
            UIAlertController *alertController = [UIAlertController
                    alertControllerWithTitle:@"Нет доступа к фотографиям"
                                     message:message
                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }

        default: {
            [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        }
    }
}

- (void)showFiles {
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"]
                                                                                                            inMode:UIDocumentPickerModeImport];
        documentPicker.delegate = self;
        documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller
didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        NSURL *url = urls[0];
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self confirmDataSubmission:data filename:url.lastPathComponent];
        });
    }
}

- (void)confirmDataSubmission:(NSData *)data filename:(NSString *)filename {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Подтвердите отправку файла"
                                                                             message:filename
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"Отправить"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
        [self sendData:data filename:filename];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Отмена"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
    }];

    [alertController addAction:cancelAction];
    [alertController addAction:okAction];

    [self presentViewController:alertController animated: YES completion: nil];
}

- (void)showImagePicker:(UIImagePickerControllerSourceType)source {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    picker.sourceType = source;
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    if (!image) {
        return;
    }
    
    // Get an asset filename.
    NSString *filename = @"";
    if (@available(iOS 11.0, *)) {
        PHAsset *asset = info[UIImagePickerControllerPHAsset];
        if (asset) {
            NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:asset];
            if (resources.count > 0) {
                PHAssetResource *resource = [resources firstObject];
                if (resource) {
                    filename = resource.originalFilename;
                }
            }
            // filename = [asset valueForKey:@"originalFilename"];
        }
    } else {
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url) {
            PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
            if (result.count > 0) {
                filename = [[result firstObject] filename];
            }
        }
    }
    
    // Dismiss the camera.
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self sendImage:image filename:filename];
        }];
        return;
    }

    // Present a gallery photo preview.
    void (^cancelBlock)(IQImagePreviewViewController *) = ^(IQImagePreviewViewController *controller) {
        CATransition *transition = [self transitionFromLeft];
        [controller.view.window.layer addAnimation:transition forKey:kCATransition];
        [controller dismissViewControllerAnimated:NO completion:nil];
    };
    void (^doneBlock)(IQImagePreviewViewController *) = ^(IQImagePreviewViewController *controller) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self sendImage:image filename:filename];
        }];
    };
    
    IQImagePreviewViewController *preview = [IQImagePreviewViewController controllerWithImage:image cancel:cancelBlock done:doneBlock];
    CATransition *transition = [self transitionFromRight];
    [picker.view.window.layer addAnimation:transition forKey:kCATransition];
    [picker presentViewController:preview animated:NO completion:nil];
}

- (void)sendImage:(UIImage *)image filename:(NSString *)filename {
    [IQChannels sendImage:image filename:filename];
}

- (void)sendData:(NSData *)data filename:(NSString *)filename {
    [IQChannels sendData:data filename:filename];
}

- (void)retryUpload:(int64_t)localId {
    [IQChannels retryUpload:localId];
}

- (void)cancelUpload:(int64_t)localId {
    [IQChannels deleteFailedUpload:localId];
}

- (CATransition *)transitionFromRight {
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = UINavigationControllerHideShowBarDuration;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    return transition;
}

- (CATransition *)transitionFromLeft {
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = UINavigationControllerHideShowBarDuration;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    return transition;
}

#pragma mark Card cell

- (IQCardCell *)dequeueCardCell:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    IQChatMessage *message = _messages[(NSUInteger) indexPath.item];
    IQCardCell *cell = [collectionView
        dequeueReusableCellWithReuseIdentifier: IQCardCell.cellReuseIdentifier
        forIndexPath: indexPath
    ];

    JSQMessagesTimestampFormatter *formatter = [JSQMessagesTimestampFormatter sharedFormatter];
    NSString *date = [formatter timeForDate:message.date];
    [cell setTime: date];

    cell.delegate = self;

    [cell setText: message.text];
    [cell setActions: [message.Actions mutableCopy]];

    JSQMessagesCollectionViewFlowLayout *layout = self.collectionView.collectionViewLayout;
    CGFloat width = [layout messageBubbleSizeForItemAtIndexPath: indexPath].width + 1;
    [cell setMessageBubbleWidth: width];

    if (message.isMediaMessage) {
        [cell setAsMedia];
        [IQChannels loadMessageMedia:message.Id];
        if (message.media) {
            JSQPhotoMediaItem *item = message.media;
            [cell setImage:item.image];
        }
    }

    if (!message.Read) {
        if (_visible) {
            [IQChannels markAsRead:message.Id];
        } else {
            [_readMessages addObject:@(message.Id)];
        }
    }

    return cell;
}

- (CGSize)getCardCellSize: (JSQMessagesCollectionViewFlowLayout *)layout atIndexPath:(NSIndexPath *)indexPath {

    IQChatMessage *message = _messages[(NSUInteger) indexPath.item];
    IQChatMessage *copyMessage = [[IQChatMessage alloc] init];
    [copyMessage setText: message.text];
    CGSize size = [layout.bubbleSizeCalculator messageBubbleSizeForMessageData:copyMessage
                                                          atIndexPath:indexPath
                                                           withLayout:layout];
    CGSize size2 = [layout sizeForItemAtIndexPath:indexPath];
    CGFloat imageHeight = message.isMediaMessage ? 150 : 0;
    return CGSizeMake(size2.width, imageHeight + size.height + message.Actions.count * 32 + 2 * 16 + 24);
}

- (CGSize)getSingleChoiceCellSize: (JSQMessagesCollectionViewFlowLayout *)layout atIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [layout sizeForItemAtIndexPath:indexPath];
    IQChatMessage *message = _messages[(NSUInteger) indexPath.item];
    if (message.IsDropDown == YES) {
        NSInteger horizontalInsets = layout.sectionInset.left + layout.sectionInset.right + 2;
        CGFloat width = CGRectGetWidth(layout.collectionView.bounds) - horizontalInsets;
        NSMutableArray<IQSingleChoice *> *choices = [message.SingleChoices mutableCopy];
        if (_messages.count - 1 != indexPath.item || choices.count < 1) {
            return size;
        }

        CGFloat height = 2 + 28 + 2;
        NSInteger index = 0;
        NSInteger choiceIndex = 0;
        do {
            CGFloat lineWidth = 0;
            while (lineWidth <= width && choiceIndex < choices.count) {
                NSString* title = choices[choiceIndex].title;
                CGRect boundingRect = [title boundingRectWithSize: CGSizeMake(-1, -1)
                       options: NSStringDrawingUsesLineFragmentOrigin
                       attributes: @{ NSFontAttributeName: [UIFont systemFontOfSize: 12] }
                       context: nil
                ];
                CGFloat choiceWidth = 6 + boundingRect.size.width + 6 + 1;
                lineWidth += choiceWidth;
                choiceIndex += 1;
            }
            if (lineWidth > width) {
                choiceIndex -= 1;
            }
            index += 1;
        } while (choiceIndex < choices.count);

        return CGSizeMake(width, size.height + height * index + 4 * (index - 1));
    } else {
        return CGSizeMake(size.width, size.height + message.SingleChoices.count * 35 - 3 + 6);
    }
}

#pragma mark IQStackedSingleChoicesCellDelegate

- (void)stackedSingleChoicesCell:(IQStackedSingleChoicesCell *)cell didSelectOption:(IQSingleChoice *)singleChoice {
    [IQChannels sendSingleChoice: singleChoice];
}

#pragma mark IQSCarCellDelegate

- (void)cardCell:(IQCardCell *)cell didSelectOption:(IQAction *)action {
    if ([action.Action isEqual: @"Postback"]) {
        [IQChannels sendAction: action];
    } else if ([action.Action isEqual: @"Open URL"]) {
        NSURL *url = [NSURL URLWithString:action.URL];
        [[UIApplication sharedApplication] openURL:url options:nil completionHandler:nil];
    } else if ([action.Action isEqual: @"Say something"]) {
        [IQChannels sendAction: action];
    }
}

@end
