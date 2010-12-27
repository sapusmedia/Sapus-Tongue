//
//  MountainNode.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 13/12/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


//
// Scene that shows the background mountains.
// there 2 big images
// When 1 big images left the screen, it is re-placed after the other, simulating a never-ending background
//
// TIP:
//   This class can be reused to generate 'never-ending' backgrounds.
//

#import "MountainNode.h"

@implementation MountainNode
-(id) init
{
	if( (self=[super init]) ) {
	
		mountain1_ = [CCSprite spriteWithFile:@"mountains1.png"];
		mountain1_.anchorPoint = CGPointZero;
		mountain1_.position = ccp(0,0);
		[self addChild:mountain1_ z:0];

		mountain2_ = [CCSprite spriteWithFile:@"mountains2.png"];
		mountain2_.anchorPoint = CGPointZero;
		mountain2_.position = ccp(1024,0);
		[self addChild:mountain2_ z:1];
		
		[self schedule:@selector(updateMountains:)];
		
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

//
// Re position the images
//
-(void) updateMountains:(ccTime) dt
{
	
	CGPoint absPos = [self convertToWorldSpace:CGPointZero];
	
	// Ask parent position (parent is the parallax node)
	
	// If position if different from last position then update mountains position
	if( ! CGPointEqualToPoint(absPos, lastPos_) ) {

		int x = abs( absPos.x / 1024 );
		if( x % 2 == 0 ) {
			mountain1_.position = ccp(1024 * (x+0),0);
			mountain2_.position = ccp(1024 * (x+1),0);
		} else {
			mountain1_.position = ccp(1024 * (x+1),0);
			mountain2_.position = ccp(1024 * (x),0);
		}
		
		lastPos_ = absPos;
	}
	
}
@end
