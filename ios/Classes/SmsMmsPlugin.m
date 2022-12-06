#import "SmsMmsPlugin.h"
#if __has_include(<sms_mms/sms_mms-Swift.h>)
#import <sms_mms/sms_mms-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "sms_mms-Swift.h"
#endif

@implementation SmsMmsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSmsMmsPlugin registerWithRegistrar:registrar];
}
@end
