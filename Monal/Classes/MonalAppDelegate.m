//
//  SworIMAppDelegate.m
//  SworIM
//
//  Created by Anurodh Pokharel on 11/16/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "MonalAppDelegate.h"



// tab bar
#import "ContactsViewController.h"
#import "ActiveChatsViewController.h"
#import "SettingsViewController.h"
#import "AccountsViewController.h"
#import "ChatLogsViewController.h"
#import "GroupChatViewController.h"
#import "SearchUsersViewController.h"
#import "LogViewController.h"
#import "HelpViewController.h"
#import "AboutViewController.h"
#import "MLNotificationManager.h"

#import <Crashlytics/Crashlytics.h>



//xmpp
#import "MLXMPPManager.h"


static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation MonalAppDelegate
{
    UITabBarItem* _activeTab;
}

-(void) createRootInterface
{
    self.window=[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
   // self.window.screen=[UIScreen mainScreen];
    
    _tabBarController=[[MLTabBarController alloc] init];
    ContactsViewController* contactsVC = [[ContactsViewController alloc] init];
    [MLXMPPManager sharedInstance].contactVC=contactsVC;
    contactsVC.presentationTabBarController=_tabBarController; 
    
    UIBarStyle barColor=UIBarStyleBlackOpaque;
    
     if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
         barColor=UIBarStyleDefault;
    
    ActiveChatsViewController* activeChatsVC = [[ActiveChatsViewController alloc] init];
    UINavigationController* activeChatNav=[[UINavigationController alloc] initWithRootViewController:activeChatsVC];
    activeChatNav.navigationBar.barStyle=barColor;
    activeChatNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Active Chats",@"") image:[UIImage imageNamed:@"active"] tag:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnread) name:UIApplicationWillEnterForegroundNotification object:nil];
    _activeTab=activeChatNav.tabBarItem;
    
    
    SettingsViewController* settingsVC = [[SettingsViewController alloc] init];
    UINavigationController* settingsNav=[[UINavigationController alloc] initWithRootViewController:settingsVC];
    settingsNav.navigationBar.barStyle=barColor;
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Settings",@"") image:[UIImage imageNamed:@"status"] tag:0];
    
    AccountsViewController* accountsVC = [[AccountsViewController alloc] init];
    UINavigationController* accountsNav=[[UINavigationController alloc] initWithRootViewController:accountsVC];
    accountsNav.navigationBar.barStyle=barColor;
    accountsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Accounts",@"") image:[UIImage imageNamed:@"accounts"] tag:0];
    
    ChatLogsViewController* chatLogVC = [[ChatLogsViewController alloc] init];
    UINavigationController* chatLogNav=[[UINavigationController alloc] initWithRootViewController:chatLogVC];
    chatLogNav.navigationBar.barStyle=barColor;
    chatLogNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Chat Logs",@"") image:[UIImage imageNamed:@"chatlog"] tag:0];
    
//    SearchUsersViewController* searchUsersVC = [[SearchUsersViewController alloc] init];
//    UINavigationController* searchUsersNav=[[UINavigationController alloc] initWithRootViewController:searchUsersVC];
//    searchUsersNav.navigationBar.barStyle=barColor;
//    searchUsersNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Search Users",@"") image:[UIImage imageNamed:@"Search"] tag:0];
//    
    GroupChatViewController* groupChatVC = [[GroupChatViewController alloc] init];
    UINavigationController* groupChatNav=[[UINavigationController alloc] initWithRootViewController:groupChatVC];
    groupChatNav.navigationBar.barStyle=barColor;
    groupChatNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Group Chat",@"") image:[UIImage imageNamed:@"joingroup"] tag:0];
    
    HelpViewController* helpVC = [[HelpViewController alloc] init];
    UINavigationController* helpNav=[[UINavigationController alloc] initWithRootViewController:helpVC];
    helpNav.navigationBar.barStyle=barColor;
    helpNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Help",@"") image:[UIImage imageNamed:@"help"] tag:0];
    
    AboutViewController* aboutVC = [[AboutViewController alloc] init];
    UINavigationController* aboutNav=[[UINavigationController alloc] initWithRootViewController:aboutVC];
    aboutNav.navigationBar.barStyle=barColor;
    aboutNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"About",@"") image:[UIImage imageNamed:@"about"] tag:0];
    
#ifdef DEBUG
    LogViewController* logVC = [[LogViewController alloc] init];
    UINavigationController* logNav=[[UINavigationController alloc] initWithRootViewController:logVC];
    logNav.navigationBar.barStyle=barColor;
    logNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Log",@"") image:nil tag:0];
#endif
    
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        
        _chatNav=[[UINavigationController alloc] initWithRootViewController:contactsVC];
        _chatNav.navigationBar.barStyle=barColor;
        contactsVC.currentNavController=_chatNav;
        _chatNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Contacts",@"") image:[UIImage imageNamed:@"Buddies"] tag:0];
        
    
        _tabBarController.viewControllers=[NSArray arrayWithObjects:_chatNav,activeChatNav, settingsNav,  accountsNav, chatLogNav, groupChatNav, //searchUsersNav,
                                           helpNav, aboutNav,
#ifdef DEBUG
                                           logNav,
#endif
                                           nil];
        
        self.window.rootViewController=_tabBarController;
        
    }
    else
    {
        
        //this is a dummy nav controller not really used for anything
        UINavigationController* navigationControllerContacts=[[UINavigationController alloc] initWithRootViewController:contactsVC];
        navigationControllerContacts.navigationBar.barStyle=barColor;
        
        _chatNav=activeChatNav;
        contactsVC.currentNavController=_chatNav;
        _splitViewController=[[UISplitViewController alloc] init];
        self.window.rootViewController=_splitViewController;
        
        _tabBarController.viewControllers=[NSArray arrayWithObjects: activeChatNav,  settingsNav, accountsNav, chatLogNav, groupChatNav,
                                        //   searchU∫sersNav,
                                           helpNav, aboutNav,
#ifdef DEBUG
                                           logNav,
#endif
                                           nil];
        
        _splitViewController.viewControllers=[NSArray arrayWithObjects:navigationControllerContacts, _tabBarController,nil];
        _splitViewController.delegate=self;
    }
    
    _chatNav.navigationBar.barStyle=barColor;
    _tabBarController.moreNavigationController.navigationBar.barStyle=barColor;
    
    [self.window makeKeyAndVisible];
}


-(void) updateUnread
{
    //make sure unread badge matches application badge
    
    int unread= [[DataLayer sharedInstance] countUnreadMessages];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(unread>0)
        {
            _activeTab.badgeValue=[NSString stringWithFormat:@"%d",unread];
            [UIApplication sharedApplication].applicationIconBadgeNumber =unread;
        }
        else
        {
            _activeTab.badgeValue=nil;
             [UIApplication sharedApplication].applicationIconBadgeNumber =0;
        }
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
#ifdef  DEBUG
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    self.fileLogger = [[DDFileLogger alloc] init];
    self.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 5;
    self.fileLogger.maximumFileSize=1024 * 500;
    [DDLog addLogger:self.fileLogger];
#endif
    
    
    [self createRootInterface];

    //rating
    [Appirater setAppId:@"317711500"];
    [Appirater setDaysUntilPrompt:5];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:5];
    [Appirater setTimeBeforeReminding:2];
    //[Appirater setDebug:YES];
    [Appirater appLaunched:YES];
    
    [MLNotificationManager sharedInstance].window=self.window;
    
    if([[UIApplication sharedApplication] applicationState]==UIApplicationStateBackground)
    {
       _backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
            
            DDLogVerbose(@"XMPP manager bgtask took too long. closing");
            [[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
            _backgroundTask=UIBackgroundTaskInvalid;
            
        }];
        
        if (_backgroundTask != UIBackgroundTaskInvalid) {
             DDLogVerbose(@"XMPP manager connecting in background");
                [[MLXMPPManager sharedInstance] connectIfNecessary];
              DDLogVerbose(@"XMPP manager completed background task");
            [[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
            _backgroundTask=UIBackgroundTaskInvalid;

        }
    }
    else
    {
    // should any accounts connect?
    [[MLXMPPManager sharedInstance] connectIfNecessary];
    }
    

    
    [Crashlytics startWithAPIKey:@"6e807cf86986312a050437809e762656b44b197c"];
  //  [Crashlytics sharedInstance].debugMode = YES;
  // [[Crashlytics sharedInstance] crash];
    
    
    //update logs if needed
    if(! [[NSUserDefaults standardUserDefaults] boolForKey:@"Logging"])
    {
        [[DataLayer sharedInstance] messageHistoryCleanAll];
    }
    return YES;
}

-(void) applicationDidBecomeActive:(UIApplication *)application
{
  //  [UIApplication sharedApplication].applicationIconBadgeNumber=0;
}

#pragma mark notifiction 
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{

}



#pragma mark backgrounding
- (void)applicationWillEnterForeground:(UIApplication *)application
{
     if (_backgroundTask != UIBackgroundTaskInvalid) {
          DDLogVerbose(@"entering foreground as connect bg task is running");
     }
    
      DDLogVerbose(@"Entering FG");
}

-(void) applicationDidEnterBackground:(UIApplication *)application
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive) {
        DDLogVerbose(@"Screen lock");
    } else if (state == UIApplicationStateBackground) {
        DDLogVerbose(@"Entering BG");
    }
}

-(void)applicationWillTerminate:(UIApplication *)application
{
    
       [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark splitview controller delegate
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

@end

