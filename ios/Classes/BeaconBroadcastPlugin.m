#import "BeaconBroadcastPlugin.h"
#import <beacon_broadcast/beacon_broadcast-Swift.h>

@implementation BeaconBroadcastPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBeaconBroadcastPlugin registerWithRegistrar:registrar];
}
@end
