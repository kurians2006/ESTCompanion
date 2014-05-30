//
//  ESTCompanion+BeaconStore.m
//  ESTCompanion-Example
//
//  Created by Jonathon Hibbard on 5/30/14.
//  Copyright (c) 2014 estcompanion. All rights reserved.
//

#import "ESTCompanion+BeaconStore.h"
#import "ESTCompanionConstants.h"
#import "ESTBeacon.h"

@implementation ESTCompanion (BeaconStore)

#pragma mark -
#pragma mark Private Method(s)
#pragma mark -

+(NSString *)stringForBeaconStoreInfoKey:(kBeaconStoreInfo)key {
    static NSString *defaultKeyName = @"ESTBeacons";
    
    switch( key ) {
        case kBeaconStoreInfoDefaultKeyName: return defaultKeyName;
        default: return nil;
    }
}


#pragma mark -
#pragma mark Public Methods
#pragma mark -

#pragma mark - Methods using kBeaconStoreTypes

+(ESTBeacon *)obtainBeaconFromStoreTypes:(kBeaconStores)storageTypes havingKeyName:(NSString *)keyName {
    if( storageTypes & kBeaconStoresDefault ) {
        return [[self class] obtainBeaconFromUserDefaultsWithKeyName:keyName];
    }

    return nil;
}

+(ESTBeacon *)obtainBeaconFromUserDefaultsWithKeyName:(NSString *)keyName {
    return [DEFAULTS objectForKey:keyName];
}

+(void)saveBeacon:(ESTBeacon *)beacon toStores:(kBeaconStores)storageTypes usingKeyName:(NSString *)keyName {

    if( storageTypes & kBeaconStoresDefault ) {
        [[self class] saveToUserDefaultsUsingBeacon:beacon keyName:keyName];
    }
}

+(void)saveToUserDefaultsUsingBeacon:(ESTBeacon *)beacon keyName:(NSString *)keyName {

    NSData *beaconInfo = [NSKeyedArchiver archivedDataWithRootObject:beacon];
    DEFAULTS_SET(keyName, beaconInfo);

    NSLog( @"Beacon received and stored in NSUserDefaults..." );
}

+(void)saveBeaconsInArray:(NSArray *)beacons usingStoreTypes:(kBeaconStores)storageTypes {
    if( [beacons count] == 0 ) {
        NSLog( @"There are no beacons found in the received array to store.  storeBeaconsInArray returning without saving anything." );
        return;
    }
    
    if( storageTypes & kBeaconStoresDefault ) {
        [[self class] saveToDefaultsUsingBeacons:beacons];
    }
}

+(void)saveBeaconsInArray:(NSArray *)beacons usingStoreTypes:(kBeaconStores)storageTypes withKeyName:(NSString *)keyName {
    
    if( [beacons count] == 0 ) {
        NSLog( @"There are no beacons found in the received array to store.  storeBeaconsInArray returning without saving anything." );
        return;
    }

    if( storageTypes & kBeaconStoresDefault ) {
        [[self class] saveToDefaultsUsingBeacons:beacons withStorageKeyName:keyName];
    }
}

/**
 * @todo Should update this to support appending/merging other storage types to a mutable array and returning the result.
 */
+(NSArray *)obtainBeaconsFromStoreTypes:(kBeaconStores)storageType {
    if( storageType & kBeaconStoresDefault ) {
        return [[self class] obtainBeaconsFromDefaults];
    }
    
    return nil;
}

+(NSArray *)obtainBeaconsFromStoreTypes:(kBeaconStores)storageType usingStorageKeyName:(NSString *)keyName {
    if( storageType & kBeaconStoresDefault ) {
        return [[self class] obtainBeaconsFromDefaultsWithKeyName:keyName];
    }
    
    return nil;
}


#pragma mark - NSUserDefaults Storage Methods

/**
 * @todo Perhaps we need a way to specify the location to use as well?
 */
+(void)saveToDefaultsUsingBeacons:(NSArray *)beacons {
    NSString *storageKey = [[self class] stringForBeaconStoreInfoKey:kBeaconStoreInfoDefaultKeyName];
    [self saveToDefaultsUsingBeacons:beacons withStorageKeyName:storageKey];
}

+(void)saveToDefaultsUsingBeacons:(NSArray *)beacons withStorageKeyName:(NSString *)keyName {
    NSMutableArray *storageData = [NSMutableArray array];
    for( ESTBeacon *beacon in beacons ) {
        NSData *beaconInfo = [NSKeyedArchiver archivedDataWithRootObject:beacon];
        [storageData addObject:beaconInfo];
    }
    
    DEFAULTS_SET(keyName, storageData);
    NSLog( @"Beacons received and stored in NSUserDefaults..." );
}

+(NSArray *)obtainBeaconsFromDefaults {
    NSString *storageKey = [[self class] stringForBeaconStoreInfoKey:kBeaconStoreInfoDefaultKeyName];
    return [DEFAULTS arrayForKey:storageKey];
}

+(NSArray *)obtainBeaconsFromDefaultsWithKeyName:(NSString *)keyName {
    return [DEFAULTS arrayForKey:keyName];
}

@end
