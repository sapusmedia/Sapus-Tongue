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

#import "cocos2d.h"

#ifdef __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>
#endif


enum {
	kTagConnectionFailedAlert = 1,
	kTagPauseAlert = 2,
};

typedef enum {
	kHUDGame,
	kHUDMenu,
	kHUDRemoveMenu,
} tHUDState;

@class GameNode;

#if __CC_PLATFORM_IOS
@interface GameHUD : CCLayer  <UITextFieldDelegate, UIAlertViewDelegate>
#elif __CC_PLATFORM_MAC
@interface GameHUD : CCLayer
#endif
{
	
#if __CC_PLATFORM_IOS
	// UI controls
	UITextField		*nameField_;
	UIActivityIndicatorView *activityIndicator_;
#endif // __CC_PLATFORM_IOS

	// pointer to State
	GameNode		*game_;

	// player name
	NSString		*name_;

	tHUDState	state;
	
	CCLabelAtlas	*scoreLabel_;
	CCSprite		*arrowSprite_;
	CCLabelAtlas	*angleLabel_;
	CCLabelAtlas	*speedLabel_;
	CCSprite		*speedSprite_;
	
	// global scores stuff
	BOOL					submittingInProgress_;
}

// initialization
-(id) initWithGame:(GameNode*) game;

@end
