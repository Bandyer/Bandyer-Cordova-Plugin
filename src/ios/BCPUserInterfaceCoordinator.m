//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import "BCPUserInterfaceCoordinator.h"
#import "BCPMacros.h"
#import "BCPUsersDetailsCache.h"
#import "BCPUsersDetailsFetcher.h"

@interface BCPUserInterfaceCoordinator () <BDKCallViewControllerDelegate>

@property (nonatomic, weak, readonly) UIViewController *viewController;
@property (nonatomic, strong, readonly) BCPUsersDetailsCache *cache;

@end

@implementation BCPUserInterfaceCoordinator


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

- (void)handleIntent:(id <BDKIntent>)intent
{
    BDKCallViewController *callViewController = [self _createCallViewController];

    [callViewController handleIntent:intent];

    [self.viewController presentViewController:callViewController animated:YES completion:nil];
}


- (BDKCallViewController *)_createCallViewController
{
    BDKCallViewControllerConfiguration *config = [BDKCallViewControllerConfiguration new];
    config.userInfoFetcher = [[BCPUsersDetailsFetcher alloc] initWithCache:self.cache];
    config.fakeCapturerFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:self.fakeCapturerFilename ofType:@"mp4"]];

    BDKCallViewController *controller = [BDKCallViewController new];

    [controller setDelegate:self];
    [controller setConfiguration:config];
    return controller;
}

- (void)callViewControllerDidFinish:(BDKCallViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void)callViewControllerDidPressBack:(BDKCallViewController *)controller
{

}

- (void)callViewController:(BDKCallViewController *)controller openChatWith:(NSString *)participantId
{

}


@end
