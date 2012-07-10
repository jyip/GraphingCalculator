//
//  GraphViewController.h
//  GraphingCalculator
//
//  Created by terran on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) NSArray *program; // model
@property (weak, nonatomic) IBOutlet UILabel *descriptionDisplay;
@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;

@end
