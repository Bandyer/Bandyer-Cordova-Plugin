// Copyright © 2020 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import "BCPUserDetailsFormatter.h"
#import "BCPMacros.h"

#import <Bandyer/BDKUserDetails.h>

@interface BCPUserDetailsFormatter()

@property (nonatomic, copy, readonly) NSString *format;
@property (nonatomic, strong, readonly) NSDictionary <NSString *, NSString *> *tokenPropertyMap;
@end

@implementation BCPUserDetailsFormatter

- (instancetype)initWithFormat:(NSString *)format
{
    BCPAssertOrThrowInvalidArgument(format, @"A format string must be provided, got nil");

    self = [super init];

    if (self)
    {
        _format = [format copy];
        _tokenPropertyMap = @{
            @"${useralias}" : @"alias",
            @"${firstname}" : @"firstname",
            @"${lastname}" : @"lastname",
            @"${nickname}" : @"nickname",
            @"${email}" : @"email",
        };
    }

    return self;
}

- (nullable NSString *)stringForObjectValue:(id)obj
{
    if ([obj isKindOfClass:NSArray.class])
        return [self stringForUserDisplayItems:obj];

    if ([obj isKindOfClass:BDKUserDetails.class])
        return [self stringForUserDisplayItem:(BDKUserDetails*) obj];

    return nil;
}

- (NSString *)stringForUserDisplayItems:(NSArray<BDKUserDetails *> *)items
{
    NSMutableArray<NSString *> *strings = [NSMutableArray array];
    for (BDKUserDetails *item in items)
    {
        NSString *string = [self stringForObjectValue:item];

        if (string != nil)
            [strings addObject:string];
    }

    return [strings componentsJoinedByString:@", "];
}

- (nullable NSString *)stringForUserDisplayItem:(BDKUserDetails *)item
{
    NSString *result = [self.format copy];
    NSArray<NSString *>*tokens = [self matchingTokensInFormat];

    for (NSString *token in tokens)
    {
        NSString *propertyName = self.tokenPropertyMap[[token lowercaseString]];
        if (propertyName != nil)
        {
            NSString *propertyValue = [item valueForKey:propertyName] ?: [NSString string];
            result = [result stringByReplacingOccurrencesOfString:token withString:propertyValue];
        }
    }

    NSString *whitespaceTrimmed = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (whitespaceTrimmed == nil || [whitespaceTrimmed isEqualToString:[NSString string]])
        return item.alias;
    return whitespaceTrimmed;
}

- (NSArray<NSString *>*)matchingTokensInFormat
{
    NSString *pattern = @"\\$\\{([\\w]+)\\}";
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    if (error)
    {
        return @[];
    }

    NSArray<NSTextCheckingResult*>* matches = [regexp matchesInString:self.format options:0 range:NSMakeRange(0, self.format.length)];

    NSMutableArray *tokens = [NSMutableArray array];
    for (NSTextCheckingResult* match in matches)
    {
        if (match.range.location != NSNotFound)
        {
            NSString *token = [self.format substringWithRange:match.range];
            [tokens addObject:token];
        }
    }
    return tokens;
}

@end
