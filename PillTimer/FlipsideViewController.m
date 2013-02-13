//
//  FlipsideViewController.m
//  PillTimer
//
//  Created by Evan Hildreth on 2/4/13.
//  Copyright (c) 2013 Evan Hildreth. All rights reserved.
//

#import "FlipsideViewController.h"

@interface FlipsideViewController ()

@end

@implementation FlipsideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
	[self setDoseHourlyInterval:nil];
	[self setDoseDailyLimit:nil];
	[self setAlertSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)clearRecentDoses:(id)sender {
	[self.delegate flipsideViewControllerClearDoses:self];
}
- (IBAction)alertSettingChanged:(id)sender {
	[self.delegate flipsideViewController:self changedAlertSettingTo:self.alertSwitch.on];
}

@end
