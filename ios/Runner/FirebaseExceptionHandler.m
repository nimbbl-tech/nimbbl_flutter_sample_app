//
//  FirebaseExceptionHandler.m
//  Helper to safely register Flutter plugins when Firebase is disabled
//
//  This file registers all plugins EXCEPT Firebase plugins when Firebase is disabled.
//  This prevents Firebase from initializing with invalid configuration.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "GeneratedPluginRegistrant.h"

// Import all plugins (same as GeneratedPluginRegistrant.m)
#if __has_include(<firebase_analytics/FirebaseAnalyticsPlugin.h>)
#import <firebase_analytics/FirebaseAnalyticsPlugin.h>
#else
@import firebase_analytics;
#endif

#if __has_include(<firebase_core/FLTFirebaseCorePlugin.h>)
#import <firebase_core/FLTFirebaseCorePlugin.h>
#else
@import firebase_core;
#endif

#if __has_include(<firebase_crashlytics/FLTFirebaseCrashlyticsPlugin.h>)
#import <firebase_crashlytics/FLTFirebaseCrashlyticsPlugin.h>
#else
@import firebase_crashlytics;
#endif

#if __has_include(<fluttertoast/FluttertoastPlugin.h>)
#import <fluttertoast/FluttertoastPlugin.h>
#else
@import fluttertoast;
#endif

#if __has_include(<nimbbl_mobile_kit_flutter_webview_sdk/NimbblMobileKitFlutterWebviewSdkPlugin.h>)
#import <nimbbl_mobile_kit_flutter_webview_sdk/NimbblMobileKitFlutterWebviewSdkPlugin.h>
#else
@import nimbbl_mobile_kit_flutter_webview_sdk;
#endif

#if __has_include(<path_provider_foundation/PathProviderPlugin.h>)
#import <path_provider_foundation/PathProviderPlugin.h>
#else
@import path_provider_foundation;
#endif

#if __has_include(<shared_preferences_foundation/SharedPreferencesPlugin.h>)
#import <shared_preferences_foundation/SharedPreferencesPlugin.h>
#else
@import shared_preferences_foundation;
#endif

#if __has_include(<url_launcher_ios/URLLauncherPlugin.h>)
#import <url_launcher_ios/URLLauncherPlugin.h>
#else
@import url_launcher_ios;
#endif

void registerPluginsSafely(id registrar) {
    NSObject<FlutterPluginRegistry> *registry = (NSObject<FlutterPluginRegistry>*)registrar;
    
    NSLog(@"⚠️ Firebase is disabled. Registering plugins without Firebase...");
    
    // Register all plugins EXCEPT Firebase plugins
    // This prevents Firebase from initializing with invalid configuration
    // NOTE: When adding new plugins, add them here too (but skip Firebase plugins)
    
    // Skip Firebase plugins (they would crash with invalid config):
    // [FirebaseAnalyticsPlugin registerWithRegistrar:...] - SKIPPED
    // [FLTFirebaseCorePlugin registerWithRegistrar:...] - SKIPPED (this one causes the crash)
    // [FLTFirebaseCrashlyticsPlugin registerWithRegistrar:...] - SKIPPED
    
    // Register non-Firebase plugins:
    @try {
        [FluttertoastPlugin registerWithRegistrar:[registry registrarForPlugin:@"FluttertoastPlugin"]];
    } @catch (NSException *e) {
        NSLog(@"Warning: Failed to register FluttertoastPlugin: %@", e);
    }
    
    @try {
        [NimbblMobileKitFlutterWebviewSdkPlugin registerWithRegistrar:[registry registrarForPlugin:@"NimbblMobileKitFlutterWebviewSdkPlugin"]];
    } @catch (NSException *e) {
        NSLog(@"Warning: Failed to register NimbblMobileKitFlutterWebviewSdkPlugin: %@", e);
    }
    
    @try {
        [PathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"PathProviderPlugin"]];
    } @catch (NSException *e) {
        NSLog(@"Warning: Failed to register PathProviderPlugin: %@", e);
    }
    
    @try {
        [SharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"SharedPreferencesPlugin"]];
    } @catch (NSException *e) {
        NSLog(@"Warning: Failed to register SharedPreferencesPlugin: %@", e);
    }
    
    @try {
        [URLLauncherPlugin registerWithRegistrar:[registry registrarForPlugin:@"URLLauncherPlugin"]];
    } @catch (NSException *e) {
        NSLog(@"Warning: Failed to register URLLauncherPlugin: %@", e);
    }
    
    NSLog(@"✅ Non-Firebase plugins registered successfully. Firebase plugins skipped.");
    NSLog(@"💡 TIP: When adding new plugins, update this function to include them (skip Firebase plugins).");
}
