//
//  CHViewController.m
//  TwitterCover
//
//  Created by hangchen on 1/7/14.
//  Copyright (c) 2014 hangchen. All rights reserved.
//

#import "CHViewController.h"
#import "UIScrollView+TwitterCover.h"
@interface CHViewController ()

@end

@implementation CHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, 600)];
    [scrollView addTwitterCoverWithImage:[UIImage imageNamed:@"cover.png"]];
    [self.view addSubview:scrollView];

    [scrollView addSubview:({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, CHTwitterCoverViewHeight, self.view.bounds.size.width - 40, 600 - CHTwitterCoverViewHeight)];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:20];
        label.text = @"TwitterCover is a parallax top view to any UIScrollView, inspired by Twitter for iOS.";
        label;
    })];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
