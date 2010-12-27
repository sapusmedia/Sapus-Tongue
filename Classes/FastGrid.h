//
//  FastGrid.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 19/04/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

//
// A class that transforms a texture into a grid
//

#import "cocos2d.h"

/** Base class for other
 */
@interface FastGrid : CCNode
{
	CCTexture2D		*texture_;
	CCSprite		*sprite_;

	CCGridBase		*fastGrid_;
}

/** texture used */
@property (nonatomic, readwrite, retain) CCTexture2D *texture;

/** creates and initializes a grid with a texture and a grid size */
+(id)gridWithTexture:(CCTexture2D*)texture;

/** initializes a grid with a texture and a grid size */
-(id)initWithTexture:(CCTexture2D*)texture;

@end
