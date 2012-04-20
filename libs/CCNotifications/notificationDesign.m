//
//  CCNotifications
//
//  Created by Manuel Martinez-Almeida Castañeda.
//  Copyright 2010 Abstraction Works. All rights reserved.
//	http://www.abstractionworks.com
//

#import "notificationDesign.h"

@implementation CCNotificationDefaultDesign

- (id) init
{
	CGSize size = [[CCDirector sharedDirector] winSize];
	self = [self initWithColor:ccc4(42, 68, 148, 180) width:size.width height:38];
	if (self != nil) {
		title_ = [CCLabelTTF labelWithString:@" " fontName:@"Arial" fontSize:12];
		[title_ setIgnoreAnchorPointForPosition:YES];
		[title_ setAnchorPoint:CGPointZero];
		[title_ setPosition:ccp(52, 20)];
		
		message_ = [CCLabelTTF labelWithString:@" " fontName:@"Arial" fontSize:15];
		[message_ setIgnoreAnchorPointForPosition:YES];
		[message_ setAnchorPoint:CGPointZero];
		[message_ setPosition:ccp(52, 3)];
		
		image_ = [CCSprite node];
		[image_ setPosition:ccp(26, 19)];
		
		[self addChild:title_];
		[self addChild:message_];
		[self addChild:image_];
	}
	return self;
}

- (void) setTitle:(NSString*)title message:(NSString*)message texture:(CCTexture2D*)texture{
	[title_ setString:title];
	[message_ setString:message];
	if(texture){
		CGRect rect = CGRectZero;
		rect.size = texture.contentSize;
		[image_ setTexture:texture];
		[image_ setTextureRect:rect];
		//Same size 32x32
		[image_ setScaleX:32.0f/rect.size.width];
		[image_ setScaleY:32.0f/rect.size.height];
	}
}

- (void) updateColor
{
	//Gradient code
	ccColor3B colorFinal = ccc3(0, 50, 100);
	
	squareColors_[0].r = color_.r;
	squareColors_[0].g = color_.g;
	squareColors_[0].b = color_.b;
	squareColors_[0].a = opacity_;
	
	squareColors_[1].r = color_.r;
	squareColors_[1].g = color_.g;
	squareColors_[1].b = color_.b;
	squareColors_[1].a = opacity_;
	
	squareColors_[2].r = colorFinal.r;
	squareColors_[2].g = colorFinal.g;
	squareColors_[2].b = colorFinal.b;
	squareColors_[2].a = opacity_;
	
	squareColors_[3].r = colorFinal.r;
	squareColors_[3].g = colorFinal.g;
	squareColors_[3].b = colorFinal.b;
	squareColors_[3].a = opacity_;
}

@end
