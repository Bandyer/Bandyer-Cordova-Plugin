// To parse this JSON:
//
//   NSError *error;
//   BCPBandyerEvents *events = BCPBandyerEventsFromJSON(json, NSUTF8Encoding, &error);

#import <Foundation/Foundation.h>

@class BCPBandyerEvents;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Boxed enums

/// This enum defines all the events that may be handled
/// <br/>
/// <br/>
/// You can listen to these events via [[BandyerPlugin.on]]
@interface BCPBandyerEvents : NSObject
@property (nonatomic, readonly, copy) NSString *value;
+ (instancetype _Nullable)withValue:(NSString *)value;
+ (BCPBandyerEvents *)callError;
+ (BCPBandyerEvents *)callModuleStatusChanged;
+ (BCPBandyerEvents *)chatError;
+ (BCPBandyerEvents *)chatModuleStatusChanged;
+ (BCPBandyerEvents *)iOSVoipPushTokenInvalidated;
+ (BCPBandyerEvents *)iOSVoipPushTokenUpdated;
+ (BCPBandyerEvents *)setupError;
@end


#pragma mark - Top-level marshaling functions

BCPBandyerEvents *_Nullable BCPBandyerEventsFromData(NSData *data, NSError **error);
BCPBandyerEvents *_Nullable BCPBandyerEventsFromJSON(NSString *json, NSStringEncoding encoding, NSError **error);
NSData           *_Nullable BCPBandyerEventsToData(BCPBandyerEvents *events, NSError **error);
NSString         *_Nullable BCPBandyerEventsToJSON(BCPBandyerEvents *events, NSStringEncoding encoding, NSError **error);

#pragma mark - Object interfaces

NS_ASSUME_NONNULL_END
