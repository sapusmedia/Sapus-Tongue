//
//  AdViewController.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 7/28/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#ifdef LITE_VERSION

#import "cocos2d.h"

#import "SapusConfig.h"
#import "AdViewController.h"
#import "SapusTongueAppDelegate.h"
#import "GameCenterManager.h"
#import "SimpleAudioEngine.h"

#pragma mark AdViewController - UIViewController stuff

@implementation AdViewController

@synthesize contentView, banner;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

	self.contentView = nil;
    banner.delegate = nil;
    self.banner = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{	
	[super viewWillDisappear:animated];
}

-(void) viewDidDisappear:(BOOL)animated
{	
	[super viewDidDisappear:animated];
}

- (void)dealloc
{
	CCLOGINFO(@"dealloc: %@", self);
    [contentView release]; contentView = nil;
    banner.delegate = nil;
    [banner release]; banner = nil; 
	
    [super dealloc];
}

#pragma mark RootViewController - iAd related


-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if( NSClassFromString(@"ADBannerView") != nil )
		[self layoutForCurrentOrientation:YES];
}

-(void)createADBannerView
{
    // --- WARNING ---
    // If you are planning on creating banner views at runtime in order to support iOS targets that don't support the iAd framework
    // then you will need to modify this method to do runtime checks for the symbols provided by the iAd framework
    // and you will need to weaklink iAd.framework in your project's target settings.
    // See the iPad Programming Guide, Creating a Universal Application for more information.
    // http://developer.apple.com/iphone/library/documentation/general/conceptual/iPadProgrammingGuide/Introduction/Introduction.html
    // --- WARNING ---
	
    // Depending on our orientation when this method is called, we set our initial content size.
    // If you only support portrait or landscape orientations, then you can remove this check and
    // select either ADBannerContentSizeIdentifier320x50 (if portrait only) or ADBannerContentSizeIdentifier480x32 (if landscape only).
    NSString *contentSize = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierLandscape;
    
    // Calculate the intial location for the banner.
    // We want this banner to be at the bottom of the view controller, but placed
    // offscreen to ensure that the user won't see the banner until its ready.
    // We'll be informed when we have an ad to show because -bannerViewDidLoadAd: will be called.
    CGRect frame;
    frame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:contentSize];
    frame.origin = CGPointMake(0.0f, CGRectGetMaxY(self.view.bounds));
    
    // Now to create and configure the banner view
    ADBannerView *bannerView = [[ADBannerView alloc] initWithFrame:frame];
    // Set the delegate to self, so that we are notified of ad responses.
    bannerView.delegate = self;
    // Set the autoresizing mask so that the banner is pinned to the bottom
    bannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    // Since we support all orientations in this view controller, support portrait and landscape content sizes.
    // If you only supported landscape or portrait, you could remove the other from this set.
    bannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];
    
    // At this point the ad banner is now be visible and looking for an ad.
    [self.view addSubview:bannerView];
    self.banner = bannerView;
    [bannerView release];
	
	
	// XXX: To prevent a bug in iOS 4.0 (not 4.1), the banner frame should be hidden.
	[self.banner setHidden:YES];
}

-(void)layoutForCurrentOrientation:(BOOL)animated
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    // by default content consumes the entire view area
    CGRect contentFrame = self.view.bounds;
    // the banner still needs to be adjusted further, but this is a reasonable starting point
    // the y value will need to be adjusted by half the banner height to get the final position
    CGPoint bannerCenter = CGPointMake(CGRectGetMidX(contentFrame), CGRectGetMaxY(contentFrame));
    CGFloat bannerHeight = 0.0f;
    
    // First, setup the banner's content size and adjustment based on the current orientation
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
        bannerHeight = 32.0f;
    }
    else
    {
        banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        bannerHeight = 50.0f;
    }
    
    // Depending on if the banner has been loaded, we adjust the content frame and banner location
    // to accomodate the ad being on or off screen.
    // This layout is for an ad at the bottom of the view.
    if(banner.bannerLoaded)
    {
        contentFrame.size.height -= bannerHeight;
        bannerCenter.y -= bannerHeight / 2.0f;
    }
    else
    {
        bannerCenter.y += bannerHeight / 2.0f;
    }
    
	[self.banner setHidden:NO];

    // And finally animate the changes, running layout for the content view if required.
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         contentView.frame = contentFrame;
                         [contentView layoutIfNeeded];
                         
                         banner.center = bannerCenter;
                     }];
}

#pragma mark ADBannerViewDelegate methods

-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	CCLOG(@"[iAd] bannerViewDidLoadAd");
	
    [self layoutForCurrentOrientation:YES];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	CCLOG(@"[iAd] bannerView:didFailToReceiveAdWithError: %@", error);
    [self layoutForCurrentOrientation:YES];
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	CCLOG(@"[iAd] bannerViewActionShouldBegin");
	
	// Pause cocos2d / CocosDenshion
	if( ! willLeave ) {
		musicIsMuted_ = [[SimpleAudioEngine sharedEngine] mute];
		if( ! musicIsMuted_ )
			[[SimpleAudioEngine sharedEngine] setMute:YES];
		
		[[CCDirector sharedDirector] stopAnimation];
	}
	
    return YES;
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
	CCLOG(@"[iAd] bannerViewActionDidFinish");

	// Resume cocos2d / CocosDenshion
	if( ! musicIsMuted_ )
		[[SimpleAudioEngine sharedEngine] setMute:NO];
	[[CCDirector sharedDirector] startAnimation];
	
}
@end

#endif // LITE_VERSION
