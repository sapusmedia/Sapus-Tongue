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
