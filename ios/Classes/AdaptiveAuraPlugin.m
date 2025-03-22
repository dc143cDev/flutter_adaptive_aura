#import "AdaptiveAuraPlugin.h"
#if __has_include(<adaptive_aura/adaptive_aura-Swift.h>)
#import <adaptive_aura/adaptive_aura-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "adaptive_aura-Swift.h"
#endif

@implementation AdaptiveAuraPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAdaptiveAuraPlugin registerWithRegistrar:registrar];
}
@end 