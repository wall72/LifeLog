//
//  NotificationTimeViewController.m
//  LifeLog
//
//  Created by cliff on 11. 3. 29..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import "NotificationTimeViewController.h"
#import "LifeLogAppDelegate.h"
#import "Utils.h"
#import "Global.h"

@interface NotificationTimeViewController ()
- (void)setLocalNotification:(NSString *)strDate withFlag:(BOOL)flagSet;
@end

@implementation NotificationTimeViewController

@synthesize notiTimes = __notiTimes;
@synthesize keys = __keys;
@synthesize flagNotification = __flagNotification;

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
    
    [__notiTimes release];
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
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    NSLog(@"Call");

    [super viewDidUnload];
    self.notiTimes = nil;
    self.keys = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Call");
    
    [super viewWillAppear:animated];

    self.keys = [self.notiTimes.allKeys sortedArrayUsingSelector:@selector(compare:)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSLog(@"Call");
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"Call");
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Call");
    
    return [self.notiTimes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Call");
    
    static NSString *_cellIdentifier = @"Cell";
    
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    if (_cell == nil) {
        _cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellIdentifier] autorelease];
    }
    
    NSString *_key = [self.keys objectAtIndex:indexPath.row];
    [_cell.textLabel setText:_key];
    
    if ([[self.notiTimes objectForKey:_key] boolValue]) {
        [_cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [_cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return _cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Call");
    
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Call");
    
    UITableViewCell *_cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *_key;
    
    if (_cell.accessoryType == UITableViewCellAccessoryNone) {
        [_cell setAccessoryType:UITableViewCellAccessoryCheckmark];

        _key = [self.keys objectAtIndex:indexPath.row];
        [self.notiTimes setObject:@"1" forKey:_key];

        if (self.flagNotification) {
            [self setLocalNotification:_key withFlag:YES];
        }
    } else {
        [_cell setAccessoryType:UITableViewCellAccessoryNone];

        _key = [self.keys objectAtIndex:indexPath.row];
        [self.notiTimes setObject:@"0" forKey:_key];
        
        if (self.flagNotification) {
            [self setLocalNotification:_key withFlag:NO];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - User defined function

- (void)setLocalNotification:(NSString *)strDate withFlag:(BOOL)flagSet {
    NSLog(@"Call");
    
    NSArray *_notificationsArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    // NSLog(@"notificationsArray = %@", notificationsArray);
    
    // 1. Find LocalNotification and Delete
    UILocalNotification *_noti;
    NSString *_clickedDate = [NSString stringWithFormat:@"%@%@", [strDate substringWithRange:(NSRange){3, 2}], [strDate substringWithRange:(NSRange){6, 2}]];
    NSString *_fireDate;
    
    for (int i = 0; i < [_notificationsArray count]; i++) {
        _noti = [_notificationsArray objectAtIndex:i];
        
        _fireDate = [Utils convertDateToString:_noti.fireDate withFlag:FORMAT_TYPE_FLAG_SPECIAL];
        
        if ([_fireDate isEqualToString:_clickedDate]) {
            [[UIApplication sharedApplication] cancelLocalNotification:_noti];
            break;
        }
    }
    
    if (flagSet) {
        // 2. Reset LocalNoti

        NSCalendar *_calendar = [NSCalendar currentCalendar];
        
        NSInteger _intHour = [[strDate substringWithRange:(NSRange){3, 2}] intValue];
        NSInteger _intMinute = [[strDate substringWithRange:(NSRange){6, 2}] intValue];
        
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
            //통지시간 
            _localNotif.fireDate = _date;
            _localNotif.timeZone = [NSTimeZone defaultTimeZone];
            
            _localNotif.repeatInterval = NSDayCalendarUnit;
            
            //Payload
            _localNotif.alertBody = NSLocalizedString(@"WriteYourLifeLog", nil);
            _localNotif.alertAction = @"Write";
            _localNotif.soundName = UILocalNotificationDefaultSoundName;
            // localNotif.applicationIconBadgeNumber = 1;
            
            //Custom Data
            // NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"mypage" forKey:@"page"];
            // localNotif.userInfo = infoDict;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:_localNotif];
        }
        [_localNotif release];
    
    }

//    _notificationsArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
//    NSLog(@"_notificationsArray = %@", _notificationsArray);
}

@end
