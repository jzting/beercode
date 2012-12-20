//
//  ViewController.h
//  beercode
//
//  Created by Jason Ting on 12/19/12.
//  Copyright (c) 2012 Jason Ting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
- (IBAction)scan:(id)sender;

@end
