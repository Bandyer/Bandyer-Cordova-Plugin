//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCPSwizzler : NSObject

@property (nonatomic, strong, readonly) Class sourceClass;
@property (nonatomic, assign, readonly) SEL sourceSelector;
@property (nonatomic, assign, readonly) SEL targetSelector;

- (instancetype)initWithClass:(Class)sourceClass sourceSelector:(SEL)sourceSelector targetSelector:(SEL)targetSelector;

- (void)swizzle;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END