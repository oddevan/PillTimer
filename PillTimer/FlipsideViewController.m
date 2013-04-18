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
}

@end

@implementation FlipsideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	UIToolbar *hourlyExtraToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
	hourlyExtraToolbar.tintColor = [UIColor darkGrayColor];
	hourlyExtraToolbar.items = [NSMutableArray arrayWithObjects:[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(switchToDailyLimit)], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(backgroundTapped:)], nil];
	
	self.doseHourlyInterval.inputAccessoryView = hourlyExtraToolbar;
    
	UIToolbar *dailyExtraToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
	dailyExtraToolbar.tintColor = [UIColor darkGrayColor];
	dailyExtraToolbar.items = [NSMutableArray arrayWithObjects:[[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(switchToHourlyInterval)], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(backgroundTapped:)], nil];
    
	self.doseDailyLimit.inputAccessoryView = dailyExtraToolbar;
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

- (void)switchToHourlyInterval
{
    [self.doseHourlyInterval becomeFirstResponder];
}

- (void)switchToDailyLimit
{
    [self.doseDailyLimit becomeFirstResponder];
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
