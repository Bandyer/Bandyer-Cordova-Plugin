//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import "BCPUserInterfaceCoordinator.h"
#import "BCPMacros.h"
#import "BCPUsersDetailsCache.h"
#import "BCPUsersDetailsProvider.h"
#import "BCPUserDetailsFormatter.h"

#import <Bandyer/Bandyer.h>
#import <Bandyer/Bandyer-Swift.h>

@interface BCPUserInterfaceCoordinator () <BDKCallWindowDelegate, BCHChannelViewControllerDelegate, BCHMessageNotificationControllerDelegate, BDKCallBannerControllerDelegate>

@property (nonatomic, weak, readonly) UIViewController *viewController;
@property (nonatomic, strong, readonly) BCPUsersDetailsCache *cache;
@property (nonatomic, strong) BDKCallBannerController *callBannerController;
@property (nonatomic, strong) BCHMessageNotificationController *messageNotificationController;
@property (nonatomic, strong, readwrite) BDKCallWindow *callWindow;

@end

@implementation BCPUserInterfaceCoordinator

- (BDKCallWindow *)callWindow
{
    if (!_callWindow)
    {
        if (BDKCallWindow.instance)
        {
            _callWindow = BDKCallWindow.instance;
        } else
        {
            _callWindow = [[BDKCallWindow alloc] init];
        }

        _callWindow.callDelegate = self;
    }

    return _callWindow;
}

- (instancetype)initWithRootViewController:(UIViewController *)viewController usersCache:(BCPUsersDetailsCache *)cache
{
    BCPAssertOrThrowInvalidArgument(viewController, @"A view controller must be provided, got nil");
    BCPAssertOrThrowInvalidArgument(cache, @"Users details cache must be provided, got nil");

    self = [super init];

    if (self)
    {
        _viewController = viewController;
        _cache = cache;
    }

    return self;
}

- (void)sdkInitialized
{
    [self setupCallBannerView];
    [self setupNotificationView];
    [self.messageNotificationController show];
    [self.callBannerController show];
}

- (void)setupNotificationView
{
    self.messageNotificationController = [BCHMessageNotificationController new];
    self.messageNotificationController.configuration = [[BCHMessageNotificationControllerConfiguration alloc] initWithUserInfoFetcher:[[BCPUsersDetailsProvider alloc] initWithCache:self.cache]];;
    self.messageNotificationController.delegate = self;
    self.messageNotificationController.parentViewController = self.viewController;
}

- (void)setupCallBannerView
{
    self.callBannerController = [BDKCallBannerController new];
    self.callBannerController.delegate = self;
    self.callBannerController.parentViewController = self.viewController;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Handling intent
//-------------------------------------------------------------------------------------------

- (void)handleIntent:(id <BDKIntent>)intent
{
    if ([intent isKindOfClass:BDKMakeCallIntent.class] || [intent isKindOfClass:BDKJoinURLIntent.class] ||
        [intent isKindOfClass:BDKIncomingCallHandlingIntent.class])
        [self presentCallInterfaceForIntent:intent];
    else if ([intent isKindOfClass:BCHOpenChatIntent.class])
        [self presentChatFrom:self.viewController intent:intent];
    else
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"An unknown intent type has been provided" userInfo:nil];

}

//-------------------------------------------------------------------------------------------
#pragma mark - Present Chat ViewController
//-------------------------------------------------------------------------------------------

- (void)presentChatFrom:(BCHChatNotification *)notification
{
    if (!self.viewController.presentedViewController)
    {
        [self presentChatFrom:self.viewController notification:notification];
    }
}

- (void)presentChatFrom:(UIViewController *)controller notification:(BCHChatNotification *)notification
{
    BCHOpenChatIntent *intent = [BCHOpenChatIntent openChatFrom:notification];

    [self presentChatFrom:controller intent:intent];
}

- (void)presentChatFrom:(UIViewController *)controller intent:(BCHOpenChatIntent *)intent
{
    BCHChannelViewController *channelViewController = [[BCHChannelViewController alloc] init];
    channelViewController.delegate = self;

    if (@available(ios 13.0, *))
    {
        channelViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    }

    BCPUsersDetailsProvider *fetcher = [[BCPUsersDetailsProvider alloc] initWithCache:self.cache];
    BCHChannelViewControllerConfiguration *configuration = [[BCHChannelViewControllerConfiguration alloc] initWithAudioButton:YES videoButton:YES userInfoFetcher:fetcher];
    channelViewController.configuration = configuration;
    channelViewController.intent = intent;

    [controller presentViewController:channelViewController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Present Call ViewController
//-------------------------------------------------------------------------------------------

- (void)presentCallInterfaceForIntent:(id <BDKIntent>)intent
{
    BDKCallViewControllerConfiguration *config = [BDKCallViewControllerConfiguration new];
    config.fakeCapturerFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:self.fakeCapturerFilename ofType:@"mp4"]];
    config.userInfoFetcher = [[BCPUsersDetailsProvider alloc] initWithCache:self.cache];

    if (self.userDetailsFormat)
    {
        config.callInfoTitleFormatter = [[BCPUserDetailsFormatter alloc] initWithFormat:self.userDetailsFormat];
    }

    [self.callWindow setConfiguration:config];

    [self.callWindow shouldPresentCallViewControllerWithIntent:intent completion:^(BOOL succeeded) {

        if (!succeeded)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Another call ongoing." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:NULL];

            [alert addAction:defaultAction];
            [self.viewController presentViewController:alert animated:YES completion:nil];
        }
    }];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Hide Call ViewController
//-------------------------------------------------------------------------------------------

- (void)hideCallInterface
{
    self.callWindow.hidden = YES;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Call window delegate
//-------------------------------------------------------------------------------------------

- (void)callWindowDidFinish:(BDKCallWindow *)window
{
    [self hideCallInterface];
}

- (void)callWindow:(BDKCallWindow *)window openChatWith:(BCHOpenChatIntent *)intent
{
    [self hideCallInterface];
    [self presentChatFrom:self.viewController intent:intent];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Channel view controller delegate
//-------------------------------------------------------------------------------------------

- (void)channelViewControllerDidFinish:(BCHChannelViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)channelViewController:(BCHChannelViewController *)controller didTapAudioCallWith:(NSArray *)users
{
    [self presentCallInterfaceForIntent:[BDKMakeCallIntent intentWithCallee:users type:BDKCallTypeAudioUpgradable]];
}

- (void)channelViewController:(BCHChannelViewController *)controller didTapVideoCallWith:(NSArray *)users
{
    [self presentCallInterfaceForIntent:[BDKMakeCallIntent intentWithCallee:users type:BDKCallTypeAudioVideo]];
}

- (void)channelViewController:(BCHChannelViewController *)controller didTouchNotification:(BCHChatNotification *)notification
{
    if ([self.viewController.presentedViewController isKindOfClass:BCHChannelViewController.class])
    {
        [controller dismissViewControllerAnimated:YES completion:^{
            [self presentChatFrom:notification];
        }];

        return;
    }

    [self presentChatFrom:notification];
}

- (void)channelViewController:(BCHChannelViewController *)controller willHide:(BDKCallBannerView *)banner
{
}

- (void)channelViewController:(BCHChannelViewController *)controller willShow:(BDKCallBannerView *)banner
{
}

- (void)channelViewController:(BCHChannelViewController *)controller didTouchBanner:(BDKCallBannerView *)banner
{
    [controller dismissViewControllerAnimated:YES completion:^{
        [self presentCallInterfaceForIntent:self.callWindow.intent];
    }];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Message Notification Controller delegate
//-------------------------------------------------------------------------------------------

- (void)messageNotificationController:(BCHMessageNotificationController *)controller didTouch:(BCHChatNotification *)notification
{
    [self presentChatFrom:notification];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Call Banner Controller delegate
//-------------------------------------------------------------------------------------------

- (void)callBannerController:(BDKCallBannerController *)controller willHide:(BDKCallBannerView *)banner
{
}

- (void)callBannerController:(BDKCallBannerController *)controller willShow:(BDKCallBannerView *)banner
{
}

- (void)callBannerController:(BDKCallBannerController *)controller didTouch:(BDKCallBannerView *)banner
{
    [self presentCallInterfaceForIntent:self.callWindow.intent];
}

@end
