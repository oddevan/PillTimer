//
//  DoseStore.m
//  PillTimer
//
//  Created by Evan Hildreth on 2/18/13.
//  Copyright (c) 2013 Evan Hildreth. All rights reserved.
//

#import "DoseStore.h"

static DoseStore *defaultStore = nil;

@implementation DoseStore

+ (NSString *)archivePath
{
	NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [documentDirectories objectAtIndex:0];
	return [documentDirectory stringByAppendingPathComponent:@"doses.data"];
}

+ (DoseStore *)defaultStore
{
	if (!defaultStore) {
		defaultStore = [[super allocWithZone:NULL] init];
	}
	
	return defaultStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
	return [self defaultStore];
}

- (id)init
{
	if (defaultStore) return defaultStore;
	
	self = [super init];	
	return self;
}

- (NSMutableArray *)allRecentDoses
{
	[self loadDosesIfNecessary];
    [_allRecentDoses sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2];
    }];
	return _allRecentDoses;
}

- (int)numberOfDoses
{
	[self loadDosesIfNecessary];
	return _allRecentDoses.count;
}

- (void)addDose:(NSDate *)newDose
{
	[self loadDosesIfNecessary];
	[_allRecentDoses addObject:newDose];
}

- (void)removeDose:(NSDate *)removeThis
{
	[_allRecentDoses removeObject:removeThis];
}

- (void)removeDoses:(NSArray *)removeThese
{
	[_allRecentDoses removeObjectsInArray:removeThese];
}

- (void)removeAllDoses
{
	[_allRecentDoses removeAllObjects];
}

- (void)loadDosesIfNecessary
{
	if (!_allRecentDoses) {
		_allRecentDoses = [NSKeyedUnarchiver unarchiveObjectWithFile:[DoseStore archivePath]];
	}
	if (!_allRecentDoses) {
		_allRecentDoses = [[NSMutableArray alloc] init];
	}
}

- (BOOL)saveChanges
{
	return [NSKeyedArchiver archiveRootObject:_allRecentDoses toFile:[DoseStore archivePath]];
}

@end
