//
//  AppDelegate.m
//  Disher
//
//  Created by Bienn Viquiera on 7/5/22.
//

#import "AppDelegate.h"
@import Parse;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Use API Keys in Keys.plist
    NSString *clientIDPath = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *clientIDDict = [NSDictionary dictionaryWithContentsOfFile: clientIDPath];
    NSString *clientIDKey = [clientIDDict objectForKey: @"parse_clientID"];
    
    NSString *appIDPath = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *appIDDict = [NSDictionary dictionaryWithContentsOfFile: appIDPath];
    NSString *appIDKey = [appIDDict objectForKey: @"parse_appID"];
    // Initialize Parse
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = appIDKey;
        configuration.clientKey = clientIDKey;
        configuration.server = @"https://parseapi.back4app.com";
    }]];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

@end
