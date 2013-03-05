//
//  DoseStore.h
//  PillTimer
//
//  Created by Evan Hildreth on 2/18/13.
//  Copyright (c) 2013 Evan Hildreth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoseStore : NSObject
{
	NSMutableArray *_allRecentDoses;
}

+ (DoseStore *)defaultStore;
+ (NSString *)archivePath;

- (NSMutableArray *)allRecentDoses;
- (int)numberOfDoses;
- (void)addDose:(NSDate *)newDose;
- (void)removeDose:(NSDate *)removeThis;
- (void)removeDoses:(NSArray *)removeThese;
- (void)removeAllDoses;

- (void)loadDosesIfNecessary;
- (BOOL)saveChanges;

@end
