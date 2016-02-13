//
//  LifeLogAppDelegate.h
//  LifeLog
//
//  Created by cliff on 11. 3. 9..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FBConnect.h"
#import "DataSyncService.h"
#import "GADBannerView.h"
#import "CaulyViewController.h"

@interface LifeLogAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, FBSessionDelegate, FBDialogDelegate, FBRequestDelegate, UIAlertViewDelegate, GADBannerViewDelegate, CaulyProtocol> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, assign) BOOL isNotif;
@property (nonatomic, retain) NSArray *keys;
@property (nonatomic, retain) NSDictionary *feelDict;
@property (nonatomic, retain) NSArray *yearKeys;
@property (nonatomic, retain) NSArray *monthKeys;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) DataSyncService *dataSyncService;
@property (nonatomic, retain) NSMutableDictionary *settingsBundle;
@property (nonatomic, retain) NSMutableDictionary *facebookBundle;
@property (nonatomic, retain) NSMutableDictionary *userInfoBundle;
@property (nonatomic, retain) NSMutableDictionary *deviceInfoBundle;
@property (nonatomic, retain) NSMutableDictionary *syncLogInfoBundle;
@property (nonatomic, retain) GADBannerView *gadbannerView;

- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationLibraryDirectory;
- (void)syncServer:(NSInteger)mode;
- (void)didComplete;
- (void)saveContext;
- (void)saveSettings;
- (void)saveSyncLogs;
- (void)saveFacebook;
- (void)logout;

@end

