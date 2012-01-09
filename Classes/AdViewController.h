//
//  RootViewController.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 7/28/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

#ifdef LITE_VERSION

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface AdViewController : UIViewController <ADBannerViewDelegate>
{
	BOOL			musicIsMuted_;
    UIView			*contentView;
    ADBannerView	*banner;
}

// A simple method that creates an ADBannerView
// Useful if you need to create the banner view in code
// such as when designing a universal binary for iPad
-(void)createADBannerView;

// Layout the Ad Banner and Content View to match the current orientation.
// The ADBannerView always animates its changes, so generally you should
// pass YES for animated, but it makes sense to pass NO in certain circumstances
// such as inside of -viewDidLoad.
-(void)layoutForCurrentOrientation:(BOOL)animated;

@property(nonatomic, retain) IBOutlet UIView *contentView;
@property(nonatomic, retain) IBOutlet ADBannerView *banner;

@end

#endif // ! LITE_VERSION