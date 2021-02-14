#import "TapkeyFlutterPlugin2Plugin.h"
#if __has_include(<tapkey_flutter_plugin2/tapkey_flutter_plugin2-Swift.h>)
#import <tapkey_flutter_plugin2/tapkey_flutter_plugin2-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tapkey_flutter_plugin2-Swift.h"
#endif

@implementation TapkeyFlutterPlugin2Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTapkeyFlutterPlugin2Plugin registerWithRegistrar:registrar];
}
@end
