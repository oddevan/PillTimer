//
//  NewDoseViewController.m
//  PillTimer
//
//  Created by Evan Hildreth on 3/12/13.
//  Copyright (c) 2013 Evan Hildreth. All rights reserved.
//

#import "NewDoseViewController.h"
#import "DoseStore.h"
#import <QuartzCore/QuartzCore.h>

@interface NewDoseViewController ()
{
	__weak IBOutlet UIButton *_cancelButton;
}

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
	
	//via http://stackoverflow.com/questions/7238507/change-round-rect-button-background-color-on-statehighlighted
	
	// set the button's highlight color
    [_cancelButton setTintColor:[UIColor colorWithRed:0.2578f green:0.2578f blue:0.2578f alpha:1.0f]];
	
    // clear any existing background image
    [_cancelButton setBackgroundImage:nil forState:UIControlStateNormal];
	
    // place the button into highlighted state with no title
    BOOL wasHighlighted = _cancelButton.highlighted;
    NSString* savedTitle = [_cancelButton titleForState:UIControlStateNormal];
    [_cancelButton setTitle:nil forState:UIControlStateNormal];
    [_cancelButton setHighlighted:YES];
	
    // render the highlighted state of the button into an image
    UIGraphicsBeginImageContext(_cancelButton.layer.frame.size);
    CGContextRef graphicsContext = UIGraphicsGetCurrentContext();
    [_cancelButton.layer renderInContext:graphicsContext];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIImage* stretchableImage = [image stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    UIGraphicsEndImageContext();
	
    // restore the button's state and title
    [_cancelButton setHighlighted:wasHighlighted];
    [_cancelButton setTitle:savedTitle forState:UIControlStateNormal];
	
    // set background image of all buttons
    [_cancelButton setBackgroundImage:stretchableImage forState:UIControlStateNormal];
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
	_cancelButton = nil;
    [super viewDidUnload];
}

- (CGFloat)viewHeight
{
	return self.view.bounds.size.height + 20.0f;
}
@end
