//
//  ViewController.m
//  ESTCompanion-Example
//
//  Created by Jonathon Hibbard on 5/28/14.
//  Copyright (c) 2014 Jonathon Hibbard. All rights reserved.
//

#import "ViewController.h"
#import "beaconTableViewCell.h"
#import "DetailTableViewController.h"

#import "ESTBeaconManager+AutoRegioning.h"
#import "UIColor+Hexcode.h" // Needed just to convert the hexcode for a beacon to a UIColor ( and vice versa )

static NSString * const DEFAULT_BEACON_IDENTIFIER = @"estimoteIdentifier";

@interface ViewController () <ESTBeaconManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion *region;

@property (nonatomic, copy) NSArray *beacons;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end


@implementation ViewController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.beaconManager = [[ESTBeaconManager alloc] initWithOptions:kUUIDGroupInitOptionsAvoidUnknownStateBeacons
                                                          delegate:self
                                                     proximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                        identifier:DEFAULT_BEACON_IDENTIFIER];
    self.selectedIndexPath = nil;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.beaconManager stopRangingBeaconsInRegion];
}

-(void)setBeacons:(NSArray *)beacons {
    if( !_beacons || ![_beacons isEqualToArray:beacons] ) {
        _beacons = [beacons copy];

        [self.tableView reloadData];
    }
}


#pragma mark - ESTBeaconManager Delegate ( default )

-(void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region {
    self.beacons = beacons;
}

#pragma mark -
#pragma mark UITableView Delegate/Datasource
#pragma mark -

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    self.selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"details" sender:self];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 98.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.beacons count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"cellIdentifier";

    beaconTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    ESTBeacon *beacon = self.beacons[(NSUInteger)indexPath.row];

    cell.majorLabel.text = [beacon.major stringValue];
    cell.minorLabel.text = [beacon.minor stringValue];

    cell.proximityLabel.text = [[ESTCompanion sharedInstance] stringFromProximity:beacon.proximity];

    // Comes from the companion...
    cell.identifierLabel.text = [beacon identifier];
    cell.beaconImageView.tintColor = [beacon beaconColor];

    return cell;
}

#pragma mark - unwindBack
-(IBAction)unwindBack:(UIStoryboardSegue *)segue {

    DetailTableViewController *detailTableViewController = (DetailTableViewController *)segue.sourceViewController;

    UIColor *color = [UIColor colorFromHexCode:detailTableViewController.beaconColor];
    NSString *identifier = [detailTableViewController.beaconIdentifier copy];

    ESTBeacon *beacon = self.beacons[(NSUInteger)self.selectedIndexPath.row];
    [beacon setBeaconColor:color];
    [beacon setIdentifier:identifier];

    [beacon syncChangesToStore];
    [self.tableView reloadData];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if( [segue.identifier isEqualToString:@"details"] ) {

        DetailTableViewController *detailTableViewController = (DetailTableViewController *)segue.destinationViewController;

        ESTBeacon *beacon = self.beacons[(NSUInteger)self.selectedIndexPath.row];
        detailTableViewController.beacon = beacon;
    }
}

@end
