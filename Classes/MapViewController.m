//
//  MapViewController.m
//  LifeLog
//
//  Created by cliff on 11. 3. 10..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import "MapViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Note.h"
#import "Resource.h"
#import "MapViewMarker.h"
#import "Utils.h"
#import "Global.h"

@interface MKMapView (Additions)
- (UIImageView*)googleLogo;
@end

@implementation MKMapView (Additions)
- (UIImageView*)googleLogo {
	UIImageView *imgView = nil;
	for (UIView *subview in self.subviews) {
		if ([subview isMemberOfClass:[UIImageView class]]) {
			imgView = (UIImageView*)subview;
			break;
		}
	}
	
	return imgView;
}
@end

@interface MapViewController ()
- (void)startCLLocation;
- (void)setPosition;
- (void)relocateGoogleLogo;
@end

@implementation MapViewController

@synthesize navigationBar = _navigationBar;
@synthesize refreshButton = _refreshButton;
@synthesize logMapView = _logMapView;
@synthesize latitudeLabel = _latitudeLabel;
@synthesize longitudeLabel = _longitudeLabel;
@synthesize actIndicator = _actIndicator;
@synthesize locationManager = __locationManager;
@synthesize note = __note;
@synthesize mapViewMarker = __mapViewMarker;
@synthesize flagCLUpdating = __flagCLUpdating;
@synthesize flagTrType = __flagTrType;

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
    [_refreshButton release];
	[_logMapView release];
	[_latitudeLabel release];
	[_longitudeLabel release];
    [_actIndicator release];
    [__locationManager release];
    [__note release];
    [__mapViewMarker release];
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
}

- (void)viewDidUnload {
	NSLog(@"call");
	
    [super viewDidUnload];
    self.navigationBar = nil;
    self.refreshButton = nil;
	self.logMapView = nil;
	self.latitudeLabel = nil;
	self.longitudeLabel = nil;
    self.actIndicator = nil;
    self.locationManager = nil;
//  self.note = nil;
    self.mapViewMarker = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"call");
    
	[super viewWillAppear:animated];

    // self.mapViewLog.showsUserLocation = YES;

    [self.actIndicator startAnimating];
	
    if (self.flagTrType == TR_TYPE_INSERT) {
        [self.logMapView setZoomEnabled:YES];
        [self.logMapView setScrollEnabled:YES];
        
        [self.refreshButton setHidden:NO];
        
        [self startCLLocation];
    } else if (self.flagTrType == TR_TYPE_EDIT) {
        [self.logMapView setZoomEnabled:YES];
        [self.logMapView setScrollEnabled:YES];

        [self.refreshButton setHidden:NO];
        
        // 지도 표시
        [self setPosition];
    } else {
        [self.logMapView setZoomEnabled:NO];
        [self.logMapView setScrollEnabled:NO];
        
        UINavigationItem *_item = [self.navigationBar.items objectAtIndex:0];
        _item.rightBarButtonItem = nil;
        [self.refreshButton setHidden:YES];
        
        // 지도 표시
        [self setPosition];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"call");
	
	[super viewWillDisappear:animated];
    
    // self.mapViewLog.showsUserLocation = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	NSLog(@"call");
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSLog(@"call");
	
	CLLocation *_curPos = self.locationManager.location;
    
    self.mapViewMarker = [[[MapViewMarker alloc] init] autorelease];
    
    [self.mapViewMarker setCoordinate:_curPos.coordinate];

    [self.latitudeLabel setText:[NSString stringWithFormat:@"%.3f", self.mapViewMarker.coordinate.latitude]];
    [self.longitudeLabel setText:[NSString stringWithFormat:@"%.3f", self.mapViewMarker.coordinate.longitude]];
    
	CLLocationCoordinate2D _mapCenter;
	_mapCenter.latitude = self.mapViewMarker.coordinate.latitude;
	_mapCenter.longitude = self.mapViewMarker.coordinate.longitude;
    
	MKCoordinateSpan _mapSpan;
	_mapSpan.latitudeDelta = 0.005;
	_mapSpan.longitudeDelta = 0.005;
    
	MKCoordinateRegion _mapRegion;
	_mapRegion.center = _mapCenter;
	_mapRegion.span = _mapSpan;
    
    [self.logMapView setRegion:_mapRegion];
    [self.logMapView setMapType:MKMapTypeStandard];

    [self.actIndicator stopAnimating];

	[self.logMapView addAnnotation:self.mapViewMarker];

	[self.locationManager stopUpdatingLocation];
	self.locationManager = nil;
    
    [self setFlagCLUpdating:NO];
}

- (void)locationManager:(CLLocationManager *)didFailWithError :(NSError *)error {
	NSLog(@"call");

    [self.actIndicator stopAnimating];

    [self.logMapView removeAnnotation:self.mapViewMarker];

	[self.locationManager stopUpdatingLocation];

    switch([error code]) {
        case kCLErrorNetwork: // general, network-related error
            [Utils showAlert:NSLocalizedString(@"Confirm", nil) withTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"CheckNetwork", nil)];
            break;
        case kCLErrorDenied:
            [Utils showAlert:NSLocalizedString(@"Confirm", nil) withTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"CheckGPS", nil)];
            break;

        default:
            [Utils showAlert:NSLocalizedString(@"Confirm", nil) withTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"NetworkError", nil)];
            break;
    }
}

#pragma mark - MKMapViewDelegate delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	NSLog(@"call");
    
    if (self.flagCLUpdating == NO) {
        CLLocationCoordinate2D _centerCoordinate = mapView.region.center;
        
        [self.mapViewMarker setCoordinate:_centerCoordinate];
        
        [self.latitudeLabel setText:[NSString stringWithFormat:@"%.3f", self.mapViewMarker.coordinate.latitude]];
        [self.longitudeLabel setText:[NSString stringWithFormat:@"%.3f", self.mapViewMarker.coordinate.longitude]];
        
        [mapView removeAnnotation:self.mapViewMarker];
        [mapView addAnnotation:self.mapViewMarker];
    }
}

#pragma mark - Event handler

- (IBAction)saveButtonPressed:(id)sender {
	NSLog(@"call");
	
    [self.note setMap_yn:[NSNumber numberWithBool:YES]];
    
    [self.note setLatitude:[NSNumber numberWithDouble:self.mapViewMarker.coordinate.latitude]];
    [self.note setLongitude:[NSNumber numberWithDouble:self.mapViewMarker.coordinate.longitude]];
        
    [self relocateGoogleLogo];

    UIGraphicsBeginImageContextWithOptions(self.logMapView.bounds.size, NO, 0.0);
    [[self.logMapView layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGImageRef _imageRef;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        // Retina display
        _imageRef = CGImageCreateWithImageInRect([_image CGImage], CGRectMake(166.0, 206.0, 308.0, 332.0));
    } else {
        // non-Retina display
        _imageRef = CGImageCreateWithImageInRect([_image CGImage], CGRectMake(83.0, 103.0, 154.0, 166.0));
    }
    
    UIImage *_cropImage = [UIImage imageWithCGImage:_imageRef];
    CGImageRelease(_imageRef);
    
    Resource *_newResource = [Utils insertResource:self.note];
    
    [_newResource setType:[NSString stringWithFormat:@"%d", 3]]; // 2:이미지, 3:맵
    [_newResource setMime:@"image/jpg"];
    [_newResource setPath:@"/Documents"];
    
    NSString *_fileName = [self.note.uuid stringByAppendingString:@"_map.jpg"];
	[Utils setImageFile:self.note.uuid useData:UIImageJPEGRepresentation(_cropImage, 1.0) withName:_fileName];
    [_newResource setFile_name:_fileName];
    
    [_newResource setFile_size:[Utils getFileSize:self.note.uuid withName:_fileName]];
    
    NSLog(@"[entity]Resource is %@", _newResource);
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)relocateGoogleLogo {
	NSLog(@"call");
	
    UIImageView *logo = [self.logMapView googleLogo];
    
    if (logo == nil) return;
    
    CGRect _frame = logo.frame;
    _frame.origin.x += 83.0;
    _frame.origin.y = 103 + 166 - _frame.size.height - 4;
    logo.frame = _frame;
}

- (IBAction)cancelButtonPressed:(id)sender {
	NSLog(@"call");
	
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)refreshButtonPressed:(id)sender {
	NSLog(@"call");
	
    [self.logMapView removeAnnotation:self.mapViewMarker];

    [self.actIndicator startAnimating];

    [self startCLLocation];
}

#pragma mark - User defined function

- (void)startCLLocation {
	NSLog(@"call");
	
    // Set up CLLocationManager
	self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [self.locationManager setDelegate:self];
	[self.locationManager startUpdatingLocation];
    [self setFlagCLUpdating:YES];
}

- (void)setPosition {
	NSLog(@"call");
	
    CLLocationCoordinate2D _mapCenter;
	_mapCenter.latitude = [self.note.latitude floatValue];
	_mapCenter.longitude = [self.note.longitude floatValue];
    
    self.mapViewMarker = [[[MapViewMarker alloc] init] autorelease];
    [self.mapViewMarker setCoordinate:_mapCenter];
    
	MKCoordinateSpan _mapSpan;
	_mapSpan.latitudeDelta = 0.005;
	_mapSpan.longitudeDelta = 0.005;
    
	MKCoordinateRegion _mapRegion;
	_mapRegion.center = _mapCenter;
	_mapRegion.span = _mapSpan;
    
    [self.logMapView setRegion:_mapRegion];
    [self.logMapView setMapType:MKMapTypeStandard];

    [self.actIndicator stopAnimating];

    [self.logMapView addAnnotation:self.mapViewMarker];

    [self setFlagCLUpdating:NO];
}

@end
