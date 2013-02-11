//
//  MainViewController.m
//  PillTimer
//
//  Created by Evan Hildreth on 2/4/13.
//  Copyright (c) 2013 Evan Hildreth. All rights reserved.
//

#import "MainViewController.h"

const NSTimeInterval TwentyFourHourTimeInterval = 86400;

@interface MainViewController ()
{
	NSMutableArray *_allRecentDoses;
	NSTimeInterval _doseHourlyInterval;
	int _doseDailyLimit;
}

- (void)recalculateIndicators;
- (void)setIndicatorsYes;
- (void)setIndicatorsNo;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self recalculateIndicators];
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
	if (_allRecentDoses) {
		NSDate *latestDose = [NSDate distantPast];
		
		for (NSDate *thisDate in _allRecentDoses) {
			if (fabs([thisDate timeIntervalSinceNow]) > TwentyFourHourTimeInterval) {
				[_allRecentDoses removeObject:thisDate];
			} else if ([thisDate timeIntervalSinceDate:latestDose] > 0) {
				latestDose = thisDate;
			}
		}
		
		if (([_allRecentDoses count] >= _doseDailyLimit) ||
			(fabs([latestDose timeIntervalSinceNow]) < _doseHourlyInterval)) {
			[self setIndicatorsNo];
		} else {
			[self setIndicatorsYes];
		}
	} else {
		_allRecentDoses = [[NSMutableArray alloc] init];
		[self setIndicatorsYes];
	}
}

- (IBAction)recordNewDose:(id)sender {
	[_allRecentDoses addObject:[NSDate date]];
	[self recalculateIndicators];
}

- (void)setIndicatorsYes
{
	self.indicatorImage.image = [UIImage imageNamed:@"OK.png"];
	self.indicatorText.text = @"You can has";
}

- (void)setIndicatorsNo
{
	self.indicatorImage.image = [UIImage imageNamed:@"Ex.png"];
	self.indicatorText.text = @"YOU CANNOT HAS";
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
	_doseDailyLimit = controller.doseDailyLimit.text.intValue;
	_doseHourlyInterval = controller.doseHourlyInterval.text.intValue * 60 * 60;
	
    [self dismissModalViewControllerAnimated:YES];
	
	[self recalculateIndicators];
}

- (void)flipsideViewControllerClearDoses:(FlipsideViewController *)controller {
	[_allRecentDoses removeAllObjects];
}

- (IBAction)showInfo:(id)sender
{    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
}

@end
