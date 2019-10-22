#import "FlutterSobotPlugin.h"
#import <flutter_sobot/flutter_sobot-Swift.h>

@implementation FlutterSobotPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterSobotPlugin registerWithRegistrar:registrar];
}
@end
