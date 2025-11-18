//
//  FirebaseExceptionHandler.h
//  Helper to safely register Flutter plugins when Firebase is disabled
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

void registerPluginsSafely(id registrar);
