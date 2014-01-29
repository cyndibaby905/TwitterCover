//
//  CHTwitterCoverDemoScrollViewController.m
//  TwitterCover
//
//  Created by hangchen on 1/29/14.
//  Copyright (c) 2014 hangchen. All rights reserved.
//

#import "CHTwitterCoverDemoScrollViewController.h"
#import "UIScrollView+TwitterCover.h"

@interface CHTwitterCoverDemoScrollViewController ()

@end

@implementation CHTwitterCoverDemoScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            [self setEdgesForExtendedLayout:UIRectEdgeNone];
        }
        self.title = @"UIScrollview+TwitterCover";

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, 600)];
    [scrollView addTwitterCoverWithImage:[UIImage imageNamed:@"cover.png"]];
    [self.view addSubview:scrollView];
    
    [scrollView addSubview:({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, CHTwitterCoverViewHeight, self.view.bounds.size.width - 40, 600 - CHTwitterCoverViewHeight)];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:22];
        label.text = @"TwitterCover is a parallax top view with real time blur effect to any UIScrollView, inspired by Twitter for iOS.\n\nCompletely created using UIKit framework.\n\nEasy to drop into your project.\n\nYou can add this feature to your own project, TwitterCover is easy-to-use.";
        label;
    })];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
