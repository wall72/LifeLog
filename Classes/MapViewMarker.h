//
//  MapViewMarker.h
//  LifeLog
//
//  Created by cliff on 11. 3. 24..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface MapViewMarker : NSObject <MKAnnotation> {

}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
