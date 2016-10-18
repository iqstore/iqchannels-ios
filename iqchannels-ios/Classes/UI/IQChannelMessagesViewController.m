//
//  IQChannelMessagesViewController.m
//  Pods
//
//  Created by Ivan Korobkov on 11/09/16.
//
//

#import "IQChannelMessagesViewController.h"
#import "IQChannels.h"
#import "IQClientSession.h"
#import "IQChannelMessageForm.h"
#import "IQChannelMessage.h"
#import "UIColor+IQChannels.h"
#import "IQChannelMessagesQuery.h"
#import "IQActivityIndicator.h"
#import "SDK.h"
#import "UIAlertView+IQChannels.h"
#import "IQChannelMessageViewData.h"
#import "IQChannelMessageViewArray.h"


@interface IQChannelMessagesViewController () <IQChannelsLoginListener>
@property(nonatomic) UIRefreshControl *refreshControl;
@property(nonatomic) IQActivityIndicator *loginIndicator;
@property(nonatomic) IQActivityIndicator *messagesIndicator;
@property(nonatomic) JSQMessagesBubbleImage *incomingBubble;
@property(nonatomic) JSQMessagesBubbleImage *outgoingBubble;
@end


@implementation IQChannelMessagesViewController {
    NSString *_navigationItemTitle; // Set on viewWillAppear.

    IQClient *_client;
    NSString *_senderId;
    IQChannelsLoginState _loginState;

    BOOL _loadedMessages;
    IQCancel _loadingMessages;
    IQChannelMessageViewArray *_messages;

    IQCancel _syncingEvents;
    IQChannelsSyncEventsState _syncEventsState;

    int64_t _userTypingAt;
    BOOL _userTypingTimeoutScheduled;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _senderId = @"";

    [self setupLoginIndicator];
    [self setupMessagesIndicator];
    [self setupBubbles];
    [self setupAvatars];
    self.automaticallyScrollsToMostRecentMessage = YES;
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
    _incomingBubble = [[[JSQMessagesBubbleImageFactory alloc] init] incomingMessagesBubbleImageWithColor:[UIColor colorWithHex:0xe6e6eb]];
    _outgoingBubble = [[[JSQMessagesBubbleImageFactory alloc] init] outgoingMessagesBubbleImageWithColor:[UIColor colorWithHex:0x0f87ff]];
}

- (void)setupAvatars {
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
}

#pragma mark viewWillAppear/Disappear

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQChannels addLoginListener:self];
    _navigationItemTitle = self.navigationItem.title;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self clearAll];
    [IQChannels removeLoginListener:self];
}

#pragma mark Clear all

- (void)clearAll {
    [self clearUserTyping];
    [self clearSyncEvents];
    [self clearMessages];
    [self clearClientAndSender];
}

#pragma mark Client and sender

- (NSString *)senderId {
    return _senderId ? _senderId : @"";
}

- (NSString *)senderDisplayName {
    return _client && _client.Name ? _client.Name : @"Client";
}

- (void)clearClientAndSender {
    _client = nil;
    _senderId = nil;
}

- (void)setClientAndSender:(IQClient *)client {
    _client = client;
    _senderId = [IQChannelMessageViewData senderIdWithClientId:client.Id];
}

#pragma mark RefreshControl

- (void)addRefreshControl {
    if (_refreshControl != nil) {
        return;
    }

    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:_refreshControl];
}

- (void)clearRefreshControl {
    if (_refreshControl == nil) {
        return;
    }

    [_refreshControl removeFromSuperview];
    _refreshControl = nil;
}

- (void)refresh:(id)sender {
    [self loadMoreMessages];
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

#pragma mark Messages

- (void)clearMessages {
    if (_loadingMessages != nil) {
        _loadingMessages();
    }

    _loadedMessages = NO;
    _loadingMessages = nil;
    _messages = [[IQChannelMessageViewArray alloc] init];
    [_messagesIndicator stopAnimating];
    [self clearRefreshControl];
}

- (void)loadMessages {
    if (_loginState != IQChannelsLoginComplete) {
        return;
    }
    if (_loadedMessages) {
        return;
    }
    if (_loadingMessages != nil) {
        return;
    }

    _messagesIndicator.label.text = [NSBundle iq_channelsLocalizedStringForKey:@"iqchannels.loading" value:@"Загрузка..."];
    [_messagesIndicator startAnimating];

    IQChannelMessagesQuery *query = [[IQChannelMessagesQuery alloc] init];
    _loadingMessages = [IQChannels loadMessages:query callback:^(NSArray<IQChannelMessage *> *messages, NSError *error) {
        [_messagesIndicator stopAnimating];
        if (error != nil) {
            [self loadMessagesFailedWithError:error];
            return;
        }

        [self loadedMessages:messages];
    }];
}

- (void)loadMessagesFailedWithError:(NSError *)error {
    if (_loadingMessages == nil) {
        return;
    }

    _loadingMessages = nil;
    UIAlertView *alertView = [UIAlertView iq_alertViewWithError:error];
    [alertView show];
}

- (void)loadedMessages:(NSArray<IQChannelMessage *> *)messages {
    if (_loadingMessages == nil) {
        return;
    }

    _loadingMessages = nil;
    _loadedMessages = YES;
    _messages = [[IQChannelMessageViewArray alloc] initWithClientId:_client.Id messages:messages];

    [self addRefreshControl];
    [self inputToolbarEnableInteraction];
    [self syncEvents];
    [self.collectionView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self finishReceivingMessageAnimated:NO];
    });
}

#pragma mark More messages

- (void)loadMoreMessages {
    if (_loginState != IQChannelsLoginComplete) {
        return;
    }
    if (!_loadedMessages) {
        return;
    }
    if (_loadingMessages != nil) {
        return;
    }

    NSNumber *maxId = _messages.minMessageId;
    if (maxId == nil) {
        [_refreshControl endRefreshing];
        return;
    }

    IQChannelMessagesQuery *query = [[IQChannelMessagesQuery alloc] initWithMaxId:maxId];
    _loadingMessages = [IQChannels loadMessages:query callback:^(NSArray<IQChannelMessage *> *messages, NSError *error) {
        [_refreshControl endRefreshing];
        if (error != nil) {
            [self loadMoreMessagesFailedWithError:error];
            return;
        }

        [self loadedMoreMessages:messages];
    }];
}

- (void)loadMoreMessagesFailedWithError:(NSError *)error {
    if (_loadingMessages == nil) {
        return;
    }

    _loadingMessages = nil;
    UIAlertView *alertView = [UIAlertView iq_alertViewWithError:error];
    [alertView show];
}

- (void)loadedMoreMessages:(NSArray<IQChannelMessage *> *)messages {
    if (_loadingMessages == nil) {
        return;
    }

    _loadingMessages = nil;
    if (messages.count == 0) {
        return;
    }

    [_messages prependMessages:messages];
    [self.collectionView reloadData];
}

#pragma mark Sync events

- (void)syncEvents {
    if (_loginState != IQChannelsLoginComplete) {
        return;
    }
    if (!_loadedMessages) {
        return;
    }
    if (_syncingEvents != nil) {
        return;
    }

    NSNumber *lastEventId = _messages.maxEventId;
    _syncingEvents = [IQChannels syncEvents:lastEventId
        callback:^(IQChannelsSyncEventsState state, NSArray<IQChannelEvent *> *array, NSError *error) {
            if (error != nil) {
                [self syncEventsFailedWithError:error];
                return;
            }

            [self syncEventsReceivedState:state events:array];
        }];
}

- (void)syncEventsFailedWithError:(NSError *)error {
    if (_syncingEvents == nil) {
        return;
    }

    // It must be a logged out error.
    _syncingEvents();
    _syncingEvents = nil;
}

- (void)syncEventsReceivedState:(IQChannelsSyncEventsState)state events:(NSArray<IQChannelEvent *> *)events {
    if (_syncingEvents == nil) {
        return;
    }

    if (_syncEventsState != state) {
        _syncEventsState = state;
        switch (state) {
            case IQChannelsSyncEventsInitial:
            case IQChannelsSyncEventsFailed:
            case IQChannelsSyncEventsClosed: {
                self.navigationItem.title = _navigationItemTitle;
                break;
            }
            case IQChannelsSyncEventsWaitingForNetwork: {
                self.navigationItem.title = [NSBundle iq_channelsLocalizedStringForKey:@"iqchannels.waiting_for_net"
                    value:@"Ожидание сети..."];
                break;
            }
            case IQChannelsSyncEventsConnecting: {
                self.navigationItem.title = [NSBundle iq_channelsLocalizedStringForKey:@"iqchannels.connecting" value:@"Подключение..."];
                break;
            }
            case IQChannelsSyncEventsInProgress: {
                self.navigationItem.title = _navigationItemTitle;
                break;
            }
        }
    }

    for (IQChannelEvent *event in events) {
        [self applyEvent:event];
    }
}

- (void)clearSyncEvents {
    if (_syncingEvents != nil) {
        _syncingEvents();
        _syncingEvents = nil;
    }

    _syncEventsState = IQChannelsSyncEventsInitial;
}

- (void)applyEvent:(IQChannelEvent *)event {
    if ([event.Type isEqualToString:IQChannelEventTyping]) {
        if (event.UserId != nil) {
            [self setUserTypingAt:event.CreatedAt];
        }
        return;
    }

    BOOL created = NO;
    NSUInteger updated = 0;
    [_messages applyEvent:event created:&created updated:&updated];

    if (created) {
        [self finishReceivingMessage];
    } else if (updated > 0) {
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:updated inSection:0]]];
    }
}

#pragma mark Typing

- (void)setUserTypingAt:(int64_t)typingAt {
    if (typingAt < _userTypingAt) {
        return;
    }

    _userTypingAt = typingAt;
    if (![self userIsTyping]) {
        return;
    }

    self.showTypingIndicator = YES;
    [self maybeScheduleUserTypingTimeout];
}

- (BOOL)userIsTyping {
    int64_t now = (int64_t) ([NSDate date].timeIntervalSince1970 * 1000);
    return now < _userTypingAt + 2000;
}

- (void)maybeScheduleUserTypingTimeout {
    if (_userTypingTimeoutScheduled) {
        return;
    }

    _userTypingTimeoutScheduled = YES;
    dispatch_time_t time = [IQTimeout timeWithTimeoutSeconds:2];
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self userTypingTimeout];
    });
}

- (void)userTypingTimeout {
    if (!_userTypingTimeoutScheduled) {
        return;
    }
    _userTypingTimeoutScheduled = NO;

    if ([self userIsTyping]) {
        [self maybeScheduleUserTypingTimeout];
    } else {
        self.showTypingIndicator = NO;
    }
}

- (void)clearUserTyping {
    _userTypingAt = 0;
    _userTypingTimeoutScheduled = NO;
}

#pragma mark IQChannelsLoginListener

- (void)channelsLoginStateChanged:(IQChannelsLoginState)state {
    if (_loginState == state) {
        return;
    }

    _loginState = state;
    switch (state) {
        case IQChannelsLoginLoggedOut: {
            [self clearAll];

            [_loginIndicator stopAnimating];
            [self inputToolbarDisableInteraction];
            break;
        }

        case IQChannelsLoginWaitingForNetwork: {
            [_loginIndicator startAnimating];
            _loginIndicator.label.text = [NSBundle iq_channelsLocalizedStringForKey:
                @"iqchannels.login_waiting_for_net" value:@"Ожидание сети..."];

            [self inputToolbarDisableInteraction];
            break;
        }

        case IQChannelsLoginInProgress: {
            [_loginIndicator startAnimating];
            _loginIndicator.label.text = [NSBundle iq_channelsLocalizedStringForKey:
                @"iqchannels.login_in_progress" value:@"Авторизация..."];

            [self inputToolbarDisableInteraction];
            break;
        }

        case IQChannelsLoginComplete: {
            [_loginIndicator stopAnimating];
            _loginIndicator.label.text = @"";

            IQClient *client = [IQChannels loginClient];
            [self setClientAndSender:client];
            [self loadMessages];
            break;
        }
    }
}

#pragma mark JSQMessagesViewController

- (void)textViewDidChange:(UITextView *)textView {
    [super textViewDidChange:textView];
    [IQChannels sendTyping];
}

- (void)didPressAccessoryButton:(UIButton *)sender {
}

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text
                  senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    if (!_loadedMessages) {
        return;
    }

    IQChannelMessageForm *form = [[IQChannelMessageForm alloc] initWithText:text];
    IQChannelMessage *message = [IQChannels sendMessage:form];
    [_messages appendMessage:message];
    [self finishSendingMessage];
}

#pragma mark JSQMessagesCollectionViewDataSource

- (id <JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _messages.items[(NSUInteger) indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _messages.items.count;
}

- (id <JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
              messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    IQChannelMessageViewData *data = _messages.items[(NSUInteger) indexPath.item];
    if ([data.message.Author isEqualToString:IQChannelAuthorClient]) {
        return _outgoingBubble;
    } else {
        return _incomingBubble;
    }
}

- (id <JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                     avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessagesCollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    IQChannelMessageViewData *data = _messages.items[(NSUInteger) indexPath.item];
    if ([data.message.Author isEqualToString:IQChannelAuthorClient]) {
        cell.textView.textColor = [UIColor whiteColor];
    } else {
        cell.textView.textColor = [UIColor blackColor];

        if (!data.message.Read) {
            [IQChannels sendReadMessage:data.message.Id];
        }
    }
    return cell;
}

// Message date

- (NSAttributedString *)  collectionView:(JSQMessagesCollectionView *)collectionView
attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    IQChannelMessageViewData *item = _messages.items[(NSUInteger) indexPath.item];
    if (!item.showDate) {
        return nil;
    }

    return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:item.date];
}

- (CGFloat)       collectionView:(JSQMessagesCollectionView *)collectionView
                          layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    IQChannelMessageViewData *item = _messages.items[(NSUInteger) indexPath.item];
    if (!item.showDate) {
        return 0.0f;
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

// Message time

- (NSAttributedString *)     collectionView:(JSQMessagesCollectionView *)collectionView
attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    IQChannelMessageViewData *item = _messages.items[(NSUInteger) indexPath.item];
    if (item.message.CreatedAt == 0) {
        return nil;
    }

    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    if ([item.message.Author isEqualToString:IQChannelAuthorClient]) {
        style.alignment = NSTextAlignmentRight;
    } else {
        style.alignment = NSTextAlignmentLeft;
    }

    NSString *time = [[JSQMessagesTimestampFormatter sharedFormatter] timeForDate:item.date];
    time = [NSString stringWithFormat:@"     %@     ", time];
    return [[NSMutableAttributedString alloc] initWithString:time attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:10.0f],
        NSForegroundColorAttributeName: [UIColor lightGrayColor],
        NSParagraphStyleAttributeName: style
    }];
}

- (CGFloat)          collectionView:(JSQMessagesCollectionView *)collectionView
                             layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    IQChannelMessageViewData *item = _messages.items[(NSUInteger) indexPath.item];
    if (item.message.CreatedAt == 0) {
        return 0.0f;
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}
@end
