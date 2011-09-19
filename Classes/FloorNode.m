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
		
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTexture];
	}

	return self;
}

-(void) dealloc
{
	[floorTex_ release];
	[super dealloc];
}

-(void) draw
{	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords );
	
	ccGLUseProgram( shaderProgram_->program_ );
	ccGLUniformModelViewProjectionMatrix( shaderProgram_ );
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	[floorTex_ drawInRect:CGRectMake(0, 0, size.width, 8) ];

	CHECK_GL_ERROR_DEBUG();	

}

@end
