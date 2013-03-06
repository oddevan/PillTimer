//
//  MainViewController.h
//  PillTimer
//
//  Created by Evan Hildreth on 2/4/13.
//  Copyright (c) 2013 Evan Hildreth. All rights reserved.
//

#import <iAd/iAd.h>
#import "FlipsideViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, ADBannerViewDelegate>

- (void)recalculateIndicators;

- (IBAction)showInfo:(id)sender;
- (IBAction)recordNewDose:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *indicatorBigText;
@property (weak, nonatomic) IBOutlet UIImageView *indicatorImage;
@property (weak, nonatomic) IBOutlet UILabel *indicatorText;
@property (weak, nonatomic) IBOutlet UITextView *recentDoses;
@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;

@end
