//
//  ReadablityTabBarViewController.m
//  Readability
//
//  Created by Helen Weng on 3/9/14.
//  Copyright (c) 2014 JEHM. All rights reserved.
//

#import "ReadablityTabBarViewController.h"
#import "Util.h"

@interface ReadablityTabBarViewController ()

@end

@implementation ReadablityTabBarViewController

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
    [self.tabBar setTranslucent:NO];
    [self.tabBar setBarTintColor:UIColorFromRGB(0xfff3b3)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
