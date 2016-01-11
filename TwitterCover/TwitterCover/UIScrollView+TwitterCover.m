//
//  UIScrollView+TwitterCover.m
//  TwitterCover
//
//  Created by hangchen on 1/7/14.
//  Copyright (c) 2014 Hang Chen (https://github.com/cyndibaby905)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "UIScrollView+TwitterCover.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

@interface CHTwitterCoverView ()

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, assign) CGSize coverSize;
@property (nonatomic, strong) CALayer *maskLayer;

@end

@implementation CHTwitterCoverView {
    NSMutableArray *blurImages_;
}

#pragma mark - instance method

- (id)initWithFrame:(CGRect)frame andContentTopView:(UIView *)view {
    self = [super initWithFrame:frame];
    if (self) {
        self.topView = view;
        self.coverSize = frame.size;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = YES;
        
        // mask
        self.maskLayer = [CALayer layer];
        _maskLayer.actions = @{@"bounds":[NSNull null],
                               @"position":[NSNull null],
                               @"opacity":[NSNull null]};
        _maskLayer.backgroundColor = [UIColor blackColor].CGColor;
        _maskLayer.contentsGravity = kCAGravityResizeAspectFill;
        _maskLayer.frame = self.layer.bounds;
        _maskLayer.opacity = 0;
        [self.layer addSublayer:self.maskLayer];
        
        // blur images
        blurImages_ = [NSMutableArray new];
    }
    return self;
}

#pragma mark - properties

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    [blurImages_ removeAllObjects];
    if (!_noBlur) {
        [self prepareForBlurImages];
    }
}

- (void)setNoBlur:(BOOL)noBlur {
    _noBlur = noBlur;
    if (!_noBlur) {
        [self prepareForBlurImages];
    }
}

- (void)prepareForBlurImages {
    if (!self.image || blurImages_.count == 20) {
        return;
    }
    [blurImages_ addObject:self.image];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        CGFloat factor = 0.1;
        for (NSUInteger i = 0; i < 20; i++) {
            [blurImages_ addObject:[self.image boxblurImageWithBlur:factor]];
            factor+=0.04;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self layoutSubviews];
        });
    });
}

#pragma mark - method to override

- (void)setFrame:(CGRect)frame {
    // Update mask frame
    if (CGRectGetWidth(self.frame) != CGRectGetWidth(frame)) {
        self.maskLayer.frame = (CGRect){{0,0},frame.size};
    }
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [UIView setAnimationsEnabled:NO];
    
    CGFloat topInset = _noContentInset ? 0 : self.scrollView.contentInset.top;
    
    CGSize coverSize = [self coverSize];
    CGFloat offset = self.scrollView.contentOffset.y + topInset;
    // Pull down
    if (self.scrollView.contentOffset.y < -topInset) {
        self.topView.frame = CGRectMake(0, offset, coverSize.width, CGRectGetHeight(self.topView.bounds));
        self.frame = CGRectMake(offset, offset + CGRectGetHeight(self.topView.bounds), coverSize.width - offset * 2, coverSize.height - offset);
        
        if (!_noBlur) {
            NSInteger index = MAX(0, MIN(blurImages_.count - 1, -offset / 10));
            UIImage *image = [blurImages_ count] > index ? blurImages_[index] : nil;
            if (self.image != image) {
                [super setImage:image];
            }
        }
    }
    // Push up
    else {
        if (offset >= CGRectGetHeight(self.topView.bounds)) {
            offset -= CGRectGetHeight(self.topView.bounds);
            self.topView.frame = CGRectMake(0, 0, coverSize.width, CGRectGetHeight(self.topView.bounds));
            self.frame = CGRectMake(0, CGRectGetHeight(self.topView.bounds) + offset, coverSize.width, MAX(0, coverSize.height - offset));
            
            if (!_noBlur) {
                UIImage *image = [blurImages_ count] > 0 ? blurImages_[0] : nil;
                if (self.image != image) {
                    [super setImage:image];
                }
            }
        }
    }
    // Update mask layer
    if (!self.noDim) {
        offset = self.scrollView.contentOffset.y + topInset;
        if (offset >= CGRectGetHeight(self.topView.bounds)) {
            offset -= CGRectGetHeight(self.topView.bounds);
            self.maskLayer.opacity = offset / coverSize.height;
        } else {
            self.maskLayer.opacity = 0;
        }
    }
    
    [UIView setAnimationsEnabled:YES];
}

@end

@implementation UIScrollView (PrivateTwitterCover)

#pragma mark - runtime objects

- (void)setTwitterCoverView:(CHTwitterCoverView *)twitterCoverView {
    objc_setAssociatedObject(self, @selector(twitterCoverView), twitterCoverView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CHTwitterCoverView *)twitterCoverView {
    return objc_getAssociatedObject(self, _cmd);
}

@end

static char UIScrollViewTwitterCoverView;
static char UIScrollViewTwitterCoverContext;

@implementation UIScrollView (TwitterCover)

- (void)setTwitterCoverView:(CHTwitterCoverView *)twitterCoverView {
    [self willChangeValueForKey:@"twitterCoverView"];
    objc_setAssociatedObject(self, &UIScrollViewTwitterCoverView,
                             twitterCoverView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"twitterCoverView"];
}

- (CHTwitterCoverView *)twitterCoverView {
    return objc_getAssociatedObject(self, &UIScrollViewTwitterCoverView);
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != &UIScrollViewTwitterCoverContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([@"bounds" isEqualToString:keyPath]) {
        CGSize coverSize = [self.twitterCoverView coverSize];
        if (coverSize.width != CGRectGetWidth(self.frame)) {
            CGRect frame = CGRectMake(0,
                                      CGRectGetHeight(self.twitterCoverView.topView.bounds),
                                      CGRectGetWidth(self.frame),
                                      self.twitterCoverView.coverSize.height);
            [self.twitterCoverView setFrame:frame];
            [self.twitterCoverView setCoverSize:frame.size];
        }
        [self.twitterCoverView setNeedsLayout];
    }
}

#pragma mark - instance methods

- (void)removeCoverView {
    if (self.twitterCoverView) {
        [self.twitterCoverView removeFromSuperview];
        [self.twitterCoverView.topView removeFromSuperview];
        
        [self removeObserver:self forKeyPath:@"bounds" context:&UIScrollViewTwitterCoverContext];
    }
}

- (void)addTwitterCoverWithImage:(UIImage *)image coverHeight:(CGFloat)coverHeight {
    [self addTwitterCoverWithImage:image coverHeight:coverHeight noBlur:NO withTopView:nil];
}

- (void)addTwitterCoverWithImage:(UIImage *)image coverHeight:(CGFloat)coverHeight noBlur:(BOOL)noBlur {
    [self addTwitterCoverWithImage:image coverHeight:coverHeight noBlur:noBlur withTopView:nil];
}

- (void)addTwitterCoverWithImage:(UIImage *)image coverHeight:(CGFloat)coverHeight withTopView:(UIView *)topView {
    [self addTwitterCoverWithImage:image coverHeight:coverHeight noBlur:NO withTopView:topView];
}

- (void)addTwitterCoverWithImage:(UIImage *)image coverHeight:(CGFloat)coverHeight noBlur:(BOOL)noBlur withTopView:(UIView *)topView {
    [self removeCoverView];
    
    // Add Cover View
    CHTwitterCoverView *view = [[CHTwitterCoverView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(topView.bounds), self.frame.size.width, coverHeight)
                                                       andContentTopView:topView];
    view.backgroundColor = [UIColor clearColor];
    view.noBlur = noBlur;
    view.image = image;
    view.scrollView = self;
    self.twitterCoverView = view;
    [self addSubview:self.twitterCoverView];
    
    // Add Top View
    if (topView) {
        [self addSubview:topView];
        topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    // Observe bounds to update cover view
    [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:&UIScrollViewTwitterCoverContext];
}

#pragma mark - life cycle

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview == nil) {
        [self removeCoverView];
    }
}

@end


@implementation UIImage (Blur)

-(UIImage *)boxblurImageWithBlur:(CGFloat)blur {
    
    NSData *imageData = UIImageJPEGRepresentation(self, 1); // convert to jpeg
    UIImage* destImage = [UIImage imageWithData:imageData];
    
    
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = destImage.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    
    vImage_Error error;
    
    void *pixelBuffer;
    
    
    //create vImage_Buffer with data from CGImageRef
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end
