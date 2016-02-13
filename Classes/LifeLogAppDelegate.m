//
//  LifeLogAppDelegate.m
//  LifeLog
//
//  Created by cliff on 11. 3. 9..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import "LifeLogAppDelegate.h"
#import "DailyListViewController.h"
#import "AddViewController.h"
#import "Note.h"
#import "Utils.h"
#import "Global.h"

@interface LifeLogAppDelegate ()
- (void)createEditableCopyOfSettingsIfNeeded;
- (void)addAdMob;
- (void)addCaulyAd;
@end

@implementation LifeLogAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize isNotif = __isNotif;
@synthesize keys = __keys;
@synthesize feelDict = __feelDict;
@synthesize yearKeys = __yearKeys;
@synthesize monthKeys = __monthKeys;
@synthesize facebook = __facebook;
@synthesize dataSyncService = __dataSyncService;
@synthesize settingsBundle = __settingsBundle;
@synthesize facebookBundle = __facebookBundle;
@synthesize userInfoBundle = __userInfoBundle;
@synthesize deviceInfoBundle = __deviceInfoBundle;
@synthesize syncLogInfoBundle = __syncLogInfoBundle;
@synthesize gadbannerView = _gadbannerView;

#pragma mark - Application lifecycle

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"call");
    
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
	NSLog(@"call");
    
    [_window release];
	[_tabBarController release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
	[__keys release];
	[__feelDict release];
    [__yearKeys release];
    [__monthKeys release];
    [__dataSyncService release];
    [__facebook release];
    [__settingsBundle release];
    [__facebookBundle release];
    [__userInfoBundle release];
    [__deviceInfoBundle release];
    [__syncLogInfoBundle release];
    self.gadbannerView.delegate = nil;
    [_gadbannerView release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	NSLog(@"call");

    // Add button on tabbar
    UIButton *_addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addButton setFrame:CGRectMake(128.0, 0.0, 64, 48)];
	[_addButton setImage:[UIImage imageNamed:@"write_icon.png"] forState:UIControlStateNormal];
	[_addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBarController.tabBar addSubview:_addButton];
    
    // Main view
    self.window.rootViewController = self.tabBarController;
//	[self.window addSubview:self.tabBarController.view];
    [self.window makeKeyAndVisible];
    
	// Initialize feel picker data
	self.keys = [NSArray arrayWithObjects:@"12", @"11", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2", @"1", nil];
	self.feelDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Happy", @"Good", @"Glad", @"Nice", @"Great", @"So so", @"Sad", @"Angry", @"Gloomy", @"Boring", @"Lonely", @"Painful", nil] forKeys:self.keys];
    
	// Initialize month picker data
    self.yearKeys = [NSArray arrayWithObjects:@"2010", @"2011", @"2012", @"2013", @"2014", @"2015", @"2016", @"2017", @"2018", @"2019", @"2020", nil];
    self.monthKeys = [NSArray arrayWithObjects:@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12", nil];
    
    // Copy plist
    [self createEditableCopyOfSettingsIfNeeded];
    
    // Load Setting plist
    NSURL *_storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:@"Settings.plist"];
    self.settingsBundle = [[NSMutableDictionary alloc] initWithContentsOfURL:_storeURL];
    _storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:@"Facebook.plist"];
    self.facebookBundle = [[NSMutableDictionary alloc] initWithContentsOfURL:_storeURL];
    _storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:@"UserInfo.plist"];
    self.userInfoBundle = [[NSMutableDictionary alloc] initWithContentsOfURL:_storeURL];
    _storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:@"DeviceInfo.plist"];
    self.deviceInfoBundle = [[NSMutableDictionary alloc] initWithContentsOfURL:_storeURL];
    _storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:@"SyncLogInfo.plist"];
    self.syncLogInfoBundle = [[NSMutableDictionary alloc] initWithContentsOfURL:_storeURL];
    
    // Radom Seed Setting
    srandom(time(NULL));
    
    // Initialize Ad
    // 지역 체크!
    NSString   *language = [[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode];
    NSLog(@"The device's specified language is %@", language);
    NSString   *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    NSLog(@"The device's specified countryCode is %@", countryCode);
	
	// embed AD
    if ([countryCode isEqualToString:@"KR"]) {
        [self addCaulyAd];
        self.gadbannerView = nil;
    } else {
        [self addAdMob];
    }

    // End of Initialize
    
    // FBConnect
    self.facebook = [[Facebook alloc] initWithAppId:FACEBOOK_APP_ID];
    [self.facebook setSessionDelegate:self];
    if (self.facebookBundle == nil || [[self.facebookBundle objectForKey:@"id"] isEqualToString:@""]) { // TODO: Expire Date 체크 요망!
        // 로그인 되어 있지 않은 경우
        
        // Dialog Version - Facebook oauth 요청
//        NSMutableDictionary *_params = [NSMutableDictionary dictionary];
//        [_params setObject:FACEBOOK_APP_ID forKey:@"client_id"];
//        [_params setObject:@"publish_stream,user_photos,email" forKey:@"scope"];
//        [self.facebook dialog:@"oauth" andParams:_params andDelegate:self];
        
        // SSO Version - Facebook login
        NSArray *_permissions =  [NSArray arrayWithObjects:@"publish_stream", @"user_photos", @"email",nil];
        [self.facebook authorize:_permissions delegate:self];
    } else {
        // 로그인 되어 있는 경우
        [self.facebook setAccessToken:[self.facebookBundle objectForKey:@"accessToken"]];
        [self.facebook setExpirationDate:[self.facebookBundle objectForKey:@"expirationDate"]];
        
        if ([[[self.settingsBundle objectForKey:@"Sync"] objectForKey:@"Sync on startup"] boolValue]) {
            [self syncServer:SYNC_METHOD_LIST];
        }
    }
    
    // Received Notification
    UILocalNotification *__notif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (__notif != nil) {
        self.isNotif = YES;
    } else {
        self.isNotif = NO;
    }
//    __notif = [[UILocalNotification alloc] init];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	NSLog(@"call");
    
    return [self.facebook handleOpenURL:url];
}

-(void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	NSLog(@"call");
    
    [Utils showAlert:NSLocalizedString(@"Confirm", nil) withTitle:NSLocalizedString(@"Notice", nil) andMessage:NSLocalizedString(@"WriteYourLifeLog", nil)];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	NSLog(@"call");
    
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	NSLog(@"call");
    
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSLog(@"call");
    
    /*
     Called as part of the transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSLog(@"call");
    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	NSLog(@"call");
    
    [self saveContext];
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	NSLog(@"call");
    
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
        [__managedObjectContext setUndoManager:nil];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
	NSLog(@"call");
    
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"LifeLog" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	NSLog(@"call");
    
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:@"LifeLog.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

- (void)saveContext {
	NSLog(@"call");
    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. 
             You should not use this function in a shipping application, although it may be useful during development. 
             If it is not possible to recover from the error, display an alert panel that instructs the user to quit 
             the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}    

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
	NSLog(@"call");
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationLibraryDirectory {
	NSLog(@"call");
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Setting plist

- (void)createEditableCopyOfSettingsIfNeeded {
	NSLog(@"call");
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
	NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:@"Settings.plist"];
	
	// Documents 폴더에 DB파일이 존재하는지 체크
	BOOL dbexists = [fileManager fileExistsAtPath:writablePath];
	if (!dbexists) {
    
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Settings.plist"];
		
		// 없으면 Resource 폴더의 원본을 복사
		NSError *error;
        // 파일 강제 복사시 아래 코드 사용
       [fileManager removeItemAtPath:writablePath error:&error];
		BOOL success = [fileManager copyItemAtPath:defaultDBPath toPath:writablePath error:&error];
		if (!success) {
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		}
	}
}

#pragma mark - TabBar controller delegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
	NSLog(@"call");
    
    UIViewController *selected = [tabBarController selectedViewController];
    if ([selected isEqual:viewController]) {
        return NO;
    }
    
    if (viewController == [tabBarController.viewControllers objectAtIndex:2]) {
        return NO;
    }
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	NSLog(@"call");
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"call");
    
    exit(0);
}

#pragma mark - FBSession delegate

- (void)fbDidLogin {
	NSLog(@"call");
    
    [self.facebook requestWithGraphPath:@"me" andDelegate:self];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"call");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                    message:NSLocalizedString(@"FacebookLogInFail", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

- (void)fbDidLogout {
	NSLog(@"call");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                    message:NSLocalizedString(@"RestartMsg", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

#pragma mark - FBRequest delegate

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"call");
    
}

- (void)request:(FBRequest *)request didLoad:(id)result {
	NSLog(@"call");

    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];
    }

    NSLog(@"result: %@", result);
    
    if (![result objectForKey:@"name"]) {
        //NSLog(@"Other request");
        
        [Utils showAlert:NSLocalizedString(@"Confirm", nil) withTitle:NSLocalizedString(@"Notice", nil) andMessage:NSLocalizedString(@"PostSuccess", nil)];
    } else {
        //NSLog(@"Userinfo request");
        
        [result setObject:self.facebook.accessToken forKey:@"accessToken"];
        [result setObject:self.facebook.expirationDate forKey:@"expirationDate"];
        
        NSURL *storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:@"Facebook.plist"];
        [result writeToURL:storeURL atomically:YES];
        
        self.facebookBundle = [[NSMutableDictionary alloc] initWithContentsOfURL:storeURL];

        NSMutableDictionary *_settingsSection = [self.settingsBundle objectForKey:@"Account"];
        [_settingsSection setObject:[NSString stringWithFormat:@"%@ (%@)", [result objectForKey:@"name"], [result objectForKey:@"email"]] forKey:@"User name"];
        [self saveSettings];

        [self syncServer:SYNC_METHOD_FIRST];
    }
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"call");
    
    NSLog(@"Error = %@", error);
    
    [Utils showAlert:NSLocalizedString(@"Confirm", nil) withTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"FacebookError", nil)];
}

#pragma mark - AdMob

- (void)addAdMob {
    self.gadbannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, -GAD_SIZE_320x50.height, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
    [self.gadbannerView setAdUnitID:ADMOB_PUBLISHER_ID];
    [self.gadbannerView setRootViewController:self.tabBarController];
    [self.gadbannerView setDelegate:self];
    [self.gadbannerView setTag:1000];
    [self.gadbannerView loadRequest:[GADRequest request]];
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"AdMob received succeeded!");
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"AdMob received failed!");
}

#pragma mark - CaulyAD

- (void)addCaulyAd {
    [CaulyViewController initCauly:self];
    
    float yPos = -48;
    
	if([CaulyViewController requestBannerADWithViewController:self.tabBarController xPos:0 yPos:yPos adType:BT_IPHONE] == FALSE) {
		NSLog(@"requestBannerAD failed");
	}
}

- (void)AdReceiveCompleted {
	NSLog(@"CaulyAD AdReceiveCompleted..");
}

- (void)AdReceiveFailed {
	NSLog(@"CaulyAD AdReceiveFailed..");
}

- (NSString *) devKey {
	return CAULY_PUBLISHER_ID;
}

#pragma mark - Event handler

- (void)addButtonPressed:(id)sender {
	NSLog(@"call");
    
    AddViewController *_addViewController = [[AddViewController alloc] init];
    [_addViewController setNote:[Utils insertNewNote:[Utils convertDateToString:[NSDate date] withFlag:FORMAT_TYPE_FLAG_FULL]]];
    [_addViewController setFlagInsert:TR_TYPE_INSERT];
    
    [self.tabBarController presentModalViewController:_addViewController animated:YES];
    [_addViewController release];
}

#pragma mark - User defined function

- (void)syncServer:(NSInteger)mode {
	NSLog(@"call");
    
    self.dataSyncService = [[DataSyncService alloc] initWithContext:self.managedObjectContext withModel:self.managedObjectModel];
    [self.dataSyncService startSyncProcess:mode];
}

- (void)didComplete {
	NSLog(@"call");
    
    self.dataSyncService = nil;
    
    // LST를 세팅에 저장
    NSDate *_lst = [NSDate dateWithTimeIntervalSince1970:[[self.syncLogInfoBundle objectForKey:@"zb_note"] doubleValue] / 1000];
    
    NSMutableDictionary *_settingsSection = [self.settingsBundle objectForKey:@"Sync"];
    [_settingsSection setObject:[Utils convertDateToString:_lst withFlag:FORMAT_TYPE_FLAG_FULL] forKey:@"Last sync time"];
    [self saveSettings];

    if (self.isNotif) {
        // application.applicationIconBadgeNumber = 0;
        
        AddViewController *_addViewController = [[AddViewController alloc] initWithNibName:@"AddViewController" bundle:nil];
        [_addViewController setNote:[Utils insertNewNote:[Utils convertDateToString:[NSDate date] withFlag:FORMAT_TYPE_FLAG_FULL]]];
        [_addViewController setFlagInsert:TR_TYPE_INSERT];
        
        [self.tabBarController presentModalViewController:_addViewController animated:YES];
        [_addViewController release];
        
        self.isNotif = NO;
    } else {
        // DailyListViewController가 현재 표시된 뷰이면 수동 갱신
        if ([self.tabBarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *_curNavController = (UINavigationController *)self.tabBarController.selectedViewController;
            if ([_curNavController.topViewController isKindOfClass:[DailyListViewController class]]) {
                DailyListViewController *_dailyListViewController = (DailyListViewController *)_curNavController.topViewController;
                [_dailyListViewController refreshAfterSync];
            }
        }
    }
}

- (void)saveSettings {
	NSLog(@"call");
    
    NSURL *storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:@"Settings.plist"];
    [self.settingsBundle writeToURL:storeURL atomically:YES];
}

- (void)saveSyncLogs {
	NSLog(@"call");
    
    NSURL *storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:@"SyncLogInfo.plist"];
    [self.syncLogInfoBundle writeToURL:storeURL atomically:YES];
}

- (void)saveFacebook {
	NSLog(@"call");
    
    NSURL *storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:@"Facebook.plist"];
    [self.facebookBundle writeToURL:storeURL atomically:YES];
}

- (void)logout {
	NSLog(@"call");
    
    [self.facebook logout:self];
}

@end
