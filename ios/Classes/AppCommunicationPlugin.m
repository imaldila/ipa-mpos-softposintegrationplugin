#import "AppCommunicationPlugin.h"
#if __has_include(<app_communication_plugin/app_communication_plugin-Swift.h>)
#import <app_communication_plugin/app_communication_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "app_communication_plugin-Swift.h"
#endif

@implementation AppCommunicationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAppCommunicationPlugin registerWithRegistrar:registrar];
}
@end
