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

#import "FastGrid.h"

@interface FastGrid (Private)

-(void)calculateVertexPoints;

@end

@implementation FastGrid

+(id) gridWithTexture:(CCTexture2D*)texture
{
	return [[[self alloc] initWithTexture:texture] autorelease];
}

-(id)initWithTexture:(CCTexture2D*)texture
{
	if ( (self = [super init] ) )
	{
		self.texture = texture;
		sprite_ = [[CCSprite alloc] initWithTexture:texture];
	}
	
	return self;
}

- (void) dealloc
{
	[sprite_ release];
	[texture_ release];
	[fastGrid_ release];
		
	[super dealloc];
}


-(void)draw
{
	if( fastGrid_ && fastGrid_.active ) {

		glBindTexture(GL_TEXTURE_2D, [texture_ name]);
		
		[fastGrid_ blit];

	} else {
		[sprite_ draw];
	}
}

// override "slow grid"
-(CCGridBase*) grid
{
	return fastGrid_;
}

-(void) setGrid:(CCGridBase*)grid
{
	[grid setIsTextureFlipped:YES];
	[fastGrid_ release];
	fastGrid_ = [grid retain];
	[fastGrid_ setTexture:texture_];
}

// set texture into fastgrid if a new texture is set
-(void) setTexture:(CCTexture2D*) texture
{
	[texture_ release];
	texture_ = [texture retain];
	[fastGrid_ setTexture:texture_];
}

-(CCTexture2D*) texture
{
	return texture_;
}
@end
