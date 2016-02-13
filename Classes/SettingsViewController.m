//
//  SettingsViewController.m
//  LifeLog
//
//  Created by cliff on 11. 3. 29..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import "SettingsViewController.h"
#import "LifeLogAppDelegate.h"
#import "NotificationTimeViewController.h"
#import "RatingBasisViewController.h"
#import "TimeSpanViewController.h"
#import "AboutViewController.h"
#import "DataSyncService.h"
#import "Global.h"

@interface SettingsViewController ()
- (NSString *)getKeyInSection:(NSString *)grpKey withIndex:(NSInteger)idx;
@end

@implementation SettingsViewController

@synthesize settings = __settings;
@synthesize keys = __keys;

- (id)initWithStyle:(UITableViewStyle)style {
    NSLog(@"Call");
    
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Call");
    
    [__settings release];
    [__keys release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"Call");
    
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    NSLog(@"Call");
    
    self.keys = [NSArray arrayWithObjects:@"Notification", @"Rating", @"View", @"Sync", @"Account", @"About", nil];

    [super viewDidLoad];
}

- (void)viewDidUnload {
    NSLog(@"Call");
    
    [super viewDidUnload];
    self.settings = nil;
    self.keys = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Call");

    [super viewWillAppear:animated];

    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.settings = _appDelegate.settingsBundle;
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"Call");
    
    [super viewWillDisappear:animated];

    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    [_appDelegate saveSettings];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSLog(@"Call");
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"Call");
    
    NSLog(@"[self.keys count]%d", [self.keys count]);
    return [self.keys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Call");
    
    NSString *_key = [self.keys objectAtIndex:section];
    NSDictionary *_settingsSection = [self.settings objectForKey:_key];
    
    return [_settingsSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Call");
    
    NSString *_groupKey = [self.keys objectAtIndex:indexPath.section];
    NSDictionary *_settingsSection = [self.settings objectForKey:_groupKey];
    NSString *_key = [self getKeyInSection:_groupKey withIndex:indexPath.row];

    static NSString *_cellIdentifier = @"SectionsTableIndentifier";
    
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    
    if (_cell == nil) {
        _cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:_cellIdentifier] autorelease];
    }

    _cell.textLabel.text = _key;
    
    if ([_key isEqualToString:@"Set Notification"]) {
        UISwitch *_switch = [[[UISwitch alloc] init] autorelease];
        [_switch setOn:[[_settingsSection objectForKey:_key] boolValue]];
        [_switch addTarget:self action:@selector(swNotiChanged:) forControlEvents:UIControlEventValueChanged];
        
        [_cell setAccessoryView:_switch];
        [_cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [_cell.detailTextLabel setText:nil];
    } else if ([_key isEqualToString:@"Sync on startup"]) {
        UISwitch *_switch = [[[UISwitch alloc] init] autorelease];
        [_switch setOn:[[_settingsSection objectForKey:_key] boolValue]];
        [_switch addTarget:self action:@selector(swSyncChanged:) forControlEvents:UIControlEventValueChanged];
        
        [_cell setAccessoryView:_switch];
        [_cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [_cell.detailTextLabel setText:nil];
    } else if ([_key isEqualToString:@"Sync now"]) {
        UIButton *_button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(0, 0, 285, 30);
        [_button setTitle:@"Sync now" forState:UIControlStateNormal];
        [_button setBackgroundImage:[[UIImage imageNamed:@"blueButton.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(btnSyncPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [_cell setAccessoryView:_button];
        [_cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [_cell.detailTextLabel setText:nil];
    } else if ([_key isEqualToString:@"Logout"]) {
        UIButton *_button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(0, 0, 81, 29);
        [_button setImage:[UIImage imageNamed:@"LogoutNormal.png"] forState:UIControlStateNormal];
        [_button setImage:[UIImage imageNamed:@"LogoutPressed.png"] forState:UIControlStateHighlighted];
        [_button addTarget:self action:@selector(btnLogoutPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [_cell setAccessoryView:_button];
        [_cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [_cell.detailTextLabel setText:nil];
    } else if ([_key isEqualToString:@"Last sync time"]||[_key isEqualToString:@"User name"]) {
        [_cell setAccessoryView:nil];
        [_cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [_cell setAccessoryType:UITableViewCellAccessoryNone];
        [_cell.detailTextLabel setText:[_settingsSection objectForKey:_key]];
        [_cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
    } else { // go viewcontroller
        [_cell setAccessoryView:nil];
        [_cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        [_cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [_cell.detailTextLabel setText:nil];
    }

    return _cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSLog(@"Call");
    
    NSString *_key = [self.keys objectAtIndex:section];
    return _key;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Call");
    
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"call");
	
    NSString *_groupKey = [self.keys objectAtIndex:indexPath.section];
    NSDictionary *_settingsSection = [self.settings objectForKey:_groupKey];
    NSString *_key = [self getKeyInSection:_groupKey withIndex:indexPath.row];

    if ([_key isEqualToString:@"Notification time"]) {
        NotificationTimeViewController *notificationTimeViewController = [[NotificationTimeViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [notificationTimeViewController setTitle:_key];
        [notificationTimeViewController setNotiTimes:[_settingsSection objectForKey:_key]];
        [notificationTimeViewController setFlagNotification:[[_settingsSection objectForKey:@"Set Notification"] boolValue]];
        [notificationTimeViewController setHidesBottomBarWhenPushed:YES];
        
        [self.navigationController pushViewController:notificationTimeViewController animated:YES];
        [notificationTimeViewController release];
    } else if ([_key isEqualToString:@"Rating basis"]) {
        RatingBasisViewController *ratingBasisViewController = [[RatingBasisViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [ratingBasisViewController setTitle:_key];
        [ratingBasisViewController setRatingBasis:[_settingsSection objectForKey:_key]];
        [ratingBasisViewController setHidesBottomBarWhenPushed:YES];
        
        [self.navigationController pushViewController:ratingBasisViewController animated:YES];
        [ratingBasisViewController release];
    } else if ([_key isEqualToString:@"Time span"]) {
        TimeSpanViewController *timeSpanViewController = [[TimeSpanViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [timeSpanViewController setTitle:_key];
        [timeSpanViewController setTimeSpan:[_settingsSection objectForKey:_key]];
        [timeSpanViewController setHidesBottomBarWhenPushed:YES];
        
        [self.navigationController pushViewController:timeSpanViewController animated:YES];
        [timeSpanViewController release];
    } else if ([_key isEqualToString:@"About us"]) {
        AboutViewController *aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
        [aboutViewController setTitle:_key];
        [aboutViewController setHidesBottomBarWhenPushed:YES];
        
        [self.navigationController pushViewController:aboutViewController animated:YES];
        [aboutViewController release];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Event Handler

- (void)swNotiChanged:(id)sender {
    NSLog(@"Call");
    
    UISwitch *_switch = (UISwitch *)sender;
    
    NSMutableDictionary *_settingsSection = [self.settings objectForKey:@"Notification"];
    [_settingsSection setObject:[NSString stringWithFormat:@"%d", _switch.on] forKey:@"Set Notification"];

    NSDictionary *_notiTimes = [_settingsSection objectForKey:@"Notification time"];

    if ([_switch isOn]) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        NSCalendar *_calendar = [NSCalendar currentCalendar];
        
        [_notiTimes enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            NSInteger _intHour = [[key substringWithRange:(NSRange){3, 2}] intValue];
            NSInteger _intMinute = [[key substringWithRange:(NSRange){6, 2}] intValue];
            BOOL _boolFlag = [obj boolValue];
            
            if (_boolFlag) {
                NSDateComponents *_dateComps = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:[NSDate date]];
                
                if (_dateComps.hour > _intHour) {
                    [_dateComps setDay:(_dateComps.day + 1)];
                }
                [_dateComps setHour:_intHour];
                [_dateComps setMinute:_intMinute];
                [_dateComps setSecond:0];
                
                NSDate *_date = [_calendar dateFromComponents:_dateComps];
                //[dateComps release];
                
                UILocalNotification *_localNotif = [[UILocalNotification alloc] init];
                if (_localNotif != nil) {
                    // Fire Date
                    _localNotif.fireDate = _date;
                    _localNotif.timeZone = [NSTimeZone defaultTimeZone];
                    
                    _localNotif.repeatInterval = NSDayCalendarUnit;
                    
                    // Payload
                    _localNotif.alertBody = NSLocalizedString(@"WriteYourLifeLog", nil);
                    _localNotif.alertAction = @"Write";
                    _localNotif.soundName = UILocalNotificationDefaultSoundName;
                    // localNotif.applicationIconBadgeNumber = 1;
                    
                    // Custom Data
                    // NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"mypage" forKey:@"page"];
                    // localNotif.userInfo = infoDict;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:_localNotif];
                }
                [_localNotif release];
            }
        }];
    } else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }

    NSArray *_notificationsArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSLog(@"_notificationsArray = %@", _notificationsArray);
}

- (void)swSyncChanged:(id)sender {
    NSLog(@"Call");
    
    UISwitch *_switch = (UISwitch *)sender;
    
    NSMutableDictionary *_settingsSection = [self.settings objectForKey:@"Sync"];
    [_settingsSection setObject:[NSString stringWithFormat:@"%d", _switch.on] forKey:@"Sync on startup"];
}

- (void)btnSyncPressed:(id)sender {
    NSLog(@"Call");
    
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    [_appDelegate syncServer:SYNC_METHOD_LIST];
}

- (void)btnLogoutPressed:(id)sender {
    NSLog(@"Call");
    
    // Facebook logout
    // 개인정보 보호를 위해 더 한짓도 해야 할듯...
    
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [_appDelegate.syncLogInfoBundle setObject:@"" forKey:@"zb_note"];
    [_appDelegate.syncLogInfoBundle setObject:@"" forKey:@"zb_resource"];
    [_appDelegate saveSyncLogs];
    
    [_appDelegate.facebookBundle setObject:@"" forKey:@"id"];
    [_appDelegate.facebookBundle setObject:@"" forKey:@"accessToken"];
    [_appDelegate.facebookBundle setObject:@"" forKey:@"expirationDate"];
    [_appDelegate saveFacebook];
    
    [_appDelegate logout];
}

#pragma mark - User defined function

- (NSString *)getKeyInSection:(NSString *)grpKey withIndex:(NSInteger)idx {
    NSLog(@"Call");
    
    if ([grpKey isEqualToString:@"Notification"]) {
        if (idx == 0) {
            return @"Set Notification";
        } else {
            return @"Notification time";
        }
    } else if ([grpKey isEqualToString:@"Rating"]) {
        return @"Rating basis";
    } else if ([grpKey isEqualToString:@"View"]) {
        return @"Time span";
    } else if ([grpKey isEqualToString:@"Sync"]) {
        if (idx == 0) {
            return @"Last sync time";
        } else if (idx == 1) { 
            return @"Sync on startup";
        } else {
            return @"Sync now";
        }
    } else if ([grpKey isEqualToString:@"Account"]) {
        if (idx == 0) {
            return @"User name";
        } else {
            return @"Logout";
        }
    } else if ([grpKey isEqualToString:@"About"]) {
        return @"About us";
    } else {
        return @"";
    }
}

@end
