//
//  LoadingBarNode.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 28/07/09.
//  Copyright 2009 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


// LoadingBar:
// A helpful class that loads and shows the images asynchronously
// When the images finish loading, the callback will be called.
//
// Feel free to reuse the code as well as the loading_bar.png image
//

#import "LoadingBarNode.h"

enum {
	kTagBatchNode,
};

enum {
	kTagSpriteBack,
	kTagSpriteBar,
};

@implementation LoadingBarNode

-(id) init
{
	if( (self=[super init])) {

		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"loading_bar.png" capacity:2];
		[self addChild:batch z:0 tag:kTagBatchNode];

#define LOADING_BAR_X 192
#define LOADING_BAR_Y 15
		
		target_ = nil;
		selector_ = nil;
		total_ = 0;
		imagesLoaded_ = 0;

		[self setContentSize:CGSizeMake(LOADING_BAR_X,LOADING_BAR_Y)];
		CCSprite *back = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(0, 0, LOADING_BAR_X, LOADING_BAR_Y)];
		CCSprite *loadingBar = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(0, LOADING_BAR_Y*1, 0, LOADING_BAR_Y)];
		
//		[back setAnchorPoint:CGPointZero];
		[loadingBar setAnchorPoint:ccp(0,0.5f)];
		[loadingBar setPosition:ccp(-LOADING_BAR_X/2,0)];
		
		[batch addChild:back z:0 tag:kTagSpriteBack];
		[batch addChild:loadingBar z:1 tag:kTagSpriteBar];
	}
	return self;
}

-(void) loadImagesWithArray:(NSArray*)names target:(id)t selector:(SEL)sel
{
	target_ = t;
	selector_ = sel;
	
	total_ = [names count];
	imagesLoaded_ = 0;
	
	for( id name in names ) {
		[[CCTextureCache sharedTextureCache] addImageAsync:name target:self selector:@selector(imageLoaded:)];
	}
}

- (void) dealloc
{
	[super dealloc];
}

-(void) imageLoaded:(CCTexture2D*) image
{
	
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
	CCSprite *bar = (CCSprite*) [batch getChildByTag:kTagSpriteBar];
	
	imagesLoaded_++;
	CGRect rect = [bar textureRect];
	rect.size.width = LOADING_BAR_X * ( imagesLoaded_ / total_ );
//	NSLog(@"width: %f", rect.size.width);

	[bar setTextureRect:rect];

	if( total_ == imagesLoaded_ )
		[target_ performSelector:selector_ withObject:self];
}
@end
