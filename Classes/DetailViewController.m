//
//  DetailViewController.m
//  LifeLog
//
//  Created by cliff on 11. 4. 7..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import "DetailViewController.h"
#import "MapViewController.h"
#import "LifeLogAppDelegate.h"
#import "Note.h"
#import "Resource.h"
#import "Utils.h"
#import "Global.h"
#import "DLStarRatingControl.h"
#import "QuartzCore/QuartzCore.h"
#import "GADBannerView.h"

@implementation DetailViewController

@synthesize note = __note;

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
    
	[__note release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
	NSLog(@"call");
    
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)loadView {
	NSLog(@"call");
    
	[super loadView];

    // Log Date Title Button
	UIButton *_logDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_logDateButton setFrame:CGRectMake(71,7,190,30)];
	[_logDateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_logDateButton setTitle:@"No Title" forState:UIControlStateNormal];
    [_logDateButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_logDateButton setUserInteractionEnabled:NO];
	[self.navigationItem setTitleView:_logDateButton];

    // Main ScrollView
    UIScrollView *_scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_scrollView setContentSize:CGSizeMake(320, 621)];
    [_scrollView setScrollEnabled:YES];
    [_scrollView setScrollsToTop:YES];
    [_scrollView setBounces:YES];
    [_scrollView setAutoresizesSubviews:YES];
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_scrollView setUserInteractionEnabled:YES];
    [_scrollView setBackgroundColor:RGB(247, 244, 237)];
    [_scrollView setTag:1];
	//scrollView.delegate = self;
	
    // Star Rating Label
    DLStarRatingControl *_customNumberOfStars = [[DLStarRatingControl alloc] initWithFrame:CGRectMake(70, 5, 120, 30) andStars:5];
    [_customNumberOfStars setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
	[_customNumberOfStars setRating:0];
    [_customNumberOfStars setDelegate:self];
	[_customNumberOfStars setBackgroundColor:RGB(247, 244, 237)];
    [_customNumberOfStars setOpaque:YES];
    [_customNumberOfStars setTag:2];
    [_customNumberOfStars setEnabled:NO];
	[_scrollView addSubview:_customNumberOfStars];
    [_customNumberOfStars release];

    // Emotion Label
	UILabel *_feelLabel = [[UILabel alloc] initWithFrame:CGRectMake(205, 5, 55, 30)];
    [_feelLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [_feelLabel setTextColor:[UIColor darkGrayColor]];
    [_feelLabel setTextAlignment:UITextAlignmentLeft];
	[_feelLabel setBackgroundColor:RGB(247, 244, 237)];
    [_feelLabel setOpaque:YES];
    [_feelLabel setTag:5];
	[_scrollView addSubview:_feelLabel];
    [_feelLabel release];

    // Bar Image
    UIImageView *_barImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 320, 4)];
    [_barImage setImage:[UIImage imageNamed:@"write_top_line_purple.png"]];
    [_barImage setOpaque:YES];
    [_barImage setTag:6];
	[_scrollView addSubview:_barImage];
    [_barImage release];

    // Contents View
	UIView *_contentsView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 483)];
    [_contentsView setBackgroundColor:RGB(226, 228, 235)];
    [_contentsView setOpaque:YES];
    [_contentsView setTag:7];
    
    // Sticker Contents View
	UIView *_stickerContentsView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 310, 445)];
    [_stickerContentsView setBackgroundColor:[UIColor whiteColor]];
    [_stickerContentsView setOpaque:YES];
    [_stickerContentsView setTag:8];
    [_stickerContentsView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [_stickerContentsView.layer setBorderWidth:1.0];
    
    // Text View
    UITextView *_textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, 300, 100)];
    [_textView setFont:[UIFont systemFontOfSize:14]];
    [_textView setBackgroundColor:[UIColor whiteColor]];
    [_textView setOpaque:YES];
    [_textView setTag:9];
    [_textView setEditable:NO];
    [_textView setDataDetectorTypes:UIDataDetectorTypeAll];
    [_textView setScrollEnabled:NO];
    [_textView setAutoresizesSubviews:NO];
	[_stickerContentsView addSubview:_textView];
    [_textView release];
    
    // Image View
    UIImageView *_camImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 110, 300, 300)];
    [_camImage setImage:[UIImage imageNamed:@"write_camera_on.png"]];
    [_camImage setTag:10];
    [_stickerContentsView addSubview:_camImage];
    [_camImage release];
    
    // Info View
	UIView *_infoContentsView = [[UIView alloc] initWithFrame:CGRectMake(5, 415, 300, 22)];
    [_infoContentsView setBackgroundColor:[UIColor clearColor]];
    [_infoContentsView setOpaque:YES];
    [_infoContentsView setTag:11];
	
    // GPS Label
	UIButton *_gpsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 195, 22)];
    [_gpsButton addTarget:self action:@selector(buttonMapPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_gpsButton setBackgroundImage:[UIImage imageNamed:@"view_status_bar_map.png"] forState:UIControlStateNormal];
    [_gpsButton setOpaque:YES];
    [_gpsButton setTag:12];
    [_gpsButton setTitle:@"Lat: 37.6100, Lon: 126.9774" forState:UIControlStateNormal];
    [_gpsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_gpsButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [_gpsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_gpsButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 25.0, 0.0, 0.0)];
	[_infoContentsView addSubview:_gpsButton];
    [_gpsButton release];

    // Facebook Image
    UIButton *_fbButton = [[UIButton alloc] initWithFrame:CGRectMake(195, 0, 105, 22)];
    [_fbButton setBackgroundImage:[UIImage imageNamed:@"view_status_bar_facebook.png"] forState:UIControlStateNormal];
    [_fbButton setUserInteractionEnabled:NO];
    [_fbButton setOpaque:YES];
    [_fbButton setTag:13];
    [_fbButton setTitle:@"Facebook" forState:UIControlStateNormal];
    [_fbButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_fbButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [_fbButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_fbButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 32.0, 0.0, 0.0)];
    [_infoContentsView addSubview:_fbButton];
    [_fbButton release];
    
    [_stickerContentsView addSubview:_infoContentsView];
    [_infoContentsView release];

    [_contentsView addSubview:_stickerContentsView];
    [_stickerContentsView release];

    // Doc Info View
	UIView *_dinfoContentsView = [[UIView alloc] initWithFrame:CGRectMake(0, 455, 320, 28)];
    [_dinfoContentsView setBackgroundColor:[UIColor clearColor]];
    [_dinfoContentsView setOpaque:YES];
    [_dinfoContentsView setTag:14];
	
    // Logo Image View
    UIImageView *_logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 96, 18)];
    [_logoImage setImage:[UIImage imageNamed:@"zepalogo.png"]];
    [_logoImage setTag:15];
    [_dinfoContentsView addSubview:_logoImage];
    [_logoImage release];
    
    // Timestamp Label
    UILabel *_timeStampLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 5, 130, 18)];
    [_timeStampLabel setFont:[UIFont systemFontOfSize:12]];
    [_timeStampLabel setTextColor:[UIColor darkGrayColor]];
    [_timeStampLabel setTextAlignment:UITextAlignmentRight];
    [_timeStampLabel setBackgroundColor:[UIColor clearColor]];
    [_timeStampLabel setOpaque:YES];
    [_timeStampLabel setTag:16];
    [_timeStampLabel setText:@"2011-04-08 16:55:21"];
    [_dinfoContentsView addSubview:_timeStampLabel];
    [_timeStampLabel release];
    
    [_contentsView addSubview:_dinfoContentsView];
    [_dinfoContentsView release];

    [_scrollView addSubview:_contentsView];
    [_contentsView release];
    
    // Embed AdMob
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (_appDelegate.gadbannerView != nil) {
        CGRect gadBannerFrame = _appDelegate.gadbannerView.frame;
        gadBannerFrame.origin.y = _contentsView.frame.origin.y + _contentsView.frame.size.height;
        [_appDelegate.gadbannerView setFrame:gadBannerFrame];
        [_scrollView addSubview:_appDelegate.gadbannerView];
    } else {
        [CaulyViewController moveBannerAD:nil caulyParentview:_scrollView xPos:0 yPos:(_contentsView.frame.origin.y + _contentsView.frame.size.height)];
    }
    
    [self.view addSubview:_scrollView];
    [_scrollView release];
}

- (void)viewDidLoad {
	NSLog(@"call");

    UIBarButtonItem *_removeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:_removeButton];
    [_removeButton release];

    [super viewDidLoad];
}

- (void)viewDidUnload {
	NSLog(@"call");
	
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"call");
    
    [super viewWillAppear:animated];

    BOOL _image_yn = YES;
    
    NSSet *_rowSet = [self.note valueForKey:@"resources"];
    
    NSEnumerator *_enumerator = [_rowSet objectEnumerator];
    Resource *_camResource;
    
    while ((_camResource = [_enumerator nextObject])) {
        NSInteger _type = [_camResource.type intValue];
        if(_type == 2) {
            break;
        }
    }
    
	UIButton *_logDateButton = (UIButton *)self.navigationItem.titleView;
	[_logDateButton setTitle:[Utils convertDateToString:[Utils convertStringToDate:self.note.log_time withFlag:FORMAT_TYPE_FLAG_MIDDLE] withFlag:FORMAT_TYPE_FLAG_READ2] forState:UIControlStateNormal];
    
	int _curScore = [self.note.rating_score intValue];
	DLStarRatingControl *_customNumberOfStars = (DLStarRatingControl *)[self.view viewWithTag:2];
    [_customNumberOfStars setRating:_curScore];
    
	if ([self.note.feeling intValue] != 0) {
        LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];

        UILabel *_feelLabel = (UILabel *)[self.view viewWithTag:5];
		[_feelLabel setText:[_appDelegate.feelDict objectForKey:self.note.feeling]];
	}
    
    UITextView *_textView = (UITextView *)[self.view viewWithTag:9];
	[_textView setText:self.note.content];
    CGRect _textViewFrame = _textView.frame;
    _textViewFrame.size.height = _textView.contentSize.height;
    [_textView setFrame:_textViewFrame];

    UIImageView *_camImage = (UIImageView *)[self.view viewWithTag:10];
    CGRect _camImageFrame = _camImage.frame;
    if ([self.note.image_yn boolValue]) {
        UIImage *_camImageImage;
        if ([Utils isExistFile:self.note.uuid withName:_camResource.file_name]) {
            _camImageImage = [[[UIImage alloc] initWithData:[Utils getImageFile:self.note.uuid withName:_camResource.file_name]] autorelease];
        } else {
            _camImageImage = [[[UIImage alloc] initWithData:[Utils retrieveImageFile:self.note.uuid useFileId:_camResource.file_id withName:_camResource.file_name]] autorelease];
            if (_camImageImage == nil) {
                [_camImage setHidden:YES];
                _image_yn = NO;
            }
        }
        
        if (_image_yn) {
            [_camImage setImage:_camImageImage];
            [_camImage setHidden:NO];
            _camImageFrame.size.height = _camImageImage.size.height / _camImageImage.size.width * _camImageFrame.size.width;
            _camImageFrame.origin.y = (_textView.frame.origin.y + _textView.frame.size.height) + 5;
            [_camImage setFrame:_camImageFrame];
        }
    } else {
        [_camImage setHidden:YES];
        _image_yn = NO;
    }

    UIButton *_gpsButton = (UIButton *)[self.view viewWithTag:12];
    [_gpsButton setTitle:[NSString stringWithFormat:@"Lat: %.3f, Lon: %.3f", [self.note.latitude floatValue], [self.note.longitude floatValue]] forState:UIControlStateNormal];

    UIButton *_fbButton = (UIButton *)[self.view viewWithTag:13];
    if ([self.note.facebook_yn boolValue]) {
        [_fbButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    } else {
        [_fbButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    UIView *_infoContentsView = (UIView *)[self.view viewWithTag:11];
    CGRect _infoContentsFrame = _infoContentsView.frame;
    if (_image_yn) {
        _infoContentsFrame.origin.y = (_camImage.frame.origin.y + _camImage.frame.size.height) + 5;
    } else {
        _infoContentsFrame.origin.y = (_textView.frame.origin.y + _textView.frame.size.height) + 5;
    }
    [_infoContentsView setFrame:_infoContentsFrame];

    UIView *_stickerContentsView = (UIView *)[self.view viewWithTag:8];
    CGRect _stickerContentsViewFrame = _stickerContentsView.frame;
    if (_image_yn) {
        _stickerContentsViewFrame.size.height = 5 + _textView.frame.size.height + 5 + _camImage.frame.size.height + 5 + _infoContentsView.frame.size.height + 5;
    } else {
        _stickerContentsViewFrame.size.height = 5 + _textView.frame.size.height + 5 + _infoContentsView.frame.size.height + 5;
    }
    [_stickerContentsView setFrame:_stickerContentsViewFrame];
	
    UILabel *_timeStampLabel = (UILabel *)[self.view viewWithTag:16];
    [_timeStampLabel setText:[Utils convertDateToString:[NSDate dateWithTimeIntervalSince1970:([self.note.created_time unsignedLongLongValue] / 1000)] withFlag:FORMAT_TYPE_FLAG_FULL]];
    
    UIView *_dinfoContentsView = (UIView *)[self.view viewWithTag:14];
    CGRect _dinfoContentsFrame = _dinfoContentsView.frame;
    _dinfoContentsFrame.origin.y = (_stickerContentsView.frame.origin.y + _stickerContentsView.frame.size.height) + 5;
    [_dinfoContentsView setFrame:_dinfoContentsFrame];

    UIView *_contentsView = (UIView *)[self.view viewWithTag:7];
    CGRect _contentsViewFrame = _contentsView.frame;
    _contentsViewFrame.size.height = 5 + _stickerContentsView.frame.size.height + 5 + _dinfoContentsView.frame.size.height + 5;
    [_contentsView setFrame:_contentsViewFrame];
    
    // Set AdMob
    UIScrollView *_scrollView = (UIScrollView *)[self.view viewWithTag:1];

    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (_appDelegate.gadbannerView != nil) {
        GADBannerView *_bannerView = (GADBannerView *)[self.view viewWithTag:1000];
        CGRect _gadBannerFrame = _bannerView.frame;
        _gadBannerFrame.origin.y = _contentsView.frame.origin.y + _contentsView.frame.size.height;
        [_bannerView setFrame:_gadBannerFrame];
    } else {
        [CaulyViewController moveBannerAD:nil caulyParentview:_scrollView xPos:0 yPos:(_contentsView.frame.origin.y + _contentsView.frame.size.height)];
    }
    
    float _newScrollContentsHeight = 0;
    if (_appDelegate.gadbannerView != nil) {
        _newScrollContentsHeight = 20 + 43 + _contentsView.frame.size.height + 50;
    } else {
        _newScrollContentsHeight = 20 + 43 + _contentsView.frame.size.height + 48;
    }
    
    if (_newScrollContentsHeight < 437) {
        [_scrollView setContentSize:CGSizeMake(320, 437)];
    } else {
        [_scrollView setContentSize:CGSizeMake(320, _newScrollContentsHeight)];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"call");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - DLStarRating delegate

-(void)newRating:(int)rating {
	NSLog(@"call");
}

#pragma mark - Event handler

- (IBAction)removeButtonPressed:(id)sender {
	NSLog(@"call");
    
    [self.note setActive:[NSNumber numberWithBool:NO]];

    int64_t _epoch_time = ([[NSDate date] timeIntervalSince1970] * 1000);
    [self.note setUpdated_time:[NSNumber numberWithLongLong:_epoch_time]];
    
    [self.note setUpdate_count:[NSNumber numberWithInt:[self.note.update_count intValue] + 1]];
    
    [Utils deleteDirectory:self.note.uuid];

    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    [_appDelegate saveContext];

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonMapPressed:(id)sender {
	NSLog(@"call");
	
	MapViewController *_mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    [_mapViewController setNote:self.note];
    [_mapViewController setFlagTrType:TR_TYPE_READ];
	[_mapViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	
	[self presentModalViewController:_mapViewController animated:YES];
	[_mapViewController release];
}

@end
