// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import "BCPUserInterfaceCoordinator.h"
#import "BCPMacros.h"
#import "BCPUsersDetailsCache.h"
#import "BCPUsersDetailsProvider.h"
#import "BCPUserDetailsFormatter.h"

#import <Bandyer/Bandyer.h>
#import <Cordova/CDVPlugin.h>

@interface BCPUserInterfaceCoordinator () <BDKCallWindowDelegate, BDKChannelViewControllerDelegate, BDKCallBannerControllerDelegate, BDKInAppChatNotificationTouchListener, BDKInAppFileShareNotificationTouchListener>

@property (nonatomic, weak, readonly) UIViewController *viewController;
@property (nonatomic, strong) BDKCallBannerController *callBannerController;
@property (nonatomic, strong, readwrite) BDKCallWindow *callWindow;

@end

@implementation BCPUserInterfaceCoordinator

- (void)setSdk:(BandyerSDK *)sdk
{
    _sdk = sdk;

    if (sdk != nil)
    {
        [self didSetSdk];
    }
}

- (instancetype)initWithRootViewController:(UIViewController *)viewController
{
    BCPAssertOrThrowInvalidArgument(viewController, @"A view controller must be provided, got nil");

    self = [super init];

    if (self)
    {
        _viewController = viewController;
    }

    return self;
}

- (void)didSetSdk
{
    [self setupCallBannerView];
    [self setupInAppNotifications];
    [self.callBannerController show];
}

- (void)setupInAppNotifications
{
    self.sdk.notificationsCoordinator.chatListener = self;
    self.sdk.notificationsCoordinator.fileShareListener = self;
    self.sdk.notificationsCoordinator.formatter = [self makeFormatterIfPossible];
    [self.sdk.notificationsCoordinator start];
}

- (void)setupCallBannerView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillTransitionToSize:) name:CDVViewWillTransitionToSizeNotification object:nil];
    self.callBannerController = [BDKCallBannerController new];
    self.callBannerController.delegate = self;
    self.callBannerController.parentViewController = self.viewController;
}

- (void)makeCallWindowIfNeeded
{
    if (_callWindow == nil)
    {
        if (BDKCallWindow.instance)
        {
            _callWindow = BDKCallWindow.instance;
        } else
        {
            if (@available(iOS 13.0, *))
            {
                UIScene *scene = [UIApplication.sharedApplication.connectedScenes.allObjects firstObject];
                if ([scene isKindOfClass:UIWindowScene.class])
                {
                    _callWindow = [[BDKCallWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
                } else
                {
                    _callWindow = [[BDKCallWindow alloc] init];
                }
            } else
            {
                _callWindow = [[BDKCallWindow alloc] init];
            }
        }

        _callWindow.callDelegate = self;
    }
}

//------------------------------------------------------------------------
#pragma mark - Handling intent
//------------------------------------------------------------------------

- (void)handleIntent:(id <BDKIntent>)intent
{
    if ([intent isKindOfClass:BDKStartOutgoingCallIntent.class] || [intent isKindOfClass:BDKJoinURLIntent.class] ||
        [intent isKindOfClass:BDKHandleIncomingCallIntent.class])
        [self presentCallInterfaceForIntent:intent];
    else if ([intent isKindOfClass:BDKOpenChatIntent.class])
        [self presentChatFrom:self.viewController intent:intent];
    else
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"An unknown intent type has been provided" userInfo:nil];
}

//----------------------------------------------------------------------------
#pragma mark - Present Chat ViewController
//----------------------------------------------------------------------------

- (void)presentChatFrom:(BDKChatNotification *)notification
{
    if (self.viewController.presentedViewController != nil)
    {
        [self.viewController dismissViewControllerAnimated:YES completion:^{
            [self presentChatFrom:notification];
        }];
    } else
    {
        [self presentChatFrom:self.viewController notification:notification];
    }
}

- (void)presentChatFrom:(UIViewController *)controller notification:(BDKChatNotification *)notification
{
    BDKOpenChatIntent *intent = [BDKOpenChatIntent openChatFrom:notification];

    [self presentChatFrom:controller intent:intent];
}

- (void)presentChatFrom:(UIViewController *)controller intent:(BDKOpenChatIntent *)intent
{
    BDKChannelViewController *channelViewController = [[BDKChannelViewController alloc] init];
    channelViewController.delegate = self;

    if (@available(ios 13.0, *))
    {
        channelViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    }

    NSFormatter *formatter = [self makeFormatterIfPossible];
    BDKChannelViewControllerConfiguration *configuration = [[BDKChannelViewControllerConfiguration alloc] initWithAudioButton:YES videoButton:YES formatter:formatter];
    channelViewController.configuration = configuration;
    channelViewController.intent = intent;

    [controller presentViewController:channelViewController animated:YES completion:nil];
}

//---------------------------------------------------------------------------
#pragma mark - Present Call ViewController
//---------------------------------------------------------------------------

- (void)presentCallInterfaceForIntent:(id <BDKIntent>)intent
{
    BDKCallViewControllerConfiguration *config = [BDKCallViewControllerConfiguration new];
    config.fakeCapturerFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:self.fakeCapturerFilename ofType:@"mp4"]];

    NSFormatter *formatter = [self makeFormatterIfPossible];
    if (formatter != nil)
    {
        config.callInfoTitleFormatter = [[BCPUserDetailsFormatter alloc] initWithFormat:self.userDetailsFormat];
    }

    [self makeCallWindowIfNeeded];
    [self.callWindow setConfiguration:config];
    [self.callWindow presentCallViewControllerFor:intent completion:^(NSError * _Nullable error) {
        if (error != nil)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Another call ongoing." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:NULL];

            [alert addAction:defaultAction];
            [self.viewController presentViewController:alert animated:YES completion:nil];
        }
    }];
}

//--------------------------------------------------------------------
#pragma mark - Hide Call ViewController
//--------------------------------------------------------------------

- (void)hideCallInterface
{
    self.callWindow.hidden = YES;
}

- (void)destroyCallWindow
{
    self.callWindow = nil;
}

//--------------------------------------------------------------------
#pragma mark - Call window delegate
//--------------------------------------------------------------------

- (void)callWindowDidFinish:(BDKCallWindow *)window
{
    [self hideCallInterface];
}

- (void)callWindow:(BDKCallWindow *)window openChatWith:(BDKOpenChatIntent *)intent
{
    [self hideCallInterface];
    [self presentChatFrom:self.viewController intent:intent];
}

//---------------------------------------------------------------------
#pragma mark - Channel view controller delegate
//---------------------------------------------------------------------

- (void)channelViewControllerDidFinish:(BDKChannelViewController *)controller
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)channelViewController:(BDKChannelViewController *)controller didTapAudioCallWith:(NSArray *)users
{
    BDKCallOptions *callOptions = [BDKCallOptions optionsWithCallType:BDKCallTypeAudioUpgradable];
    BDKStartOutgoingCallIntent *intent = [[BDKStartOutgoingCallIntent alloc] initWithCallees:users options:callOptions];
    [self presentCallInterfaceForIntent:intent];
}

- (void)channelViewController:(BDKChannelViewController *)controller didTapVideoCallWith:(NSArray *)users
{
    BDKCallOptions *callOptions = [BDKCallOptions optionsWithCallType:BDKCallTypeAudioVideo];
    BDKStartOutgoingCallIntent *intent = [[BDKStartOutgoingCallIntent alloc] initWithCallees:users options:callOptions];
    [self presentCallInterfaceForIntent:intent];
}

//- (void)channelViewController:(BDKChannelViewController *)controller didTouchBanner:(BDKCallBannerView *)banner
//{
//    [self.viewController dismissViewControllerAnimated:YES completion:^{
//        [self presentCallInterfaceForIntent:self.callWindow.intent];
//    }];
//}

//----------------------------------------------------------------------
#pragma mark - In app notifications touch listeners
//----------------------------------------------------------------------

- (void)didTouchChatNotification:(BDKChatNotification *)notification
{
    [self.callWindow dismissCallViewControllerWithCompletion:^{
        [self presentChatFrom:notification];
    }];
}

- (void)didTouchFileShareNotification:(BDKFileShareNotification *)notification
{
    [self.callWindow presentCallViewControllerFor:[BDKOpenDownloadsIntent new] completion:^(NSError * _Nullable error) {}];
}

//----------------------------------------------------------
#pragma mark - Call Banner Controller delegate
//----------------------------------------------------------

- (void)callBannerControllerWillHideBanner:(BDKCallBannerController *)controller
{
}

- (void)callBannerControllerWillShowBanner:(BDKCallBannerController *)controller
{
}

- (void)callBannerControllerDidTouchBanner:(BDKCallBannerController *)controller
{
    [self presentCallInterfaceForIntent:self.callWindow.intent];
}

//----------------------------------------------------------
#pragma mark - UIViewController willTransitionToSize
//----------------------------------------------------------

- (void)viewWillTransitionToSize:(NSNotification *)notification
{
    NSValue *value = (NSValue *)notification.object;
    CGSize size = [value CGSizeValue];
    [self.callBannerController viewWillTransitionTo:size withTransitionCoordinator:nil];
}

//------------------------------------------------------------
#pragma mark - Formatter
//------------------------------------------------------------

- (nullable NSFormatter *)makeFormatterIfPossible
{
    if (self.userDetailsFormat != nil)
        return [[BCPUserDetailsFormatter alloc] initWithFormat:self.userDetailsFormat];

    return nil;
}

@end
