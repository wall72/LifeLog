//
//  AnalyticsViewController.m
//  LifeLog
//
//  Created by cliff on 11. 3. 9..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import "AnalyticsDetailViewController.h"
#import "LifeLogAppDelegate.h"
#import "Utils.h"
#import "Global.h"

@interface AnalyticsDetailViewController ()
- (void)goURL;
@end

@implementation AnalyticsDetailViewController

@synthesize reportSegment = _reportSegment;
@synthesize webView = _webView;
@synthesize actIndicator = _actIndicator;
@synthesize analyticsFlag = __analyticsFlag;
@synthesize actionSheet = _actionSheet;
@synthesize monthPicker = _monthPicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    NSLog(@"Call");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Call");
    
    [_reportSegment release];
    [_webView release];
    [_actIndicator release];
	[_actionSheet release];
	[_monthPicker release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"Call");
    
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    NSLog(@"Call");

    // Log Date Title Button
	UIButton *_logMonthButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_logMonthButton setFrame:CGRectMake(71,7,150,30)];
	[_logMonthButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_logMonthButton setTitle:[Utils convertDateToString:[NSDate date] withFlag:FORMAT_TYPE_FLAG_MM] forState:UIControlStateNormal];
    [_logMonthButton setTag:100];
    [_logMonthButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
	[_logMonthButton addTarget:self action:@selector(logMonthButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.navigationItem setTitleView:_logMonthButton];
//    [_logMonthButton release];
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    NSLog(@"Call");
    
    [super viewDidUnload];
    
    self.reportSegment = nil;
    self.webView = nil;
    self.actIndicator = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Call");
    
    [super viewWillAppear:animated];

    [self goURL];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSLog(@"Call");
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIPickerView delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSLog(@"call");
	
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (component == 0) {
        return [_appDelegate.yearKeys objectAtIndex:row];
    } else {
        return [_appDelegate.monthKeys objectAtIndex:row];
    }
}

#pragma mark - UIPickerView datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	NSLog(@"call");
	
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	NSLog(@"call");
	
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (component == 0) {
        return [_appDelegate.yearKeys count];
    } else {
        return [_appDelegate.monthKeys count];
    }
}

#pragma mark - UIWebView delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"Call");
    
    [self.actIndicator setHidden:NO];
    [self.actIndicator startAnimating];
    
    UIApplication *_app = [UIApplication sharedApplication];
    [_app setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"Call");
    
    [self.actIndicator stopAnimating];
    [self.actIndicator setHidden:YES];
    
    UIApplication *_app = [UIApplication sharedApplication];
    [_app setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Call");
    
    [Utils showAlert:NSLocalizedString(@"Confirm", nil) withTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"CheckNetwork", nil)];
    
    [self.actIndicator stopAnimating];
    [self.actIndicator setHidden:YES];
    
    UIApplication *_app = [UIApplication sharedApplication];
    [_app setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Event handlers

- (void)logMonthButtonPressed:(id)sender {
    NSLog(@"Call");
    
	self.actionSheet = [[UIActionSheet alloc] initWithTitle:@""
												   delegate:nil
									      cancelButtonTitle:nil
								     destructiveButtonTitle:nil
									      otherButtonTitles:nil];
	
	self.monthPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
	
	UIToolbar *_datePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	[_datePickerToolbar setBarStyle:UIBarStyleBlackOpaque];
	[_datePickerToolbar sizeToFit];
	
	NSMutableArray *_barItems = [[NSMutableArray alloc] init];
	
	UIBarButtonItem *_btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(monthPickerCancelPressed:)];
	[_barItems addObject:_btnCancel];
	[_btnCancel release];
	
	UIBarButtonItem *_btnFlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:self 
                                                                                       action:nil];
	[_barItems addObject:_btnFlexibleSpace];
	[_btnFlexibleSpace release];
	
	UIBarButtonItem *_btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self
                                                                              action:@selector(monthPickerDonePressed:)];
	[_barItems addObject:_btnDone];
	[_btnDone release];
	
	[_datePickerToolbar setItems:_barItems animated:NO];
	[_barItems release];
	
	[self.actionSheet addSubview:_datePickerToolbar];
	[_datePickerToolbar release];
	
	[self.monthPicker setDelegate:self];
	[self.monthPicker setDataSource:self];
    [self.monthPicker setShowsSelectionIndicator:YES];
	
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIButton *_logMonthButton = (UIButton *)[self.navigationController.view viewWithTag:100];
    
	NSInteger _pickYearKey = [_appDelegate.yearKeys indexOfObject:[_logMonthButton.titleLabel.text substringToIndex:4]];
	[self.monthPicker selectRow:_pickYearKey inComponent:0 animated:YES];
	
	NSInteger _pickMonthKey = [_appDelegate.monthKeys indexOfObject:[_logMonthButton.titleLabel.text substringFromIndex:5]];
	[self.monthPicker selectRow:_pickMonthKey inComponent:1 animated:YES];

	[self.actionSheet addSubview:self.monthPicker];
	[self.monthPicker release];
	
//	[self.actionSheet showInView:self.view];
    [self.actionSheet showFromTabBar:_appDelegate.tabBarController.tabBar];
	[self.actionSheet setBounds:CGRectMake(0, 0, 320, 500)];
}

-(IBAction)monthPickerDonePressed:(id)sender {
	NSLog(@"call");
	
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    
	NSInteger _currentYearKey = [self.monthPicker selectedRowInComponent:0];
	NSInteger _currentMonthKey = [self.monthPicker selectedRowInComponent:1];

    UIButton *_logMonthButton = (UIButton *)[self.navigationController.view viewWithTag:100];
    [_logMonthButton setTitle:[NSString stringWithFormat:@"%@-%@", [_appDelegate.yearKeys objectAtIndex:_currentYearKey], [_appDelegate.monthKeys objectAtIndex:_currentMonthKey]] forState:UIControlStateNormal];
    
	[self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];

    [self goURL];
}

-(IBAction)monthPickerCancelPressed:(id)sender {
	NSLog(@"call");
	
	[self.actionSheet dismissWithClickedButtonIndex:0 animated:YES]; 
}

- (IBAction)reportValueChanged:(id)sender {
    NSLog(@"Call");
    
    [self goURL];
}

#pragma mark - User defined functions

- (void)goURL {
    NSLog(@"Call");

    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *_urlString;
	
    switch (self.reportSegment.selectedSegmentIndex ) {
        case 1:
            if (self.analyticsFlag) {
                _urlString = [ANALYTICS_OUTCOME_PATH2 stringByAppendingString:[NSString stringWithFormat:@"?user_uuid=%@", [_appDelegate.deviceInfoBundle valueForKey:@"user_uuid"]]];
            } else {
                _urlString = [ANALYTICS_FEELING_PATH2 stringByAppendingString:[NSString stringWithFormat:@"?user_uuid=%@", [_appDelegate.deviceInfoBundle valueForKey:@"user_uuid"]]];
            }
            break;
        case 2:
            if (self.analyticsFlag) {
                _urlString = [ANALYTICS_OUTCOME_PATH3 stringByAppendingString:[NSString stringWithFormat:@"?user_uuid=%@", [_appDelegate.deviceInfoBundle valueForKey:@"user_uuid"]]];
            } else {
                _urlString = [ANALYTICS_FEELING_PATH3 stringByAppendingString:[NSString stringWithFormat:@"?user_uuid=%@", [_appDelegate.deviceInfoBundle valueForKey:@"user_uuid"]]];
            }
            break;
            
        default:
            if (self.analyticsFlag) {
                _urlString = [ANALYTICS_OUTCOME_PATH1 stringByAppendingString:[NSString stringWithFormat:@"?user_uuid=%@", [_appDelegate.deviceInfoBundle valueForKey:@"user_uuid"]]];
            } else {
                _urlString = [ANALYTICS_FEELING_PATH1 stringByAppendingString:[NSString stringWithFormat:@"?user_uuid=%@", [_appDelegate.deviceInfoBundle valueForKey:@"user_uuid"]]];
            }
            break;
    }
    
    // set year & month
    NSString *_curYear;
    NSString *_curMonth;

    UIButton *_logMonthButton = (UIButton *)[self.navigationController.view viewWithTag:100];
    if (_logMonthButton) {
        _curYear = [_logMonthButton.titleLabel.text substringToIndex:4];
        _curMonth = [_logMonthButton.titleLabel.text substringFromIndex:5];
    } else {
        NSString *_curDate = [Utils convertDateToString:[NSDate date] withFlag:FORMAT_TYPE_FLAG_MM];
        _curYear = [_curDate substringToIndex:4];
        _curMonth = [_curDate substringFromIndex:5];
    }
    
    _urlString = [_urlString stringByAppendingFormat:@"&yyyy=%@&mm=%@", _curYear, _curMonth];

    NSLog(@"_logMonthButton = %@", _logMonthButton);
    NSLog(@"URL = %@", _urlString);
    
    NSURLRequest *_requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:[_urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
	[self.webView loadRequest:_requestObj];
}

@end
