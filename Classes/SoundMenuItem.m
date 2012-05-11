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


#import "SoundMenuItem.h"
#import "SimpleAudioEngine.h"

//
// A MeneItem that plays a sound each time is is pressed
// Added support for SpriteFrameNames
//
@implementation SoundMenuItem

+(id) itemWithNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName target:(id)target selector:(SEL)selector
{
	return [[[self alloc] initWithNormalSpriteFrameName:normalFrameName selectedSpriteFrameName:selectedFrameName disabledSpriteFrameName:nil target:target selector:selector] autorelease];
}

+(id) itemWithNormalSpriteFrameName:(NSString*)normal selectedSpriteFrameName:(NSString*)selected disabledSpriteFrameName:(NSString*)disabled target:(id)target selector:(SEL)selector
{
	return [[[self alloc] initWithNormalSpriteFrameName:normal selectedSpriteFrameName:selected disabledSpriteFrameName:disabled target:target selector:selector] autorelease];
}

-(id) initWithNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName target:(id)target selector:(SEL)selector
{
	return [self initWithNormalSpriteFrameName:normalFrameName selectedSpriteFrameName:selectedFrameName disabledSpriteFrameName:nil target:target selector:selector];
}


-(id) initWithNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName disabledSpriteFrameName:(NSString*)disabledFrameName target:(id)target selector:(SEL)selector
{
	CCSprite *normal = [CCSprite spriteWithSpriteFrameName:normalFrameName];
	CCSprite *selected = [CCSprite spriteWithSpriteFrameName:selectedFrameName];
	
	CCSprite *disabled = nil;
	if( disabledFrameName )
		disabled = [CCSprite spriteWithSpriteFrameName:disabledFrameName];
				
	if( (self=[super initWithNormalSprite:normal selectedSprite:selected disabledSprite:disabled target:target selector:selector]))
	{

		// nothing
	}
	return self;	
}

-(void) selected {
	[super selected];

	[[SimpleAudioEngine sharedEngine] playEffect:@"snd-tap-button.caf"];
}

@end
