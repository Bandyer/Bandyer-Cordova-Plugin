//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>
#import <BandyerSDK/BDKIntent.h>

@class BCPUsersDetailsCache;

NS_ASSUME_NONNULL_BEGIN

@interface BCPUserInterfaceCoordinator : NSObject

@property (nonatomic, strong) NSString *fakeCapturerFilename;

- (instancetype)initWithRootViewController:(UIViewController *)viewController usersCache:(BCPUsersDetailsCache *)cache;

- (void)sdkInitialized;

- (void)handleIntent:(id <BDKIntent>)intent;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
