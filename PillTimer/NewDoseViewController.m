//
//  NewDoseViewController.m
//  PillTimer
//
//  Created by Evan Hildreth on 3/12/13.
//  Copyright (c) 2013 Evan Hildreth. All rights reserved.
//

#import "NewDoseViewController.h"
#import "DoseStore.h"

@interface NewDoseViewController ()

@end

@implementation NewDoseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.timePicker.date = [NSDate date];
    [self timeChanged:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)timeChanged:(id)sender {
    NSString *dayModifier;
    
    if ([self.timePicker.date timeIntervalSinceNow] <= 0) {
        dayModifier = NSLocalizedString(@"Today", nil);
    } else {
        dayModifier = NSLocalizedString(@"Yesterday", nil);
    }
    
    self.doseCaption.text = [NSString stringWithFormat:@"%@ at %@",
                             dayModifier,
                             [NSDateFormatter localizedStringFromDate:self.timePicker.date
                                                            dateStyle:NSDateFormatterNoStyle
                                                            timeStyle:NSDateFormatterShortStyle]];
}

- (IBAction)recordDose:(id)sender {
    if ([self.timePicker.date timeIntervalSinceNow] <= 0) {
        [[DoseStore defaultStore] addDose:self.timePicker.date];
    } else {
        [[DoseStore defaultStore] addDose:[self.timePicker.date dateByAddingTimeInterval:-86400]];
    }
    [self.delegate newDoseViewControllerDidFinish:self];
}
- (IBAction)formCancelled:(id)sender {
    [self.delegate newDoseViewControllerDidFinish:self];
}

- (void)viewDidUnload {
    [self setTimePicker:nil];
    [self setDoseCaption:nil];
    [super viewDidUnload];
}
@end
