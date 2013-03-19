//
//  NewDoseViewController.h
//  PillTimer
//
//  Created by Evan Hildreth on 3/12/13.
//  Copyright (c) 2013 Evan Hildreth. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewDoseViewController;

@protocol NewDoseViewControllerDelegate <NSObject>

- (void)newDoseViewControllerDidFinish:(NewDoseViewController *)controller;

@end

@interface NewDoseViewController : UIViewController
- (IBAction)recordDose:(id)sender;

@property (weak, nonatomic) id <NewDoseViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UILabel *doseCaption;
@property (readonly) CGFloat viewHeight;

@end
