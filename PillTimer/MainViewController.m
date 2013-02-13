//
//  MainViewController.m
//  PillTimer
//
//  Created by Evan Hildreth on 2/4/13.
//  Copyright (c) 2013 Evan Hildreth. All rights reserved.
//

#import "MainViewController.h"

const NSTimeInterval TwentyFourHourTimeInterval = 86400;
NSString * const PillTimerHourlyPrefKey = @"PillTimerHourlyPrefKey";
NSString * const PillTimerDailyPrefKey = @"PillTimerDailyPrefKey";
NSString * const PillTimerAlertsPrefKey  = @"PillTimerAlertsPrefKey";

@interface MainViewController ()
{
	NSMutableArray *_allRecentDoses;
	NSTimeInterval _doseHourlyInterval;
	int _doseDailyLimit;
	BOOL _alertsOn;
}

- (void)recalculateIndicators;
- (void)setIndicatorsYes;
- (void)setIndicatorsNo:(NSDate *)expiresTime;
- (void)refreshRecentDoses;
- (void)setAlertFor:(NSDate *)fireTime;
- (void)clearAlert;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_doseDailyLimit = [[NSUserDefaults standardUserDefaults] integerForKey:PillTimerDailyPrefKey];
	_doseHourlyInterval = [[NSUserDefaults standardUserDefaults] integerForKey:PillTimerHourlyPrefKey] * 3600;
	_alertsOn = [[NSUserDefaults standardUserDefaults] boolForKey:PillTimerAlertsPrefKey];
}

- (void)viewDidAppear:(BOOL)animated
{
	if ((_doseHourlyInterval <= 0) || (_doseDailyLimit <= 0)) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please configure"
														message:@"Please set the dosage information in settings."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[self showInfo:nil];
	} else {
		[self recalculateIndicators];
	}
}

- (void)viewDidUnload
{
    [self setIndicatorImage:nil];
    [self setIndicatorText:nil];
    [self setRecentDoses:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)recalculateIndicators
{
	BOOL dosesNeedRefresh = NO;
	
	if (_allRecentDoses) {
		NSDate *earliestDose = [NSDate distantFuture];
		NSDate *latestDose = [NSDate distantPast];
		
		for (NSDate *thisDate in _allRecentDoses) {
			if (fabs([thisDate timeIntervalSinceNow]) > TwentyFourHourTimeInterval) {
				[_allRecentDoses removeObject:thisDate];
				dosesNeedRefresh = YES;
			} else {
				if ([thisDate timeIntervalSinceDate:latestDose] > 0) {
					latestDose = thisDate;
				}
				if ([thisDate timeIntervalSinceDate:earliestDose] < 0) {
					earliestDose = thisDate;
				}
			}
		}
		
		if (([_allRecentDoses count] >= _doseDailyLimit) ||
			(fabs([latestDose timeIntervalSinceNow]) < _doseHourlyInterval)) {
			NSDate *earliestDoseExpires = [earliestDose dateByAddingTimeInterval:TwentyFourHourTimeInterval];
			NSDate *latestDoseExpires = [latestDose dateByAddingTimeInterval:_doseHourlyInterval];
			
			if ([_allRecentDoses count] >= _doseDailyLimit &&
				[earliestDoseExpires timeIntervalSinceDate:latestDoseExpires] > 0) {
				if (_alertsOn) [self setAlertFor:earliestDoseExpires];
				[self setIndicatorsNo:earliestDoseExpires];
			} else {
				if (_alertsOn) [self setAlertFor:latestDoseExpires];
				[self setIndicatorsNo:latestDoseExpires];
			}
			
		} else {
			[self setIndicatorsYes];
		}
	} else {
		_allRecentDoses = [[NSMutableArray alloc] init];
		[self setIndicatorsYes];
		dosesNeedRefresh = YES;
	}
	
	if (dosesNeedRefresh) [self refreshRecentDoses];
}

- (void)refreshRecentDoses
{
	NSMutableString *newDoseList = [[NSMutableString alloc] init];
	
	for (NSDate *thisDate in _allRecentDoses) {
		if (newDoseList.length > 0) [newDoseList appendString:@"\n"];
		
		[newDoseList appendString:[NSDateFormatter localizedStringFromDate:thisDate
																 dateStyle:NSDateFormatterNoStyle
																 timeStyle:NSDateFormatterShortStyle]];
	}
	
	self.recentDoses.text = newDoseList;
}

- (IBAction)recordNewDose:(id)sender {
	[_allRecentDoses addObject:[NSDate date]];
	[self refreshRecentDoses];
	[self recalculateIndicators];
}

- (void)setIndicatorsYes
{
	self.indicatorImage.image = [UIImage imageNamed:@"OK.png"];
	self.indicatorText.text = @"You can has";
}

- (void)setIndicatorsNo:(NSDate *)expiresTime
{
	self.indicatorImage.image = [UIImage imageNamed:@"Ex.png"];
	self.indicatorText.text = [NSString stringWithFormat: @"Not until %@",
							   [NSDateFormatter localizedStringFromDate:expiresTime
															  dateStyle:NSDateFormatterNoStyle
															  timeStyle:NSDateFormatterShortStyle]];
}

- (void)setAlertFor:(NSDate *)fireTime
{
	[self clearAlert];
	
	UILocalNotification *alert = [[UILocalNotification alloc] init];
	alert.soundName = @"PillTimerAlert.aif";
	alert.alertBody = NSLocalizedString(@"You may take a dose now", nil);
	alert.fireDate = fireTime;
	
	[[UIApplication sharedApplication] scheduleLocalNotification:alert];
}

- (void)clearAlert
{
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
	_doseDailyLimit = controller.doseDailyLimit.text.intValue;
	[[NSUserDefaults standardUserDefaults] setInteger:controller.doseDailyLimit.text.intValue
											   forKey:PillTimerDailyPrefKey];
	
	_doseHourlyInterval = controller.doseHourlyInterval.text.intValue * 3600;
	[[NSUserDefaults standardUserDefaults] setInteger:controller.doseHourlyInterval.text.intValue
											   forKey:PillTimerHourlyPrefKey];
	
    [self dismissModalViewControllerAnimated:YES];
	
	[self refreshRecentDoses];
	[self recalculateIndicators];
}

- (void)flipsideViewControllerClearDoses:(FlipsideViewController *)controller {
	[_allRecentDoses removeAllObjects];
	[self clearAlert];
}

- (void)flipsideViewController:(FlipsideViewController *)controller changedAlertSettingTo:(BOOL)alertsOn
{
	_alertsOn = alertsOn;
	if (!alertsOn) {
		[self clearAlert];
	}
	
	[[NSUserDefaults standardUserDefaults] setBool:alertsOn forKey:PillTimerAlertsPrefKey];
}

- (IBAction)showInfo:(id)sender
{    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
	controller.doseHourlyInterval.text = [NSString stringWithFormat:@"%d", (int)(_doseHourlyInterval / 3600)];
	controller.doseDailyLimit.text = [NSString stringWithFormat:@"%d", _doseDailyLimit];
	controller.alertSwitch.on = _alertsOn;
}

@end
