## TwitterCover ##

TwitterCover is a parallax top view with real time blur effect to any UIScrollView, inspired by Twitter for iOS.

Completely created using UIKit framework.

Easy to drop into your project.

You can add this feature to your own project, `TwitterCover` is easy-to-use. 

**Now the Android version is also available:** [TwitterCover-Android](https://github.com/cyndibaby905/TwitterCover-Android)

## Requirements ##

TwitterCover requires Xcode 5, targeting either iOS 5.0 and above, ARC-enabled.


## How to use ##
	
Drag UIScrollView+TwitterCover.h amd UIScrollView+TwitterCover.m files to your project. 

No other frameworks required.

    #import "UIScrollView+TwitterCover.h"

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [scrollView addTwitterCoverWithImage:[UIImage imageNamed:@"cover.png"]];

And do not forget to remove it in your dealloc method, otherwise memory leaks:

    [scrollView removeTwitterCoverView];    

## How it looks ##

![TwitterCover] (https://raw.github.com/cyndibaby905/TwitterCover/master/TwitterCover.gif)


## Lincense ##

`TwitterCover` is available under the MIT license. See the LICENSE file for more info.

