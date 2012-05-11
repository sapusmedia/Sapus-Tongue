/*
 * Copyright (c) 2008-2011 Ricardo Quesada
 * Copyright (c) 2011-2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


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
		CCSprite *back = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(0, 0, LOADING_BAR_X, LOADING_BAR_Y)];
		CCSprite *loadingBar = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(0, LOADING_BAR_Y*1, 0, LOADING_BAR_Y)];
		
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
