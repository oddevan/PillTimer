//
//  FlipsideViewController.m
//  PillTimer
//
//  Created by Evan Hildreth on 2/4/13.
//  Copyright (c) 2013 Evan Hildreth. All rights reserved.
//

#import "FlipsideViewController.h"

@interface FlipsideViewController ()
{
	UIToolbar *extraToolbar;
}

@end

@implementation FlipsideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	extraToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
	extraToolbar.tintColor = [UIColor darkGrayColor];
	
	NSMutableArray *items = [NSMutableArray array];
	[items addObject:[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(textFieldShouldReturn:)]];
	[items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]];
	[items addObject:[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(textFieldShouldReturn:)]];
	
	self.doseHourlyInterval.inputAccessoryView = extraToolbar;
	self.doseDailyLimit.inputAccessoryView = extraToolbar;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)clearRecentDoses:(id)sender
{
	[self.delegate flipsideViewControllerClearDoses:self];
}

- (IBAction)alertSettingChanged:(id)sender
{
	[self.delegate flipsideViewController:self changedAlertSettingTo:self.alertSwitch.on];
}

- (IBAction)hourlyLimitChanged:(id)sender
{
	[self.delegate flipsideViewController:self changedHourlyIntervalTo:self.doseHourlyInterval.text.intValue];
}

- (IBAction)dailyLimitChanged:(id)sender
{
	[self.delegate flipsideViewController:self changedDailyLimitTo:self.doseDailyLimit.text.intValue];
}

- (IBAction)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)vanityPlateTapped:(id)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://pilltimer.oddevan.com/"]];
}

@end
