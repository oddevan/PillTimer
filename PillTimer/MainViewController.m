//
//  MainViewController.m
//  PillTimer
//
//  Created by Evan Hildreth on 2/4/13.
//  Copyright (c) 2013 Evan Hildreth. All rights reserved.
//

#import "MainViewController.h"
#import "DoseStore.h"
#import "NewDoseViewController.h"

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
    NewDoseViewController *_newDoseController;
    UIView *_fullFrameView;
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
	
    self.bannerView.delegate = self;
    
	[[DoseStore defaultStore] loadDosesIfNecessary];
}

- (void)viewDidAppear:(BOOL)animated
{
	[self recalculateIndicators];
	
	if ((_doseHourlyInterval < 0) || (_doseDailyLimit <= 0)) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", nil)
														message:NSLocalizedString(@"This is a timer designed to help you follow dosage instructions as given by your doctor, pharmacist, or other authority. Only your doctor or pharmacist can answer questions you have about your medication. While this app is here to help, neither it nor those who made it can advise you on whether or not you should take any form of medication.", nil)
													   delegate:nil
											  cancelButtonTitle:@"Accept"
											  otherButtonTitles:nil];
		[alert show];
		[self showInfo:nil];
	}
}

- (void)viewDidUnload
{
    [self setIndicatorImage:nil];
    [self setIndicatorText:nil];
    [self setRecentDoses:nil];
    [self setIndicatorBigText:nil];
    [self setBannerView:nil];
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
		NSMutableArray *expiredDoses = [[NSMutableArray alloc] init];
		
		for (NSDate *thisDate in [[DoseStore defaultStore] allRecentDoses]) {
			if (fabs([thisDate timeIntervalSinceNow]) > TwentyFourHourTimeInterval) {
				[expiredDoses addObject:thisDate];
			} else {
				if ([thisDate timeIntervalSinceDate:latestDose] > 0) {
					latestDose = thisDate;
				}
				if ([thisDate timeIntervalSinceDate:earliestDose] < 0) {
					earliestDose = thisDate;
				}
			}
		}
		//Moving the removal outside of the enumeration
		[[DoseStore defaultStore] removeDoses:expiredDoses];
		
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
			[self clearAlert];
		}
	} else if ((_doseHourlyInterval < 0) || (_doseDailyLimit <= 0)) {
		[self setIndicatorsNeutral];
		[self clearAlert];
	} else {
		[self setIndicatorsYes];
		[self clearAlert];
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
    _newDoseController = [[NewDoseViewController alloc] initWithNibName:@"NewDoseViewController" bundle:nil];
    _newDoseController.delegate = self;
    
    _fullFrameView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _fullFrameView.backgroundColor = nil;
    [self.view addSubview:_fullFrameView];
    
    _newDoseController.view.center = CGPointMake(_fullFrameView.bounds.size.width / 2, _fullFrameView.bounds.size.height + _newDoseController.viewHeight / 2.0f);
    [_fullFrameView addSubview:_newDoseController.view];
    
    [UIView animateWithDuration:0.3f animations:^{_newDoseController.view.center = CGPointMake(_fullFrameView.bounds.size.width / 2, _fullFrameView.bounds.size.height - _newDoseController.viewHeight / 2.0f);}];
}

- (void)newDoseViewControllerDidFinish:(NewDoseViewController *)controller
{
    [UIView animateWithDuration:0.3f
                     animations:^{
        _newDoseController.view.center = CGPointMake(_fullFrameView.bounds.size.width / 2,
                                                     _fullFrameView.bounds.size.height + _newDoseController.viewHeight / 2.0f);}
                     completion:^(BOOL finished){
                         [_newDoseController.view removeFromSuperview];
                         [_fullFrameView removeFromSuperview];
                         
                         _newDoseController = nil;
                         _fullFrameView = nil;
                         
                         [self refreshRecentDoses];
                         [self recalculateIndicators];
                     }];
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

#pragma mark - iAd stuff

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    self.bannerView.hidden = YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [self recalculateIndicators];
}

- (void)bannerViewWillLoadAd:(ADBannerView *)banner
{
    self.bannerView.hidden = NO;
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

@end
