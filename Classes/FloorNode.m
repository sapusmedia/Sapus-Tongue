//
//  GameBackground.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 09/10/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

// A very simple Layer that draws a green bar in the bottom of the screen
// This is more efficient than having drawing each tile using a TileMapAtlas
// TIP:
//   . Again, here the OpenGL Quad is used to optimize things
#import "FloorNode.h"

@interface FloorNode (Private)
-(void) initBackground;
-(void) initFloor;
@end


@implementation FloorNode

-(id) init
{
	if( (self = [super init]) ) {
		floorTex_ = [[CCTextureCache sharedTextureCache] addImage:@"floor.png"];
		[floorTex_ retain];
	}

	return self;
}

-(void) dealloc
{
	[floorTex_ release];
	[super dealloc];
}

-(void) draw {

	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: GL_COLOR_ARRAY
	
	glDisableClientState(GL_COLOR_ARRAY);

	CGSize size = [[CCDirector sharedDirector] winSizeInPixels];
	
	[floorTex_ drawInRect:CGRectMake(0, 0, size.width, 8 * CC_CONTENT_SCALE_FACTOR())];
	
	glEnableClientState(GL_COLOR_ARRAY);
}

@end
