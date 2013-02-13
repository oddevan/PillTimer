//
//  FlipsideViewController.h
//  PillTimer
//
//  Created by Evan Hildreth on 2/4/13.
//  Copyright (c) 2013 Evan Hildreth. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
- (void)flipsideViewControllerClearDoses:(FlipsideViewController *)controller;
- (void)flipsideViewController:(FlipsideViewController *)controller changedAlertSettingTo:(BOOL)alertsOn;
@end

@interface FlipsideViewController : UIViewController

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *doseHourlyInterval;
@property (weak, nonatomic) IBOutlet UITextField *doseDailyLimit;
@property (weak, nonatomic) IBOutlet UISwitch *alertSwitch;

- (IBAction)done:(id)sender;
- (IBAction)clearRecentDoses:(id)sender;
- (IBAction)alertSettingChanged:(id)sender;

@end
