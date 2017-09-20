#import "MyCordovaPlugin.h"

#import <Cordova/CDVAvailability.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>

@implementation MyCordovaPlugin

- (void)pluginInitialize {
}

- (void)echo:(CDVInvokedUrlCommand *)command {
  NSString* phrase = [command.arguments objectAtIndex:0];
  NSLog(@"%@", phrase);
}

- (void)getDate:(CDVInvokedUrlCommand *)command {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
  [dateFormatter setLocale:enUSPOSIXLocale];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];

  NSDate *now = [NSDate date];
  NSString *iso8601String = [dateFormatter stringFromDate:now];

  CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:iso8601String];
  [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

-(void)login:(CDVInvokedUrlCommand *)command{
  [[KOSession sharedSession] close];

  [[KOSession sharedSession] openWithCompletionHandler:^(NSError *error) {
      if ([[KOSession sharedSession] isOpen]) {
        [KOSessionTask meTaskWithCompletionHandler:^(KOUser* result, NSError *error) {
                CDVPluginResult* pluginResult = nil;
			    if (result) {
			        // success
			        NSLog(@"userId=%@", result.ID);
			        NSLog(@"nickName=%@", [result propertyForKey:@"nickname"]);
                    NSLog(@"profileImage=%@", [result propertyForKey:@"profile_image"]);
			        
			        NSDictionary *userSession = @{
										  @"id": result.ID,
										  @"nickname": [result propertyForKey:@"nickname"],
										  @"profile_image": [result propertyForKey:@"profile_image"]};
					pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userSession];
			    } else {
			        // failed
			        NSLog(@"login session failed.");
			        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
			    }
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
			  }];
      } else {
          // failed
          NSLog(@"login failed.");
      }
  }];
}

- (void)logout:(CDVInvokedUrlCommand *)command
{
	[[KOSession sharedSession] logoutAndCloseWithCompletionHandler:^(BOOL success, NSError *error) {
	    if (success) {
	        // logout success.
            NSLog(@"Successful logout.");
	    } else {
	        // failed
	        NSLog(@"failed to logout.");
	    }
	}];
	CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end
