#import "BCPBandyerEvents.h"

#define λ(decl, expr) (^(decl) { return (expr); })

static id NSNullify(id _Nullable x) {
    return (x == nil || x == NSNull.null) ? NSNull.null : x;
}

NS_ASSUME_NONNULL_BEGIN

@implementation BCPBandyerEvents
+ (NSDictionary<NSString *, BCPBandyerEvents *> *)values
{
    static NSDictionary<NSString *, BCPBandyerEvents *> *values;
    return values = values ? values : @{
        @"callError": [[BCPBandyerEvents alloc] initWithValue:@"callError"],
        @"callModuleStatusChanged": [[BCPBandyerEvents alloc] initWithValue:@"callModuleStatusChanged"],
        @"chatError": [[BCPBandyerEvents alloc] initWithValue:@"chatError"],
        @"chatModuleStatusChanged": [[BCPBandyerEvents alloc] initWithValue:@"chatModuleStatusChanged"],
    };
}

+ (BCPBandyerEvents *)callError { return BCPBandyerEvents.values[@"callError"]; }
+ (BCPBandyerEvents *)callModuleStatusChanged { return BCPBandyerEvents.values[@"callModuleStatusChanged"]; }
+ (BCPBandyerEvents *)chatError { return BCPBandyerEvents.values[@"chatError"]; }
+ (BCPBandyerEvents *)chatModuleStatusChanged { return BCPBandyerEvents.values[@"chatModuleStatusChanged"]; }

+ (instancetype _Nullable)withValue:(NSString *)value
{
    return BCPBandyerEvents.values[value];
}

- (instancetype)initWithValue:(NSString *)value
{
    if (self = [super init]) _value = value;
    return self;
}

- (NSUInteger)hash { return _value.hash; }
@end

#pragma mark - JSON serialization

BCPBandyerEvents *_Nullable BCPBandyerEventsFromData(NSData *data, NSError **error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        return *error ? nil : [BCPBandyerEvents withValue:json];
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

BCPBandyerEvents *_Nullable BCPBandyerEventsFromJSON(NSString *json, NSStringEncoding encoding, NSError **error)
{
    return BCPBandyerEventsFromData([json dataUsingEncoding:encoding], error);
}

NSData *_Nullable BCPBandyerEventsToData(BCPBandyerEvents *events, NSError **error)
{
    @try {
        id json = [events value];
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

NSString *_Nullable BCPBandyerEventsToJSON(BCPBandyerEvents *events, NSStringEncoding encoding, NSError **error)
{
    NSData *data = BCPBandyerEventsToData(events, error);
    return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
}

NS_ASSUME_NONNULL_END
