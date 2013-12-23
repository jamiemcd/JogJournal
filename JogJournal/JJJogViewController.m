//
//  JJJogViewController.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/20/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "JJJogViewController.h"
#import <MapKit/MapKit.h>
#import "Jog+AdditionalMethods.h"
#import "Location+AdditionalMethods.h"
#import "JJCoreDataManager.h"


@interface JJJogViewController () <MKMapViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *barButtonItem;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) MKPolyline *polyline;

@property (nonatomic, strong) NSArray *viewConstraints;

@end

@implementation JJJogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self createUI];
    [self updateUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataManagerNewLocationAddedToActiveJogHandler:) name:JJCoreDataManagerNewLocationAddedToActiveJog object:[JJCoreDataManager sharedManager]];
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    // mapView
    self.mapView = [[MKMapView alloc] init];
    [self.mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateUI
{
    Jog *jog = self.jog;
    if (!jog)
    {
        jog = [JJCoreDataManager sharedManager].activeJog;
    }
    if (jog)
    {
        if (jog.endDate)
        {
            self.title = [NSString stringWithFormat:@"%@ %@", [jog distanceString], [jog durationString]];
            self.barButtonItem = nil;
        }
        else
        {
            self.title = @"Active Jog";
            self.barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Complete" style:UIBarButtonItemStylePlain target:self action:@selector(completeButtonTouchHandler:)];
        }
        self.navigationItem.rightBarButtonItem = self.barButtonItem;
        
        // Draw the jog locations on the map
        NSUInteger locationsCount = [jog.locations count];
        CLLocationCoordinate2D *coordinatesArray = malloc(sizeof(CLLocationCoordinate2D) * locationsCount);
        for (int i = 0; i < locationsCount; i++)
        {
            Location *location = jog.locations[i];
            coordinatesArray[i] = CLLocationCoordinate2DMake([location.latitude doubleValue], [location.longitude doubleValue]);
        }
        [self.mapView removeOverlay:self.polyline];
        self.polyline = [MKPolyline polylineWithCoordinates:coordinatesArray count:locationsCount];
        [self.mapView addOverlay:self.polyline level:MKOverlayLevelAboveRoads];
        if (locationsCount > 0)
        {
            if (jog.endDate)
            {
                [self zoomToBestZoomForCompletedJog];
            }
            else
            {
                CLLocationCoordinate2D currentCoordinate = coordinatesArray[locationsCount - 1];
                
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentCoordinate, 50, 50);
                [self.mapView setRegion:region animated:YES];
            }
        }
        free(coordinatesArray);
    }
    else
    {
        self.title = @"New Jog";
        self.barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(startButtonTouchHandler:)];
        self.navigationItem.rightBarButtonItem = self.barButtonItem;
    }
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if (self.viewConstraints)
    {
        [self.view removeConstraints:self.viewConstraints];
    }
    
    NSDictionary *views = @{ @"mapView": self.mapView };
    
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]|" options:0 metrics:nil views:views]];
    
    self.viewConstraints = [constraints copy];
    [self.view addConstraints:self.viewConstraints];

}

- (void)zoomToBestZoomForCompletedJog
{
    CLLocationDegrees northernMostLatitude;
    CLLocationDegrees southernMostLatitude;
    CLLocationDegrees easternMostLongitude;
    CLLocationDegrees westernMostLongitude;
    
    NSUInteger count = [self.jog.locations count];
    for (int i = 0; i < count; i++)
    {
        Location *location = self.jog.locations[i];
        if (i == 0)
        {
            northernMostLatitude = [location.latitude doubleValue];
            southernMostLatitude = [location.latitude doubleValue];
            easternMostLongitude = [location.longitude doubleValue];
            westernMostLongitude = [location.longitude doubleValue];
        }
        else
        {
            northernMostLatitude = ([location.latitude doubleValue] > northernMostLatitude) ? [location.latitude doubleValue] : northernMostLatitude;
            southernMostLatitude = ([location.latitude doubleValue] < southernMostLatitude) ? [location.latitude doubleValue] : southernMostLatitude;
            easternMostLongitude = ([location.longitude doubleValue] > easternMostLongitude) ? [location.longitude doubleValue] : easternMostLongitude;
            westernMostLongitude = ([location.longitude doubleValue] < westernMostLongitude) ? [location.longitude doubleValue] : westernMostLongitude;
        }
    }
    
    MKMapPoint swPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(southernMostLatitude, westernMostLongitude));
    MKMapRect swRect = MKMapRectMake(swPoint.x, swPoint.y, 0, 0);
    
    MKMapPoint nePoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(northernMostLatitude, easternMostLongitude));
    MKMapRect neRect = MKMapRectMake(nePoint.x, nePoint.y, 0, 0);
    
    MKMapRect rect = MKMapRectUnion(swRect, neRect);
    
    [self.mapView setVisibleMapRect:rect edgePadding:UIEdgeInsetsMake(70, 20, 20, 20) animated:YES];
}

- (void)startButtonTouchHandler:(UIBarButtonItem *)barButtonItem
{
    [[JJCoreDataManager sharedManager] startNewJog];
    [self updateUI];
}

- (void)completeButtonTouchHandler:(UIBarButtonItem *)barButtonItem
{
    [[JJCoreDataManager sharedManager] completeActiveJog];
}

- (void)coreDataManagerNewLocationAddedToActiveJogHandler:(NSNotification *)notification
{
    if (!self.jog)
    {
        [self updateUI];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        polylineRenderer.lineWidth = 5.0;
        polylineRenderer.strokeColor = [UIColor purpleColor];
        return polylineRenderer;
    }
    return nil;
}

@end
