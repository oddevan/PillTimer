//
//  MainViewController.m
//  PillTimer
//
//  Created by Evan Hildreth on 2/4/13.
//  Copyright (c) 2013 Evan Hildreth. All rights reserved.
//

#import "MainViewController.h"
#import "DoseStore.h"

const NSTimeInterval TwentyFourHourTimeInterval = 86400;
const NSTimeInterval OneHourTimeInterval = 3600;
NSString * const PillTimerHourlyPrefKey = @"PillTimerHourlyPrefKey";
NSString * const PillTimerDailyPrefKey = @"PillTimerDailyPrefKey";
NSString * const PillTimerAlertsPrefKey  = @"PillTimerAlertsPrefKey";

@interface MainViewController ()
{
	NSTimeInterval _doseHourlyInterval;
	int _doseDailyLimit;
	BOOL _alertsOn;
}

- (void)setIndicatorsYes;
- (void)setIndicatorsNo:(NSDate *)expiresTime;
- (void)setIndicatorsNeutral;
- (void)refreshRecentDoses;
- (void)setAlertFor:(NSDate *)fireTime;
- (void)clearAlert;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_doseDailyLimit = [[NSUserDefaults standardUserDefaults] integerForKey:PillTimerDailyPrefKey];
	_doseHourlyInterval = [[NSUserDefaults standardUserDefaults] integerForKey:PillTimerHourlyPrefKey] * OneHourTimeInterval;
	_alertsOn = [[NSUserDefaults standardUserDefaults] boolForKey:PillTimerAlertsPrefKey];
}

- (void)viewDidAppear:(BOOL)animated
{
	[self recalculateIndicators];
	
	if ((_doseHourlyInterval < 0) || (_doseDailyLimit <= 0)) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", nil)
														message:NSLocalizedString(@"Welcome! Please set the dosage information so we can begin.", nil)
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[self setIndicatorsNeutral];
		//[self showInfo:nil];
	}
}

- (void)viewDidUnload
{
    [self setIndicatorImage:nil];
    [self setIndicatorText:nil];
    [self setRecentDoses:nil];
    [self setIndicatorBigText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)recalculateIndicators
{
	if ([[DoseStore defaultStore] numberOfDoses] > 0) {
		NSDate *earliestDose = [NSDate distantFuture];
		NSDate *latestDose = [NSDate distantPast];
		
		for (NSDate *thisDate in [[DoseStore defaultStore] allRecentDoses]) {
			if (fabs([thisDate timeIntervalSinceNow]) > TwentyFourHourTimeInterval) {
				[[DoseStore defaultStore] removeDose:thisDate];
			} else {
				if ([thisDate timeIntervalSinceDate:latestDose] > 0) {
					latestDose = thisDate;
				}
				if ([thisDate timeIntervalSinceDate:earliestDose] < 0) {
					earliestDose = thisDate;
				}
			}
		}
		
		if (([[DoseStore defaultStore] numberOfDoses] >= _doseDailyLimit) ||
			(fabs([latestDose timeIntervalSinceNow]) < _doseHourlyInterval)) {
			NSDate *earliestDoseExpires = [earliestDose dateByAddingTimeInterval:TwentyFourHourTimeInterval];
			NSDate *latestDoseExpires = [latestDose dateByAddingTimeInterval:_doseHourlyInterval];
			
			if ([[DoseStore defaultStore] numberOfDoses] >= _doseDailyLimit &&
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
	} else if ((_doseHourlyInterval < 0) || (_doseDailyLimit <= 0)) {
		[self setIndicatorsNeutral];
	} else {
		[self setIndicatorsYes];
	}
	
	[self refreshRecentDoses];
}

- (void)refreshRecentDoses
{
	NSMutableString *newDoseList = [[NSMutableString alloc] init];
	
	if ([[DoseStore defaultStore] numberOfDoses] > 0) {
		for (NSDate *thisDate in [[DoseStore defaultStore] allRecentDoses]) {
			if (newDoseList.length > 0) [newDoseList appendString:@"\n"];
			
			[newDoseList appendString:[NSDateFormatter localizedStringFromDate:thisDate
																	 dateStyle:NSDateFormatterNoStyle
																	 timeStyle:NSDateFormatterShortStyle]];
		}
	} else {
		[newDoseList appendString:NSLocalizedString(@"No doses recorded.", nil)];
	}
	
	self.recentDoses.text = newDoseList;
}

- (IBAction)recordNewDose:(id)sender {
	[[DoseStore defaultStore] addDose:[NSDate date]];
	[self refreshRecentDoses];
	[self recalculateIndicators];
}

- (void)setIndicatorsYes
{
	self.indicatorImage.image = [UIImage imageNamed:@"OK.png"];
	self.indicatorText.text = NSLocalizedString(@"You may take a dose now.", nil);
	self.indicatorBigText.text = NSLocalizedString(@"Yes", nil);
}

- (void)setIndicatorsNo:(NSDate *)expiresTime
{
	self.indicatorImage.image = [UIImage imageNamed:@"Ex.png"];
	self.indicatorText.text = [NSString stringWithFormat: NSLocalizedString(@"Next dose: %@", nil),
							   [NSDateFormatter localizedStringFromDate:expiresTime
															  dateStyle:NSDateFormatterNoStyle
															  timeStyle:NSDateFormatterShortStyle]];
	self.indicatorBigText.text = NSLocalizedString(@"No", nil);
}

- (void)setIndicatorsNeutral
{
	self.indicatorImage.image = [UIImage imageNamed:@"Neutral.png"];
	self.indicatorText.text = NSLocalizedString(@"No dosage information", nil);
	self.indicatorBigText.text = @"– –";
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
    [self dismissModalViewControllerAnimated:YES];
	
	[self refreshRecentDoses];
	[self recalculateIndicators];
}

- (void)flipsideViewControllerClearDoses:(FlipsideViewController *)controller
{
	[[DoseStore defaultStore] removeAllDoses];
	[self clearAlert];
}

- (void)flipsideViewController:(FlipsideViewController *)controller changedHourlyIntervalTo:(int)hourlyInterval
{
	_doseHourlyInterval = hourlyInterval * OneHourTimeInterval;
	[[NSUserDefaults standardUserDefaults] setInteger:hourlyInterval
											   forKey:PillTimerHourlyPrefKey];
}

- (void)flipsideViewController:(FlipsideViewController *)controller changedDailyLimitTo:(int)dailyLimit
{
	_doseDailyLimit = dailyLimit;
	[[NSUserDefaults standardUserDefaults] setInteger:dailyLimit
											   forKey:PillTimerDailyPrefKey];
}

- (void)flipsideViewController:(FlipsideViewController *)controller changedAlertSettingTo:(BOOL)alertsOn
{
	_alertsOn = alertsOn;
	if (!alertsOn) [self clearAlert];
	
	[[NSUserDefaults standardUserDefaults] setBool:alertsOn forKey:PillTimerAlertsPrefKey];
}

- (IBAction)showInfo:(id)sender
{    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
	controller.doseHourlyInterval.text = [NSString stringWithFormat:@"%d", (int)(_doseHourlyInterval / OneHourTimeInterval)];
	controller.doseDailyLimit.text = [NSString stringWithFormat:@"%d", _doseDailyLimit];
	controller.alertSwitch.on = _alertsOn;
}

@end
