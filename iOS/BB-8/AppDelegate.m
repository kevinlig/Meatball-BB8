//
//  AppDelegate.m
//  BB-8
//
//  Created by Kevin Li on 2/28/16.
//  Copyright © 2016 Kevin Li. All rights reserved.
//

#import "AppDelegate.h"
#import "PebbleKit/PebbleKit.h"


@interface AppDelegate () <PBPebbleCentralDelegate>

@property (weak, nonatomic) PBWatch *watch;
@property (weak, nonatomic) PBPebbleCentral *central;

@property int soundIndex;

@property (nonatomic, strong) NSDate *lastTrigger;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.soundIndex = 1;
    
    // Set the delegate to receive PebbleKit events
    self.central = [PBPebbleCentral defaultCentral];
    self.central.delegate = self;
    
    // Register UUID
    self.central.appUUID = [[NSUUID alloc]initWithUUIDString:@"276acda0-8e51-4e2f-9d05-aed3a3a71b18"];
    
    // Begin connection
    [self.central run];
    
    // set up notifications
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)playSound {
    
    // don't trigger the sound effect more than once every 5 seconds
    if (!self.lastTrigger || (self.lastTrigger && fabs([self.lastTrigger timeIntervalSinceNow]) >= 5.0f)) {
        
        // rotate through the five available sound effects
        NSString *soundName = [NSString stringWithFormat:@"bb8_0%i.aif", self.soundIndex];
        
        // clear out old notifications from this application to keep the lock screen clear
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
        // delay the notification by 300ms so the above code doesn't clear out this notification too
        NSDate *playDate = [NSDate dateWithTimeIntervalSinceNow:0.3f];
        
        self.lastTrigger = [NSDate date];
        
        // set up the local notification
        UILocalNotification *notify = [[UILocalNotification alloc]init];
        notify.alertBody = @"Bleep blorp";
        notify.soundName = soundName;
        notify.fireDate = playDate;
        [[UIApplication sharedApplication]scheduleLocalNotification:notify];
        
        // iterate to the next sound file
        self.soundIndex++;
        if (self.soundIndex > 5) {
            self.soundIndex = 1;
        }
        
    }

}

- (void)registerCallbacks {
    
    // app is ready to receive commands from Pebble, update the view controller label
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ready" object:nil];
    
    // checking if app messages are supported on the watch
    [self.watch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if (isAppMessagesSupported) {
            // Tell the user using the Label
           NSLog(@"AppMessage is supported!");
        } else {
            NSLog(@"AppMessage is NOT supported!");
        }
    }];
    
    // Keep a weak reference to self to prevent it staying around forever
    __weak typeof(self) welf = self;
    
    // callback for when Pebble sends a command
    [self.watch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
    
        
        
        __strong typeof(welf) sself = welf;
        if (!sself) {
            // self has been destroyed
            return NO;
        }
        
        // received a trigger to play a BB-8 sound effect
        if ([[update objectForKey:@(1)]isEqualToNumber:@(0)]) {
            [self playSound];
        }
        
        return YES;
    }];
    

}

#pragma mark - Pebble delegate
- (void)pebbleCentral:(PBPebbleCentral *)central watchDidConnect:(PBWatch *)watch isNew:(BOOL)isNew {    
    if (self.watch) {
        [self registerCallbacks];
        return;
    }
    self.watch = watch;
    
    [self registerCallbacks];
}

- (void)pebbleCentral:(PBPebbleCentral *)central watchDidDisconnect:(PBWatch *)watch {
    // Only remove reference if it was the current active watch
    if (self.watch == watch) {
        self.watch = nil;
    }
}

@end
