//
//  NotificationService.m
//  NotificaionService
//
//  Created by Anurodh Pokharel on 9/16/19.
//  Copyright © 2019 Monal.im. All rights reserved.
//

#import "NotificationService.h"
#import "MLConstants.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

static void logException(NSException* exception)
{
    DDLogError(@"*** CRASH: %@", exception);
    DDLogError(@"*** Stack Trace: %@", [exception callStackSymbols]);
    [DDLog flushLog];
}

@implementation NotificationService

+(void) initialize
{
    DDDispatchQueueLogFormatter* formatter = [[DDDispatchQueueLogFormatter alloc] init];
    [[DDOSLogger sharedInstance] setLogFormatter:formatter];
    [DDLog addLogger:[DDOSLogger sharedInstance]];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL* containerUrl = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.monal"];
    id<DDLogFileManager> logFileManager = [[MLLogFileManager alloc] initWithLogsDirectory:[containerUrl path]];
    DDFileLogger* fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    [fileLogger setLogFormatter:formatter];
    fileLogger.rollingFrequency = 60 * 60 * 24;    // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 5;
    fileLogger.maximumFileSize=1024 * 1024 * 64;
    [DDLog addLogger:fileLogger];
    DDLogInfo(@"*** Logfile dir: %@", [containerUrl path]);
    
    DDLogInfo(@"*** notification handler INIT");
    
    //log unhandled exceptions
    NSSetUncaughtExceptionHandler(&logException);
}

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    DDLogInfo(@"*** notification handler called");
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = @"New Message"; //[NSString stringWithFormat:@"New Message %@", self.bestAttemptContent.title];
    self.bestAttemptContent.body = @"Open app to view";
    self.bestAttemptContent.badge = @1;
    //self.contentHandler(self.bestAttemptContent);
    
    NSString* idval = [[NSUUID UUID] UUIDString];
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = @"Notification incoming";
    content.body = @"Please wait 30 seconds to see it...";
    content.sound = [UNNotificationSound defaultSound];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNNotificationRequest* new_request = [UNNotificationRequest requestWithIdentifier:idval content:content trigger:nil];
    [center addNotificationRequest:new_request withCompletionHandler:^(NSError * _Nullable error) {
        DDLogInfo(@"*** second notification request completed: %@", error);
    }];
    
    [[MLXMPPManager sharedInstance] connectIfNecessary];
}

- (void)serviceExtensionTimeWillExpire {
    DDLogInfo(@"*** notification handler expired");
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
