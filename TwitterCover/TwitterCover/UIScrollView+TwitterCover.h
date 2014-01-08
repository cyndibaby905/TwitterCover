//
//  UIScrollView+TwitterCover.h
//  TwitterCover
//
//  Created by hangchen on 1/7/14.
//  Copyright (c) 2014 hangchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#define CHTwitterCoverViewHeight 200

@interface CHTwitterCoverView : UIImageView
@property (nonatomic, weak) UIScrollView *scrollView;
@end


@interface UIScrollView (TwitterCover)
@property(nonatomic,weak)CHTwitterCoverView *twitterCoverView;
- (void)addTwitterCoverWithImage:(UIImage*)image;
@end

@interface UIImage (Blur)
-(UIImage *)boxblurImageWithBlur:(CGFloat)blur;
@end