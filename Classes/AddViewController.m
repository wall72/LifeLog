//
//  AddViewController.m
//  LifeLog
//
//  Created by cliff on 11. 3. 7..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import "AddViewController.h"
#import "LifeLogAppDelegate.h"
#import "MapViewController.h"
#import "Note.h"
#import "Resource.h"
#import "Utils.h"
#import "Global.h"
#import "QuartzCore/QuartzCore.h"
#import "GADBannerView.h"

@interface AddViewController ()
- (BOOL)validateValue;
- (NSString *)makeFbMessage;
@end

@implementation AddViewController

@synthesize navigationBar = _navigationBar;
@synthesize pointLabel = _pointLabel;
@synthesize contentTextView = _contentTextView;
@synthesize feelingButton = _feelingButton;
@synthesize facebookButton = _facebookButton;
@synthesize imageButton = _imageButton;
@synthesize mapButton = _mapButton;
@synthesize latitudeLabel = _latitudeLabel;
@synthesize longitudeLabel = _longitudeLabel;
@synthesize createdTimeLabel = _createdTimeLabel;
@synthesize note = __note;
@synthesize flagInsert = __flagInsert;
@synthesize actionSheet = _actionSheet;
@synthesize datePicker = _datePicker;
@synthesize feelPicker = _feelPicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	NSLog(@"call");
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
	NSLog(@"call");
	
    [_navigationBar release];
    [_pointLabel release];
    [_contentTextView release];
    [_feelingButton release];
    [_facebookButton release];
    [_imageButton release];
    [_mapButton release];
    [_latitudeLabel release];
    [_longitudeLabel release];
    [_createdTimeLabel release];
	[__note release];
	[_actionSheet release];
	[_datePicker release];
	[_feelPicker release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
	NSLog(@"call");
	
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	NSLog(@"call");
	
    [super viewDidLoad];

    // Log Date Title Button
	UIButton *_logTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_logTimeButton setFrame:CGRectMake(71,7,190,30)];
	[_logTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_logTimeButton setTitle:@"No Title" forState:UIControlStateNormal];
    [_logTimeButton setTag:1];
    [_logTimeButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
	[_logTimeButton addTarget:self action:@selector(logTimeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:_logTimeButton];
    
    // Star Rating Label
    DLStarRatingControl *_customNumberOfStars = [[DLStarRatingControl alloc] initWithFrame:CGRectMake(100.5, 72, 120, 25) andStars:5];
	[_customNumberOfStars setBackgroundColor:RGB(247, 244, 237)]; // Set RGB
	[_customNumberOfStars setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
	[_customNumberOfStars setRating:0];
    [_customNumberOfStars setDelegate:self];
    [_customNumberOfStars setTag:2];
	[self.view addSubview:_customNumberOfStars];
    [_customNumberOfStars release];

    // TextView Border
    [self.contentTextView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self.contentTextView.layer setBorderWidth:1.0];

    // Embed AdMob
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (_appDelegate.gadbannerView != nil) {
        CGRect gadBannerFrame = _appDelegate.gadbannerView.frame;
        gadBannerFrame.origin.y = self.view.frame.size.height - _appDelegate.gadbannerView.frame.size.height;
        [_appDelegate.gadbannerView setFrame:gadBannerFrame];
        [self.view addSubview:_appDelegate.gadbannerView];
    } else {
        [CaulyViewController moveBannerAD:self caulyParentview:self.view xPos:0 yPos:(self.view.frame.size.height - 48)];
    }
}

- (void)viewDidUnload {
	NSLog(@"call");
	
    [super viewDidUnload];
    self.navigationBar = nil;
    self.pointLabel = nil;
    self.contentTextView = nil;
    self.feelingButton = nil;
    self.facebookButton = nil;
    self.imageButton = nil;
    self.mapButton = nil;
    self.latitudeLabel = nil;
    self.longitudeLabel = nil;
    self.createdTimeLabel = nil;
	//self.note = nil;
	//self.actionSheet = nil;
	//self.datePicker = nil;
	//self.feelPicker = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"call");

    if (self.flagInsert == TR_TYPE_EDIT) {
        UINavigationItem *_item = [self.navigationBar.items objectAtIndex:0];
        _item.leftBarButtonItem = nil;
    }
    
    NSSet *_rowSet = [self.note valueForKey:@"resources"];
    
    NSEnumerator *_enumerator = [_rowSet objectEnumerator];
    Resource *_value;
    
    Resource *_camResource;
    Resource *_mapResource;
    
    while ((_value = [_enumerator nextObject])) {
        NSInteger _type = [_value.type intValue];

        switch (_type) {
            case 2: // Camera
                _camResource = _value;
                break;
            case 3: // Map
                _mapResource = _value;
                break;
                
            default:
                break;
        }
    }

	UIButton *_logTimeButton = (UIButton *)[self.view viewWithTag:1];
    [_logTimeButton setTitle:[Utils convertDateToString:[Utils convertStringToDate:self.note.log_time withFlag:FORMAT_TYPE_FLAG_MIDDLE] withFlag:FORMAT_TYPE_FLAG_READ2] forState:UIControlStateNormal];

	int _curScore = [self.note.rating_score intValue];
	DLStarRatingControl *_customNumberOfStars = (DLStarRatingControl *)[self.view viewWithTag:2];
    _customNumberOfStars.rating = _curScore;
	
    [self.pointLabel setText:[[Utils getPoint:_curScore] stringByAppendingString:@" Points"]];
	
	[self.contentTextView setText:self.note.content];
    
	[self.createdTimeLabel setText:[Utils convertDateToString:[NSDate dateWithTimeIntervalSince1970:([self.note.created_time unsignedLongLongValue] / 1000)] withFlag:FORMAT_TYPE_FLAG_FULL]];
	
	if ([self.note.feeling intValue] != 0) {
        LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
		[self.feelingButton setTitle:[_appDelegate.feelDict objectForKey:self.note.feeling] forState:UIControlStateNormal];
        [self.feelingButton setBackgroundImage:[UIImage imageNamed:@"write_feel_bg.png"] forState:UIControlStateNormal];
	}
    
    if ([self.note.facebook_yn boolValue]) {
        [self.facebookButton setSelected:YES];
    }

    if ([self.note.image_yn boolValue]) {
        [self.imageButton setImage:[[[UIImage alloc] initWithData:[Utils getImageFile:self.note.uuid withName:_camResource.file_name]] autorelease] forState:UIControlStateNormal];
        [self.imageButton setImage:nil forState:UIControlStateHighlighted];
    }
	
    if ([self.note.map_yn boolValue]) {
        [self.mapButton setImage:[[[UIImage alloc] initWithData:[Utils getImageFile:self.note.uuid withName:_mapResource.file_name]] autorelease] forState:UIControlStateNormal];
        [self.mapButton setImage:nil forState:UIControlStateHighlighted];
    }
    
	[self.latitudeLabel setText:[NSString stringWithFormat:@"%.3f", [self.note.latitude doubleValue]]];
	[self.longitudeLabel setText:[NSString stringWithFormat:@"%.3f", [self.note.longitude doubleValue]]];
    
    if (![self validateValue]) {
        [Utils showAlert:NSLocalizedString(@"Confirm", nil) withTitle:NSLocalizedString(@"Alert", nil) andMessage:NSLocalizedString(@"LifeLogExist", nil)];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"call");

    [self.imageButton setImage:[UIImage imageNamed:@"write_camera_off.png"] forState:UIControlStateNormal];
    [self.imageButton setImage:[UIImage imageNamed:@"write_camera_on.png"] forState:UIControlStateHighlighted];

    [self.mapButton setImage:[UIImage imageNamed:@"write_map_off.png"] forState:UIControlStateNormal];
    [self.mapButton setImage:[UIImage imageNamed:@"write_map_on.png"] forState:UIControlStateHighlighted];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	NSLog(@"call");
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIActionSheet delegate

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"call");
	
	UIImagePickerController *_picker = [[UIImagePickerController alloc] init];
	_picker.delegate = self;
	_picker.allowsEditing = YES;
	
	switch (buttonIndex) {
		case 0:
			_picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			[self presentModalViewController:_picker animated:YES];
			break;
		case 1:
			_picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentModalViewController:_picker animated:YES];
			break;
		default:
			[_picker release];
			break;
	}
	
}

#pragma mark - UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSLog(@"call");
	
    self.note.image_yn = [NSNumber numberWithBool:YES];
    
    Resource *_newResource = [Utils insertResource:self.note];
    
    _newResource.type = [NSString stringWithFormat:@"%d", 2]; // 2:이미지, 3:맵
    _newResource.mime = @"image/jpg";
    _newResource.path = @"/Documents";

    NSString *_fileName = [self.note.uuid stringByAppendingString:@".jpg"];
	[Utils setImageFile:self.note.uuid useData:UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerEditedImage], 1.0) withName:_fileName];
    _newResource.file_name = _fileName;
    
    _newResource.file_size = [Utils getFileSize:self.note.uuid withName:_fileName];
    _newResource.display_sequence = [NSNumber numberWithInt:1];
    
    NSLog(@"[entity]Resource is %@", _newResource);

	[picker dismissModalViewControllerAnimated:YES];
	
	[picker release];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	NSLog(@"call");
	
	[picker dismissModalViewControllerAnimated:YES];
	
	[picker release];
}

#pragma mark - UIPickerView delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSLog(@"call");
	
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];

	NSString *itemKey = [_appDelegate.keys objectAtIndex:row];
	return [_appDelegate.feelDict objectForKey:itemKey];
}

#pragma mark - UIPickerView datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	NSLog(@"call");
	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	NSLog(@"call");
	
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];

	return [_appDelegate.keys count];
}

#pragma mark - UITextView delegate

- (void)textViewDidEndEditing:(UITextView *)textView {
	NSLog(@"call");
	
	[self.note setContent:self.contentTextView.text];
}

#pragma mark - DLStarRating delegate

-(void)newRating:(int)rating {
	NSLog(@"call");
	
	[self.note setRating_score:[NSNumber numberWithInt:rating]];

    [self.pointLabel setText:[[Utils getPoint:rating] stringByAppendingString:@" Points"]];
}

#pragma mark - Event handler

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"call");
	
	[self.contentTextView resignFirstResponder];
}

- (IBAction)saveButtonPressed:(id)sender {
	NSLog(@"call");
	
    if (![self validateValue]) {
        [Utils showAlert:NSLocalizedString(@"Confirm", nil) withTitle:NSLocalizedString(@"Alert", nil) andMessage:NSLocalizedString(@"LifeLogExist", nil)];
        
        return;
    }

    if ([self.note.content isEqualToString:self.contentTextView.text] == NO) {
        [self.note setContent:self.contentTextView.text];
    }
    
    [self.note setTitle:[Utils getTitle:self.note.content]];
    
    [Utils setTextFile:self.note.uuid useData:self.note.content];
    
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([self.note.updated_time compare:[_appDelegate.syncLogInfoBundle objectForKey:@"zb_note"]] == NSOrderedAscending) {
        [self.note setUpdated_time:[_appDelegate.syncLogInfoBundle objectForKey:@"zb_note"]];
    }
    
    [_appDelegate saveContext];

    // Post message on Facebook
    if ([self.note.facebook_yn boolValue]) {
        NSMutableDictionary *_params = [NSMutableDictionary dictionary];
        
        [_params setObject:[self makeFbMessage] forKey:@"message"];
        
        [_params setObject:@"http://apps.facebook.com/test_training/" forKey:@"link"];
        [_params setObject:@"http://a.yfrog.com/img640/5260/2bcl.png" forKey:@"picture"];
        [_params setObject:@"LifeLog" forKey:@"name"];
        [_params setObject:@"Zepa LifeLog" forKey:@"caption"];
        [_params setObject:@"Check you Life! Improve you Life!" forKey:@"description"];
        
        [_appDelegate.facebook requestWithGraphPath:@"me/feed"
                                          andParams:_params
                                      andHttpMethod:@"POST"
                                        andDelegate:_appDelegate];
    }

    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelButtonPressed:(id)sender {
	NSLog(@"cal");
    
    if (self.flagInsert == TR_TYPE_INSERT) {
        LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];

        [Utils deleteDirectory:self.note.uuid];

        [_appDelegate.managedObjectContext deleteObject:self.note];

        [_appDelegate saveContext];
    }

	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)logTimeButtonPressed:(id)sender {
	NSLog(@"call");
	
	[self.contentTextView resignFirstResponder];

	self.actionSheet = [[UIActionSheet alloc] initWithTitle:@""
												   delegate:nil
									      cancelButtonTitle:nil
								     destructiveButtonTitle:nil
									      otherButtonTitles:nil];
	
	self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
	
	UIToolbar *_datePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	[_datePickerToolbar setBarStyle:UIBarStyleBlackOpaque];
	[_datePickerToolbar sizeToFit];
	
	NSMutableArray *_barItems = [[NSMutableArray alloc] init];
	
	UIBarButtonItem *_btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																			   target:self
																			   action:@selector(datePickerCancelPressed:)];
	[_barItems addObject:_btnCancel];
	[_btnCancel release];
	
	UIBarButtonItem *_btnFlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																					  target:self 
																					  action:nil];
	[_barItems addObject:_btnFlexibleSpace];
	[_btnFlexibleSpace release];
	
	UIBarButtonItem *_btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(datePickerDonePressed:)];
	[_barItems addObject:_btnDone];
	[_btnDone release];
	
	[_datePickerToolbar setItems:_barItems animated:NO];
	[_barItems release];
	
	[self.actionSheet addSubview:_datePickerToolbar];
	[_datePickerToolbar release];
	
	[self.datePicker setMinuteInterval:30];

	[self.datePicker setDate:[Utils convertStringToDate:self.note.log_time withFlag:FORMAT_TYPE_FLAG_MIDDLE] animated:YES];
	
	[self.actionSheet addSubview:self.datePicker];
	[self.datePicker release];
	
	[self.actionSheet showInView:self.view];
	[self.actionSheet setBounds:CGRectMake(0, 0, 320, 500)]; 
}

- (IBAction)feelingButtonPressed:(id)sender {
	NSLog(@"call");
	
	[self.contentTextView resignFirstResponder];

	self.actionSheet = [[UIActionSheet alloc] initWithTitle:@""
												   delegate:nil
									      cancelButtonTitle:nil
								     destructiveButtonTitle:nil
									      otherButtonTitles:nil];
	
	self.feelPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
	
	UIToolbar *_datePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	[_datePickerToolbar setBarStyle:UIBarStyleBlackOpaque];
	[_datePickerToolbar sizeToFit];
	
	NSMutableArray *_barItems = [[NSMutableArray alloc] init];
	
	UIBarButtonItem *_btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																			   target:self
																			   action:@selector(feelPickerCancelPressed:)];
	[_barItems addObject:_btnCancel];
	[_btnCancel release];
	
	UIBarButtonItem *_btnFlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																					  target:self 
																					  action:nil];
	[_barItems addObject:_btnFlexibleSpace];
	[_btnFlexibleSpace release];
	
	UIBarButtonItem *_btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(feelPickerDonePressed:)];
	[_barItems addObject:_btnDone];
	[_btnDone release];
	
	[_datePickerToolbar setItems:_barItems animated:NO];
	[_barItems release];
	
	[self.actionSheet addSubview:_datePickerToolbar];
	[_datePickerToolbar release];
	
	[self.feelPicker setDelegate:self];
	[self.feelPicker setDataSource:self];
    [self.feelPicker setShowsSelectionIndicator:YES];
	
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    
	NSInteger _pickKey = [_appDelegate.keys indexOfObject:self.note.feeling];
	
	[self.feelPicker selectRow:_pickKey inComponent:0 animated:YES];
	
	[self.actionSheet addSubview:self.feelPicker];
	[self.feelPicker release];
	
	[self.actionSheet showInView:self.view];
	[self.actionSheet setBounds:CGRectMake(0, 0, 320, 500)];
}

- (IBAction)facebookButtonPressed:(id)sender {
	NSLog(@"call");
	
	[self.contentTextView resignFirstResponder];
    
    if ([self.facebookButton isSelected] == YES) {
        self.facebookButton.selected = NO;
    } else {
        self.facebookButton.selected = YES;
    }

    [self.note setFacebook_yn:[NSNumber numberWithBool:[self.facebookButton isSelected]]];
}

- (IBAction)mapButtonPressed:(id)sender {
	NSLog(@"call");
	
	MapViewController *_mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    [_mapViewController setNote:self.note];
    [_mapViewController setFlagTrType:self.flagInsert];
	[_mapViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	
	[self presentModalViewController:_mapViewController animated:YES];
	[_mapViewController release];
}

- (IBAction)imageButtonPressed:(id)sender {
	NSLog(@"call");
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Picture" 
													   delegate:self 
											  cancelButtonTitle:@"Cancel" 
										 destructiveButtonTitle:nil 
											  otherButtonTitles:@"Take New Photo", @"Choose Existing Photo", nil, nil];
		
		[self.actionSheet showInView:self.view];
		
		[self.actionSheet release];
	} else {
		UIImagePickerController *_picker = [[UIImagePickerController alloc] init];
		[_picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
		[_picker setDelegate:self];
		[_picker setAllowsEditing:YES];
		
		[self presentModalViewController:_picker animated:YES];
	}
}

-(IBAction)datePickerDonePressed:(id)sender {
	NSLog(@"call");

	NSDate *_changeDate = self.datePicker.date;
	
	self.note.log_time = [Utils convertDateToString:_changeDate withFlag:FORMAT_TYPE_FLAG_MIDDLE];

	UIButton *_logTimeButton = (UIButton *)[self.view viewWithTag:1];
    [_logTimeButton setTitle:[Utils convertDateToString:[Utils convertStringToDate:self.note.log_time withFlag:FORMAT_TYPE_FLAG_MIDDLE] withFlag:FORMAT_TYPE_FLAG_READ2] forState:UIControlStateNormal];

	[self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

-(IBAction)datePickerCancelPressed:(id)sender {
	NSLog(@"call");
	
	[self.actionSheet dismissWithClickedButtonIndex:0 animated:YES]; 
}

-(IBAction)feelPickerDonePressed:(id)sender {
	NSLog(@"call");
	
	NSInteger _currentKey = [self.feelPicker selectedRowInComponent:0];

    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    
	self.note.feeling = [_appDelegate.keys objectAtIndex:_currentKey];
	
	[self.feelingButton setTitle:[_appDelegate.feelDict objectForKey:self.note.feeling] forState:UIControlStateNormal];
    [self.feelingButton setBackgroundImage:[UIImage imageNamed:@"write_feel_bg.png"] forState:UIControlStateNormal];

	[self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

-(IBAction)feelPickerCancelPressed:(id)sender {
	NSLog(@"call");
	
	[self.actionSheet dismissWithClickedButtonIndex:0 animated:YES]; 
}

#pragma mark - User defined fuction

- (BOOL)validateValue {
	NSLog(@"call");
	
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *_managedObjectContext = _appDelegate.managedObjectContext;
    NSFetchRequest *_request = [[NSFetchRequest alloc] init];
    NSEntityDescription *_entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:_managedObjectContext];
    [_request setEntity:_entity];
    
	NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"log_time = %@ and active = 1", self.note.log_time];
	[_request setPredicate:_predicate];

    NSError *_error = nil;
    NSUInteger _count = [_managedObjectContext countForFetchRequest:_request error:&_error];
    [_request release];
	
    if (!_error && _count > 1){
        return NO;
    } 
    
    return YES;
}

- (NSString *)makeFbMessage {
	NSLog(@"call");
    
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *_returnString = [NSString stringWithFormat:@"[%@] %@", [_appDelegate.feelDict objectForKey:self.note.feeling], [NSString stringWithString:self.note.content]];
    
    int _loopCnt = [self.note.rating_score intValue];
    for (int i = 0; i < _loopCnt; i++) {
        if (i == 0) {
            _returnString = [@"* " stringByAppendingString:_returnString];
        } else {
            _returnString = [@"*" stringByAppendingString:_returnString];
        }
    }
    
    return _returnString;
}

@end
