//
//  IQChannelMessagesViewController.m
//  Pods
//
//  Created by Ivan Korobkov on 11/09/16.
//
//

#import "IQChannelMessagesViewController.h"
#import "UIColor+IQChannels.h"
#import "IQClientSession.h"
#import "IQChannels.h"
#import "IQChannelMessageForm.h"
#import "IQChannelMessage.h"
#import "IQChannelThread.h"
#import "IQChannelsSession.h"
#import "NSError+IQChannels.h"
#import "IQChannelMessagesQuery.h"
#import "IQTimeout.h"
#import "IQChannelThreadQuery.h"


@interface IQChannelMessagesViewController () <IQChannelsListener>
@end


@implementation IQChannelMessagesViewController {
    NSString *_senderId;
    IQChannelThread *_thread;
    IQChannelsSessionState _sessionState;

    IQCancel _loadingThread;
    IQCancel _loadingMessages;
    IQCancel _listeningToEvents;
    BOOL _typingEndScheduled;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
    [self clear];
    [IQChannels addListener:self];
}

- (void)setupView {
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:_refreshControl];

    _incomingBubble = [[[JSQMessagesBubbleImageFactory alloc] init]
        incomingMessagesBubbleImageWithColor:[UIColor colorWithHex:0xe6e6eb]];
    _outgoingBubble = [[[JSQMessagesBubbleImageFactory alloc] init]
        outgoingMessagesBubbleImageWithColor:[UIColor colorWithHex:0x0f87ff]];

    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;

    self.automaticallyScrollsToMostRecentMessage = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (_loadingThread != nil) {
        _loadingThread();
        _loadingThread = nil;
    }
    if (_loadingMessages != nil) {
        _loadingMessages();
        _loadingMessages = nil;
    }
    if (_listeningToEvents != nil) {
        _listeningToEvents();
        _listeningToEvents = nil;
    }
    [IQChannels removeListener:self];
}

- (NSString *)senderId {
    return _senderId;
}

- (NSString *)senderDisplayName {
    return @"Client";
}

- (void)clear {
    _senderId = @"";
    _thread = nil;
}

- (void)refresh:(id)sender {
    [self loadMoreMessages];
}

- (void)userInteractionEnable {
    self.inputToolbar.contentView.textView.editable = YES;
    self.inputToolbar.contentView.leftBarButtonItem.enabled = YES;
}

- (void)userInteractionDisable {
    self.inputToolbar.contentView.textView.editable = NO;
    self.inputToolbar.contentView.leftBarButtonItem.enabled = NO;
}

- (void)reloadData {
    [self.collectionView reloadData];
    [self reloadThreadData];
}

- (void)reloadThreadData {
    int64_t now = (int64_t) ([[NSDate date] timeIntervalSince1970] * 1000);
    BOOL typing = (now - _thread.UserTypingAt) < 2000;
    self.showTypingIndicator = typing;

    if (typing && !_typingEndScheduled) {
        dispatch_time_t timeout = [IQTimeout timeWithTimeoutSeconds:2];
        dispatch_after(timeout, dispatch_get_main_queue(), ^{
            _typingEndScheduled = NO;
            [self reloadData];
        });
    }
}

#pragma mark loadThread

- (void)loadThread {
    if (_sessionState != IQChannelsSessionStateAuthenticated) {
        return;
    }

    IQChannelThreadQuery *query = [[IQChannelThreadQuery alloc] initWithMessagesLimit:@(25)];
    _loadingThread = [IQChannels loadThread:query callback:^(IQChannelThread *thread, NSError *error) {
        if (error != nil) {
            [self failedToLoadThreadWithError:error];
            return;
        }
        [self loadedThread:thread];
    }];
    [_refreshControl beginRefreshing];
}

- (void)loadedThread:(IQChannelThread *)thread {
    if (_loadingThread == nil) {
        return;
    }
    _loadingThread = nil;
    [_refreshControl endRefreshing];

    _thread = [thread copy];
    [self reloadData];
    [self finishReceivingMessage];
    [self userInteractionEnable];
    [self listenToEvents];
}

- (void)failedToLoadThreadWithError:(NSError *)error {
    if (_loadingMessages == nil) {
        return;
    }
    _loadingMessages = nil;
    [_refreshControl endRefreshing];

    UIAlertView *alert = [error iq_toAlertView];
    [alert show];
}

#pragma mark loadMessages

- (void)loadMoreMessages {
    if (_sessionState != IQChannelsSessionStateAuthenticated) {
        return;
    }
    if (_thread == nil) {
        return;
    }
    if (_loadingMessages != nil) {
        return;
    }

    IQChannelMessagesQuery *query = [[IQChannelMessagesQuery alloc] init];
    if (_thread.Messages.count > 0) {
        query.MaxId = @(_thread.Messages[0].Id);
    }

    _loadingMessages = [IQChannels loadMessages:query
        callback:^(NSArray<IQChannelMessage *> *array, NSError *error) {
            if (error != nil) {
                [self failedToLoadMessagesWithError:error];
                return;
            }

            [self loadedMessages:array];
        }];
}

- (void)loadedMessages:(NSArray<IQChannelMessage *> *)messages {
    if (_loadingMessages == nil) {
        return;
    }
    _loadingMessages = nil;
    [_refreshControl endRefreshing];

    // Add loaded messages to the thread.
    [_thread prependMessages:messages];

    // Allow the refresh control to hide before reloading the data.
    dispatch_time_t timeout = [IQTimeout timeWithTimeoutSeconds:0.3];
    dispatch_after(timeout, dispatch_get_main_queue(), ^{
        [self reloadData];
    });
}

- (void)failedToLoadMessagesWithError:(NSError *)error {
    if (_loadingMessages == nil) {
        return;
    }
    _loadingMessages = nil;
    [_refreshControl endRefreshing];

    UIAlertView *alert = [error iq_toAlertView];
    [alert show];
}

#pragma mark listenToEvents

- (void)listenToEvents {
    if (_sessionState != IQChannelsSessionStateAuthenticated) {
        return;
    }
    if (_listeningToEvents != nil) {
        return;
    }

    _listeningToEvents = [IQChannels listenToEvents:_thread.EventId callback:^(NSArray<IQChannelEvent *> *events) {
        [self receivedEvents:events];
    }];
}

- (void)receivedEvents:(NSArray<IQChannelEvent *> *)events {
    [_thread applyEvents:events];
    [self reloadData];
}

#pragma mark JSQMessagesViewController

- (void)textViewDidChange:(UITextView *)textView {
    [super textViewDidChange:textView];
    [IQChannels typing];
}

- (void)didPressAccessoryButton:(UIButton *)sender {
}

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text
                  senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    if (_senderId == nil || [_senderId isEqualToString:@""]) {
        return;
    }

    IQChannelMessageForm *form = [[IQChannelMessageForm alloc] initWithText:text];
    IQChannelMessage *message = [IQChannels sendMessage:form];
    [_thread appendMessage:message];
    [self finishSendingMessageAnimated:YES];
}

#pragma mark JSQMessagesCollectionViewDataSource

- (id <JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView
        messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _thread.Messages[(NSUInteger) indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_thread.Messages == nil) {
        return 0;
    }

    return _thread.Messages.count;
}

- (id <JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
              messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    IQChannelMessage *message = _thread.Messages[(NSUInteger) indexPath.item];
    if ([message.Author isEqualToString:IQChannelAuthorClient]) {
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

    IQChannelMessage *message = _thread.Messages[(NSUInteger) indexPath.item];
    if ([message.Author isEqualToString:IQChannelAuthorClient]) {
        cell.textView.textColor = [UIColor whiteColor];
    } else {
        cell.textView.textColor = [UIColor blackColor];
        [IQChannels readMessage:message.Id];
    }
    return cell;
}

#pragma mark IQChannelsListener

- (void)channelsSessionAuthenticating:(IQChannelsSession *)session {
    _sessionState = IQChannelsSessionStateAuthenticating;
    [_refreshControl beginRefreshing];
    [self userInteractionDisable];
}

- (void)channelsSessionAuthenticated:(IQChannelsSession *)session {
    _senderId = [IQChannelMessage senderIdWithClientId:session.authentication.ClientId];
    _sessionState = IQChannelsSessionStateAuthenticated;
    [_refreshControl endRefreshing];

    [self loadThread];
}

- (void)channelsSessionClosed {
    _sessionState = IQChannelsSessionStateClosed;
    [self clear];
    [self userInteractionDisable];
}
@end
