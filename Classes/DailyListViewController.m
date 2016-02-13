//
//  DailyListViewController.m
//  LifeLog
//
//  Created by cliff on 11. 3. 9..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import "DailyListViewController.h"
#import "LifeLogAppDelegate.h"
#import "DetailViewController.h"
#import "AddViewController.h"
#import "ListCell.h"
#import "Note.h"
#import "Resource.h"
#import "Utils.h"
#import "Global.h"

@interface DailyListViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)chageDate:(NSInteger)pos;
- (NSString *)getCurDateToString:(NSDateComponents *)dateComp;
- (NSString *)getCurDateToWeekString:(NSDateComponents *)dateComp;
- (void)populateArray48Hour;
- (void)fetchData;
- (BOOL)findDataArrayByKey:(NSString *)findKey withNote:(Note **)note;
- (void)refreshData;
- (void)setCurDayLabel;
- (void)reSetDaySumbar;
@end

@implementation DailyListViewController

@synthesize daySumbar = _daySumbar;
@synthesize tableView = _tableView;
@synthesize curDate = __curDate;
@synthesize array48hour = __array48hour;
@synthesize dataArray = __dataArray;
@synthesize sumOfRating = __sumOfRating;
@synthesize sumOfFeeling = __sumOfFeeling;;
@synthesize countOfNote = __countOfNote;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
	NSLog(@"call");
	
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	NSLog(@"call");
    
	[_tableView release];
	[_daySumbar release];
	[__curDate release];
    [__array48hour release];
	[__dataArray release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void) loadView{
	NSLog(@"call");

	[super loadView];

	float _y = 0;
	float _height = 22;

    // Add DaySumBar
	self.daySumbar = [[UIView alloc] initWithFrame:CGRectMake(0, _y, 320, _height)];
    [self.daySumbar setBackgroundColor:[UIColor grayColor]];
	
	UIImageView *_imageViewLogo = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 96, 18)];
	[_imageViewLogo setTag:3];
	[_imageViewLogo setImage:[UIImage imageNamed:@"zepalogo.png"]];
	[self.daySumbar addSubview:_imageViewLogo];
	[_imageViewLogo release];

	UIImageView *_imageViewRating = [[UIImageView alloc] initWithFrame:CGRectMake(209, 3, 86, 16)];
	[_imageViewRating setTag:4];
	[_imageViewRating setImage:[UIImage imageNamed:@"daily_t_bar_star_5.png"]];
	[self.daySumbar addSubview:_imageViewRating];
	[_imageViewRating release];
	
	UIImageView *_imageViewFeel = [[UIImageView alloc] initWithFrame:CGRectMake(299, 2, 19, 19)];
	[_imageViewFeel setTag:5];
	[_imageViewFeel setImage:[UIImage imageNamed:@"daily_t_bar_feel_3"]];
	[self.daySumbar addSubview:_imageViewFeel];
	[_imageViewFeel release];

	[self.view addSubview:self.daySumbar];
	
	_y = self.daySumbar.frame.origin.y + self.daySumbar.frame.size.height;
	_height = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - _y - 49;

    // Add TableView
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _y, 320, _height) style:UITableViewStylePlain];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setRowHeight:57];
	[self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
	
	[self.view addSubview:self.tableView];
	[self.view sendSubviewToBack:self.tableView];
}

- (void)viewDidLoad {
	NSLog(@"call");
	
	UIButton *_prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_prevButton setFrame:CGRectMake(0, 0, 37, 37)];
	[_prevButton setImage:[UIImage imageNamed:@"daily_navi_before_button.png"] forState:UIControlStateNormal];
    [_prevButton setTag:1];
	[_prevButton addTarget:self action:@selector(prevButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *_prevButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_prevButton];
	[self.navigationItem setLeftBarButtonItem:_prevButtonItem];
    [_prevButtonItem release];
    
	UIButton *_nexButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_nexButton setFrame:CGRectMake(0, 0, 37, 37)];
	[_nexButton setImage:[UIImage imageNamed:@"daily_navi_next_button.png"] forState:UIControlStateNormal];
    [_nexButton setTag:2];
	[_nexButton addTarget:self action:@selector(nexButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *_nexButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_nexButton];
	[self.navigationItem setRightBarButtonItem:_nexButtonItem];
    [_nexButtonItem release];

	self.curDate = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit) fromDate:[NSDate date]];

    [super viewDidLoad];
}

- (void)viewDidUnload {
	NSLog(@"call");
    
    [super viewDidUnload];
    self.tableView = nil;
    self.daySumbar = nil;
    self.curDate = nil;
    self.array48hour = nil;
    self.dataArray = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"call");
	
    [super viewWillAppear:animated];

    [self setCurDayLabel];
    
    [self populateArray48Hour];
    
    [self refreshData];
    
    [self reSetDaySumbar];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSLog(@"call");
	
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"call");

	return [self.array48hour count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"call");
	
    static NSString *_customCellIdentifier = @"ListCellIdentifier ";
    
    ListCell *_cell = (ListCell *)[tableView dequeueReusableCellWithIdentifier:_customCellIdentifier];
    if (_cell == nil) {
        NSArray *_nib = [[NSBundle mainBundle] loadNibNamed:@"ListCell" owner:self options:nil];
        for (id _oneObject in _nib) {
            if ([_oneObject isKindOfClass:[ListCell class]]) {
                _cell = (ListCell *)_oneObject;
            }
        }
    }
    
    [self configureCell:_cell atIndexPath:indexPath];
    
    return _cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *_findKey = [self.array48hour objectAtIndex:indexPath.row];
    
    Note *_note;
    
    BOOL _boolCheck = [self findDataArrayByKey:_findKey withNote:&_note];
    
    return _boolCheck;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"call");
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSString *_findKey = [self.array48hour objectAtIndex:indexPath.row];
        
        Note *_note;
        
        BOOL _boolCheck = [self findDataArrayByKey:_findKey withNote:&_note];
        
        if (_boolCheck == YES) {
            [_note setActive:[NSNumber numberWithBool:NO]];

            int64_t _epoch_time = ([[NSDate date] timeIntervalSince1970] * 1000);
            [_note setUpdated_time:[NSNumber numberWithLongLong:_epoch_time]];
            
            [_note setUpdate_count:[NSNumber numberWithInt:[_note.update_count intValue] + 1]];

            [Utils deleteDirectory:_note.uuid];
            
            LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
            [_appDelegate saveContext];
        
            [self.dataArray removeObject:_note];
        }
    }
    
    [self refreshData];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"call");
	
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"call");
    
    NSString *_findKey = [self.array48hour objectAtIndex:indexPath.row];
    
    Note *_note;
    
    BOOL _boolCheck = [self findDataArrayByKey:_findKey withNote:&_note];
    
    if (_boolCheck == YES) {
        DetailViewController *detailViewController = [[DetailViewController alloc] init];
        [detailViewController setNote:_note];
        [detailViewController setHidesBottomBarWhenPushed:YES];
        
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    } else {
        AddViewController *_addViewController = [[AddViewController alloc] initWithNibName:@"AddViewController" bundle:nil];
        [_addViewController setNote:[Utils insertNewNote:_findKey]];
        [_addViewController setFlagInsert:TR_TYPE_INSERT];
        
        [self presentModalViewController:_addViewController animated:YES];
        [_addViewController release];
    }
}

#pragma mark - Event handler

- (IBAction)prevButtonPressed:(id)sender {
	NSLog(@"call");
	
	[self chageDate:[sender tag]];
	
    [self setCurDayLabel];
	
    [self populateArray48Hour];

    [self refreshData];
    
    [self reSetDaySumbar];
}

- (IBAction)nexButtonPressed:(id)sender {
	NSLog(@"call");
	
	[self chageDate:[sender tag]];
	
    [self setCurDayLabel];
	
    [self populateArray48Hour];
    
    [self refreshData];
    
    [self reSetDaySumbar];
}

#pragma mark - User defined fuction

- (void)configureCell:(ListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"call");
	
    NSString *_findKey = [self.array48hour objectAtIndex:indexPath.row];
    
    Note *_note;
    
    BOOL _boolCheck = [self findDataArrayByKey:_findKey withNote:&_note];
    
    // Set Background Image
    NSString *_disHour = [_findKey substringWithRange:(NSRange){11, 2}];
    NSString *_disMinute = [_findKey substringFromIndex:14];
    if ([_disMinute isEqualToString:@"30"]) {
        [cell.backgroundImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"daily_time_bg_%@.png", _disMinute]]];
    } else {
        [cell.backgroundImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"daily_time_bg_%@.png", _disHour]]];
    }

    if (_boolCheck == TRUE) {
        // Set Feeling
        LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];    
        [cell.feelingLabel setText:[_appDelegate.feelDict objectForKey:_note.feeling]];
        
        // Set Rating Star
        [cell.ratingScoreImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"daily_time_bar_star_s_%d.png", [_note.rating_score intValue]]]];
        
        // Set Log Text
        [cell.contentLabel setText:_note.title];
        
        // Set Accessary
        if ([_note.map_yn boolValue]) {
            [cell.mapYnImage setImage:[UIImage imageNamed:@"daily_time_bar_map_on.png"]];
        }
        if ([_note.facebook_yn boolValue]) {
            [cell.facebookYnImage setImage:[UIImage imageNamed:@"daily_time_bar_facebook_on.png"]];
        }

        // Set Line
        [cell.line1Image setImage:[UIImage imageNamed:[NSString stringWithFormat:@"daily_time_bar_line.png"]]];
        [cell.line2Image setImage:[UIImage imageNamed:[NSString stringWithFormat:@"daily_time_bar_line.png"]]];

        // Set Accessary Type
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

        // Set Line
        [cell.accessoryImage setImage:nil];
    } else {
        // Set Feeling
        [cell.feelingLabel setText:nil];
        
        // Set Rating Star
        [cell.ratingScoreImage setImage:nil];
        
        // Set Log Text
        [cell.contentLabel setText:nil];
        
        // Set Accessary
        [cell.mapYnImage setImage:nil];
        [cell.facebookYnImage setImage:nil];

        // Set Line
        [cell.line1Image setImage:nil];
        [cell.line2Image setImage:nil];

        // Set Accessary Type
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        // Set Line
        [cell.accessoryImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"daily_write_icon_s.png"]]];
    }
}

- (void)chageDate:(NSInteger)pos {
	NSLog(@"call");
	
    NSTimeInterval _newValue = 0;
    NSDate *_tempDate = [[NSCalendar currentCalendar] dateFromComponents:self.curDate];
	
	if (pos == NAV_PREVDAY) {
		_newValue = -ONEDAY_SECOND;
	} else if (pos == NAV_NEXTDAY) {
		_newValue = ONEDAY_SECOND;
	} else {
		return;
	}
	
    NSDateComponents *_newDate = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit) fromDate:[_tempDate dateByAddingTimeInterval:_newValue]];
    
    [self.curDate setYear: [_newDate year]];
    [self.curDate setMonth: [_newDate month]];
    [self.curDate setDay: [_newDate day]];
    [self.curDate setWeekday: [_newDate weekday]];
}

- (NSString *)getCurDateToString:(NSDateComponents *)dateComp {
	NSLog(@"call");
	
    NSString *_returnString;
    
    _returnString = [NSString stringWithFormat:@"%d-%02d-%02d", [dateComp year], [dateComp month], [dateComp day]];
    
	return _returnString;
}

- (NSString *)getCurDateToWeekString:(NSDateComponents *)dateComp {
	NSLog(@"call");
    
    NSCalendar *_tmpCalendar = [NSCalendar currentCalendar];
	
    NSDate *_tmpDate = [_tmpCalendar dateFromComponents:dateComp];
    
	NSDateFormatter *_dateFormatter = [[NSDateFormatter alloc] init];
	
	[_dateFormatter setDateFormat:@"cccc"];
    
	NSString *returnString = [_dateFormatter stringFromDate:_tmpDate];
	
	[_dateFormatter release];
	
	return returnString;
}

- (void)populateArray48Hour {
	NSLog(@"call");
	
    NSInteger _tmpHour = 0;
    NSInteger _tmpMinute = 0;
    NSInteger _tmpTimeSpan = SIZE_OF_TIME_SPAN;

    // Set Time Span
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *_settingsSection = [_appDelegate.settingsBundle objectForKey:@"View"];
    NSDictionary *_ratingBasis = [_settingsSection objectForKey:@"Time span"];
    
    NSString *_checkedKey = nil;
    
    NSEnumerator *_enumerator = [_ratingBasis keyEnumerator];
    id _key;
    BOOL _boolFlag;
    while ((_key = [_enumerator nextObject])) {
        _boolFlag = [[_ratingBasis objectForKey:_key] boolValue];
        if (_boolFlag) {
            _checkedKey = _key;
            break;
        }
    }
    
    if ([_checkedKey isEqualToString:@"09:00 ~ 18:00"]) {
        _tmpHour = 9;
        _tmpTimeSpan = SIZE_OF_TIME_SPAN;
    } else if ([_checkedKey isEqualToString:@"10:00 ~ 19:00"]) {
        _tmpHour = 10;
        _tmpTimeSpan = SIZE_OF_TIME_SPAN;
    } else { // @"00:00 ~ 24:00"
        _tmpHour = 0;
        _tmpTimeSpan = 48;
    }

    // Populate Array
	NSString *_curDate = [self getCurDateToString:self.curDate];
    NSString *_newLogDate;
    
    [__array48hour release];
    self.array48hour = [[NSMutableArray alloc] init];
    for (int _count = 0; _count < _tmpTimeSpan; _count++) {
        if (_count != 0) {
            if ((_count % 2) == 0) {
                _tmpHour++;
                _tmpMinute = 0;
            } else {
                _tmpMinute = 30;
            }
        }
        
        _newLogDate = [NSString stringWithFormat:@"%@ %.2d:%.2d", _curDate, _tmpHour, _tmpMinute];
        [self.array48hour addObject:_newLogDate];
    }
}

- (void)fetchData {
	NSLog(@"call");
	
	// NSManagedObjectContext를 가져옴
	LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *_managedObjectContext = _appDelegate.managedObjectContext;

    // Create the fetch request for the entity.
    NSFetchRequest *_fetchRequest = [[NSFetchRequest alloc] init];
   
    // Edit the entity name as appropriate.
    NSEntityDescription *_entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:_managedObjectContext];
    [_fetchRequest setEntity:_entity];
    
	// Set Predicate
	NSString *_wildCardString = [NSString stringWithFormat:@"%@*", [self getCurDateToString:self.curDate]];
	NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"log_time like %@ and active = 1", _wildCardString];
	[_fetchRequest setPredicate:_predicate];
    
	// Set the batch size to a suitable number.
    [_fetchRequest setFetchBatchSize:48];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *_sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"log_time" ascending:YES];
    NSArray *_sortDescriptors = [[NSArray alloc] initWithObjects:_sortDescriptor, nil];
    
    [_fetchRequest setSortDescriptors:_sortDescriptors];
    
    [_sortDescriptor release];
    [_sortDescriptors release];
    
    NSError *_error = nil;
    [__dataArray release];
	self.dataArray = [[_managedObjectContext executeFetchRequest:_fetchRequest error:&_error] mutableCopy];
    
    if (_error != nil) {
        NSLog(@"Unresolved error %@, %@", _error, [_error userInfo]);
        abort();
    }

    self.countOfNote = [self.dataArray count];
    
    NSNumber* _sum = [self.dataArray valueForKeyPath:@"@sum.rating_score"];
    if (_sum != nil) {
        self.sumOfRating = [_sum intValue];
    } else {
        self.sumOfRating = 0;
    }
    
    _sum = [self.dataArray valueForKeyPath:@"@sum.feeling"];
    if (_sum != nil) {
        self.sumOfFeeling = [_sum intValue];
    } else {
        self.sumOfFeeling = 0;
    }
    
    [_fetchRequest release];
}    

- (BOOL)findDataArrayByKey:(NSString *)findKey withNote:(Note **)note {
	NSLog(@"call");
	
    BOOL _boolCheck = FALSE;
    
    for (int _count = 0; _count < [self.dataArray count]; _count++) {
        *note = [self.dataArray objectAtIndex:_count];
        if ([(*note).log_time isEqualToString:findKey] == TRUE) {
            _boolCheck = TRUE;
            break;
        }
    }
    
    return _boolCheck;
}

- (void)refreshData {
	NSLog(@"call");
	
    [self fetchData];
    
	[self.tableView reloadData];
}

- (void)setCurDayLabel {
	NSLog(@"call");
	
	self.navigationItem.title = [Utils convertDateToString:[[NSCalendar currentCalendar] dateFromComponents:self.curDate] withFlag:FORMAT_TYPE_FLAG_READ];
}

- (void)reSetDaySumbar {
	NSLog(@"call");
	
	UIImageView *_imageViewRating = (UIImageView *)[self.view viewWithTag:4];
    
	int _avrScore = 0;
    if (self.countOfNote > 0) {
        _avrScore = self.sumOfRating / self.countOfNote;
    }
    
	[_imageViewRating setImage:[UIImage imageNamed:[NSString stringWithFormat:@"daily_t_bar_star_%d.png", _avrScore]]];

	UIImageView *_imageViewFeel = (UIImageView *)[self.view viewWithTag:5];
    
    int _avrFeel = 2;
    if (self.countOfNote > 0) {
        _avrFeel = self.sumOfFeeling / self.countOfNote;
        if (_avrFeel > 8) {
            _avrFeel = 3;
        } else if (_avrFeel > 4) {
            _avrFeel = 2;
        } else {
            _avrFeel = 1;
        }
    }
    
	[_imageViewFeel setImage:[UIImage imageNamed:[NSString stringWithFormat:@"daily_t_bar_feel_%d.png", _avrFeel]]];
}

- (void)refreshAfterSync {
	NSLog(@"call");
    
    [self refreshData];
    
    [self reSetDaySumbar];
}

@end

