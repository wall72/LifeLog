//
//  MapViewController.h
//  LifeLog
//
//  Created by cliff on 11. 3. 10..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class Note;
@class MapViewMarker;

@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate> {

}

@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UIButton *refreshButton;
@property (nonatomic, retain) IBOutlet MKMapView *logMapView;
@property (nonatomic, retain) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, retain) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *actIndicator;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) Note *note;
@property (nonatomic, retain) MapViewMarker *mapViewMarker;
@property (nonatomic, assign) BOOL flagCLUpdating;
@property (nonatomic, assign) BOOL flagTrType;

- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)refreshButtonPressed:(id)sender;

@end
