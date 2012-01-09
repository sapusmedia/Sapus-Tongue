//
//  SoundMenuItem.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 17/09/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "SoundMenuItem.h"
#import "SimpleAudioEngine.h"

//
// A MeneItem that plays a sound each time is is pressed
// Added support for SpriteFrameNames
//
@implementation SoundMenuItem

+(id) itemFromNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName target:(id)target selector:(SEL)selector
{
	return [[[self alloc] initFromNormalSpriteFrameName:normalFrameName selectedSpriteFrameName:selectedFrameName disabledSpriteFrameName:nil target:target selector:selector] autorelease];
}

+(id) itemFromNormalSpriteFrameName:(NSString*)normal selectedSpriteFrameName:(NSString*)selected disabledSpriteFrameName:(NSString*)disabled target:(id)target selector:(SEL)selector
{
	return [[[self alloc] initFromNormalSpriteFrameName:normal selectedSpriteFrameName:selected disabledSpriteFrameName:disabled target:target selector:selector] autorelease];
}

-(id) initFromNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName target:(id)target selector:(SEL)selector
{
	return [self initFromNormalSpriteFrameName:normalFrameName selectedSpriteFrameName:selectedFrameName disabledSpriteFrameName:nil target:target selector:selector];
}


-(id) initFromNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName disabledSpriteFrameName:(NSString*)disabledFrameName target:(id)target selector:(SEL)selector
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
